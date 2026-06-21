import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ChatMessage {
  final String sender; // "User" | "Admin"
  final String text;
  final String time; // ISO string for UI

  ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
  });
}

class ChatConversation {
  final String chatId;
  final String userName;
  final String lastMessage;
  final Timestamp? lastMessageTime;
  final int unreadAdmin;
  final int unreadUser;

  ChatConversation({
    required this.chatId,
    required this.userName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadAdmin,
    required this.unreadUser,
  });
}

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;

  ChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ChatConversation>> listenToChatList() {
    return _firestore
        .collection('chats')
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatConversation(
          chatId: doc.id,
          userName: (data['userName'] ?? '') as String,
          lastMessage: (data['lastMessage'] ?? '') as String,
          lastMessageTime: data['lastMessageTime'] as Timestamp?,
          unreadAdmin: (data['unreadAdmin'] ?? 0) as int,
          unreadUser: (data['unreadUser'] ?? 0) as int,
        );
      }).toList();

      list.sort((a, b) {
        final at = a.lastMessageTime;
        final bt = b.lastMessageTime;
        if (at == null && bt == null) return 0;
        if (at == null) return 1;
        if (bt == null) return -1;
        return bt.compareTo(at);
      });

      return list;
    });
  }

  Stream<List<ChatMessage>> listenToMessages(String chatId) {
    if (chatId.isEmpty) {
      return const Stream.empty();
    }

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('created_at')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final sender = (data['sender'] ?? 'User') as String;
        final text = (data['text'] ?? '') as String;
        final createdAt = data['created_at'];
        String timeIso = '';
        if (createdAt is Timestamp) {
          timeIso = createdAt.toDate().toIso8601String();
        } else if (createdAt is String) {
          timeIso = createdAt;
        }

        return ChatMessage(sender: sender, text: text, time: timeIso);
      }).toList();
    });
  }

  Future<String> startOrGetChat(String userName) async {
    final userNameTrim = userName.trim();
    if (userNameTrim.isEmpty) {
      throw ArgumentError('userName/chatId is empty');
    }

    // sesuai pilihan Anda: chatId = userUid
    // tapi sampai integrasi auth/userUid lengkap masuk ke UI,
    // kita anggap parameter yang dikirim dari UI sudah berisi chatId (UID).
    final chatId = userNameTrim;

    final docRef = _firestore.collection('chats').doc(chatId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) {
        tx.set(docRef, {
          'userName': userNameTrim,
          'lastMessage': '',
          'lastMessageTime': null,
          'unreadAdmin': 0,
          'unreadUser': 0,
        });
      }
    });

    return chatId;
  }


  Future<void> sendMessage({
    required String chatId,
    required String sender, // "User" | "Admin"
    required String text,
  }) async {
    final trimmed = text.trim();
    if (chatId.isEmpty || trimmed.isEmpty) return;

    final now = Timestamp.now();
    try {
      final messageDoc = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();

      await _firestore.runTransaction((tx) async {
        // buat chat doc bila belum ada
        final chatRef = _firestore.collection('chats').doc(chatId);
        final chatSnap = await tx.get(chatRef);
        if (!chatSnap.exists) {
          // fallback userName jika belum tersimpan: ambil docId
          tx.set(chatRef, {
            'userName': chatId,
            'lastMessage': '',
            'lastMessageTime': null,
            'unreadAdmin': 0,
            'unreadUser': 0,
          });
        }

        tx.set(messageDoc, {
          'sender': sender,
          'text': trimmed,
          'created_at': now,
        });

        // Update lastMessage
        // Aturan badge/unread:
        // - Kalau Admin mengirim: unreadUser (untuk pihak User) naik, unreadAdmin direset (karena Admin sedang mengirim/terbaca).
        // - Kalau User mengirim: unreadAdmin naik, unreadUser direset.
        tx.update(chatRef, {
          'lastMessage': trimmed,
          'lastMessageTime': now,
          if (sender == 'Admin')
            ...{
              'unreadUser': FieldValue.increment(1),
              'unreadAdmin': 0,
            }
          else
            ...{
              'unreadAdmin': FieldValue.increment(1),
              'unreadUser': 0,
            },
        });
      });
    } catch (e) {
      debugPrint('ChatService sendMessage error for $chatId: $e');
    }
  }

  Future<void> markAsRead(String chatId, String userRole) async {
    if (chatId.isEmpty) return;
    final docRef = _firestore.collection('chats').doc(chatId);

    try {
      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(docRef);
        if (!snap.exists) return;

        // reset unread milik pihak yang sedang membuka chat
        if (userRole == 'Admin') {
          tx.update(docRef, {'unreadAdmin': 0});
          // opsional: jika Admin membalas, unreadUser juga tidak masalah.
        } else {
          tx.update(docRef, {'unreadUser': 0});
        }
      });
    } catch (e) {
      debugPrint('ChatService markAsRead error for $chatId: $e');
    }
  }


  // Backward compatibility untuk kode lama
  Future<void> sendUserMessage(String chatId, String text) => sendMessage(chatId: chatId, sender: 'User', text: text);
  Future<void> sendAdminMessage(String chatId, String text) => sendMessage(chatId: chatId, sender: 'Admin', text: text);

  // Backward compatibility: streamless state tidak dipakai lagi, tetap sediakan method minimal.
  List<ChatMessage> getMessages(String chatId) {
    // dummy: UI baru memakai listenToMessages.
    return const [];
  }
}

