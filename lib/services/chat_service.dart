import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ChatMessage {
  final String sender;
  final String text;
  final String time;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
  });
}

class ChatService with ChangeNotifier {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;

  ChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, List<ChatMessage>> _conversations = {};
  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>> _listeners = {};

  List<ChatMessage> getMessages(String chatId) {
    _ensureConversation(chatId);
    return List.unmodifiable(_conversations[chatId]!);
  }

  Future<void> listenToChat(String chatId) async {
    if (chatId.isEmpty) return;
    if (_listeners.containsKey(chatId)) return;

    _ensureConversation(chatId);
    final sub = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('created_at')
        .snapshots()
        .listen((snapshot) {
      final messages = snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatMessage(
          sender: (data['sender'] ?? 'User') as String,
          text: (data['text'] ?? '') as String,
          time: (data['created_at'] ?? '') as String,
        );
      }).toList();

      _conversations[chatId] = messages;
      notifyListeners();
    }, onError: (error) {
      debugPrint('ChatService listen error for $chatId: $error');
    });

    _listeners[chatId] = sub;
  }

  void stopListening(String chatId) {
    _listeners.remove(chatId)?.cancel();
  }

  Future<void> sendUserMessage(String chatId, String text) async {
    await _sendMessage(chatId, 'User', text);
  }

  Future<void> sendAdminMessage(String chatId, String text) async {
    await _sendMessage(chatId, 'Admin', text);
  }

  Future<void> _sendMessage(String chatId, String sender, String text) async {
    if (chatId.isEmpty || text.trim().isEmpty) return;

    final now = DateTime.now().toIso8601String();
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'sender': sender,
        'text': text,
        'created_at': now,
      });
    } catch (e) {
      debugPrint('ChatService send error for $chatId: $e');
    }
  }

  void _ensureConversation(String chatId) {
    _conversations.putIfAbsent(chatId, () => []);
  }

  void disposeChat(String chatId) {
    stopListening(chatId);
    _conversations.remove(chatId);
  }
}
