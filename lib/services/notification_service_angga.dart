import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/notification_model_angga.dart';

class NotificationServiceAngga extends ChangeNotifier {
  static final NotificationServiceAngga _instance = NotificationServiceAngga._internal();
  factory NotificationServiceAngga() => _instance;
  NotificationServiceAngga._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of notifications for a specific user
  Stream<List<NotificationModelAngga>> getNotificationsStream(String userId) {
    return _firestore.collection('notifications')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) {
            return NotificationModelAngga.fromMap(doc.data(), doc.id);
          }).toList();
          
          // Sort client-side in case firestore indexes are not yet fully generated
          list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return list;
        });
  }

  // Stream of unread notification count
  Stream<int> getUnreadCountStream(String userId) {
    return _firestore.collection('notifications')
        .where('user_id', isEqualTo: userId)
        .where('is_read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Create a new notification
  Future<void> addNotification({
    required String userId,
    required String title,
    required String body,
  }) async {
    try {
      final notif = NotificationModelAngga(
        id: '',
        userId: userId,
        title: title,
        body: body,
        timestamp: DateTime.now(),
        isRead: false,
      );
      await _firestore.collection('notifications').add(notif.toMap());
    } catch (e) {
      debugPrint('Error adding notification: $e');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notifId) async {
    try {
      await _firestore.collection('notifications').doc(notifId).update({'is_read': true});
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    try {
      final query = await _firestore.collection('notifications')
          .where('user_id', isEqualTo: userId)
          .where('is_read', isEqualTo: false)
          .get();
      
      final batch = _firestore.batch();
      for (var doc in query.docs) {
        batch.update(doc.reference, {'is_read': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  // Delete a notification
  Future<void> deleteNotification(String notifId) async {
    try {
      await _firestore.collection('notifications').doc(notifId).delete();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }
}
