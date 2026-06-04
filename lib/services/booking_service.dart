import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import 'notification_service_angga.dart';

class BookingService extends ChangeNotifier {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<BookingModel> _orders = [];

  final Map<String, List<Map<String, dynamic>>> _baseScheduleData = {
    '2025-4-1': [
      {'time': '07:00 - 08:00', 'isAvailable': false},
      {'time': '09:00 - 10:00', 'isAvailable': true},
      {'time': '13:00 - 14:00', 'isAvailable': true},
    ],
    '2025-4-5': [
      {'time': '07:00 - 08:00', 'isAvailable': false},
      {'time': '10:00 - 11:00', 'isAvailable': false},
      {'time': '14:00 - 15:00', 'isAvailable': true},
    ],
    '2025-4-10': [
      {'time': '08:00 - 09:00', 'isAvailable': true},
      {'time': '11:00 - 12:00', 'isAvailable': false},
      {'time': '15:00 - 16:00', 'isAvailable': true},
    ],
    '2025-4-15': [
      {'time': '07:00 - 08:00', 'isAvailable': false},
      {'time': '10:00 - 11:00', 'isAvailable': false},
      {'time': '13:00 - 14:00', 'isAvailable': false},
    ],
    '2025-4-19': [
      {'time': '07:00 - 08:00', 'isAvailable': false},
      {'time': '10:00 - 11:00', 'isAvailable': true},
      {'time': '11:00 - 12:00', 'isAvailable': true},
    ],
    '2025-4-22': [
      {'time': '09:00 - 10:00', 'isAvailable': true},
      {'time': '12:00 - 13:00', 'isAvailable': false},
      {'time': '16:00 - 17:00', 'isAvailable': true},
    ],
    '2025-5-3': [
      {'time': '07:00 - 08:00', 'isAvailable': true},
      {'time': '10:00 - 11:00', 'isAvailable': true},
    ],
    '2025-5-10': [
      {'time': '08:00 - 09:00', 'isAvailable': false},
      {'time': '13:00 - 14:00', 'isAvailable': true},
    ],
  };

  List<BookingModel> get orders => List.unmodifiable(_orders);

  List<BookingModel> getActiveOrders() {
    return _orders
        .where((o) => o.status != 'Selesai' && o.status != 'Dibatalkan')
        .toList();
  }

  List<Map<String, dynamic>> getSlotsForDate(String scheduleKey) {
    List<Map<String, dynamic>> slots;
    if (_baseScheduleData.containsKey(scheduleKey)) {
      slots = _baseScheduleData[scheduleKey]!.map((s) => Map<String, dynamic>.from(s)).toList();
    } else {
      slots = [
        {'time': '07:00 - 08:00', 'isAvailable': true},
        {'time': '10:00 - 11:00', 'isAvailable': true},
        {'time': '11:00 - 12:00', 'isAvailable': true},
      ];
    }
    for (var slot in slots) {
      final isBooked = _orders.any((o) =>
          o.scheduleKey == scheduleKey &&
          o.timeRange == slot['time'] &&
          o.status != 'Dibatalkan');
      if (isBooked) slot['isAvailable'] = false;
    }
    return slots;
  }

  bool hasScheduleForDate(String scheduleKey) {
    if (_baseScheduleData.containsKey(scheduleKey)) return true;
    return _orders.any((o) => o.scheduleKey == scheduleKey && o.status != 'Dibatalkan');
  }

  bool isSlotAvailable(String scheduleKey, String timeRange) {
    final isBooked = _orders.any((o) =>
        o.scheduleKey == scheduleKey &&
        o.timeRange == timeRange &&
        o.status != 'Dibatalkan');
    if (isBooked) return false;
    final slots = getSlotsForDate(scheduleKey);
    final match = slots.firstWhere((s) => s['time'] == timeRange, orElse: () => {'isAvailable': false});
    return match['isAvailable'] == true;
  }

  // Digunakan oleh BookingConfirmationScreen
  Future<BookingModel?> saveBooking(BookingModel order) async {
    if (!isSlotAvailable(order.scheduleKey, order.timeRange)) return null;

    try {
      final docRef = await _firestore.collection('bookings').add(order.toMap());
      final savedOrder = order.copyWith(id: docRef.id);
      _orders.add(savedOrder);
      notifyListeners();

      // Create notification for admin about the new booking
      await NotificationServiceAngga().addNotification(
        userId: 'admin',
        title: 'Pesanan Baru Masuk 🧹',
        body: 'Pesanan oleh ${order.userEmail ?? "User"} untuk ${order.category} pada ${order.formattedDate} telah diterima.',
      );

      return savedOrder;
    } catch (e) {
      debugPrint('Error saving to Firebase: $e');
      _orders.add(order);
      notifyListeners();
      return order;
    }
  }

  StreamSubscription<QuerySnapshot>? _bookingsSubscription;

  void syncUserBookings(String userId) {
    _bookingsSubscription?.cancel();
    _bookingsSubscription = _firestore.collection('bookings')
        .where('user_uid', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
          _orders.clear();
          for (var doc in snapshot.docs) {
            _orders.add(BookingModel.fromMap(doc.data(), doc.id));
          }
          // Sort by created_at descending
          _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          notifyListeners();
        });
  }

  void disposeSync() {
    _bookingsSubscription?.cancel();
  }

  Stream<List<BookingModel>> getBookingsStream() {
    return _firestore.collection('bookings')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return BookingModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  Future<void> cancelOrder(String orderId) async {
    await updateOrderStatusInFirestore(orderId, 'Dibatalkan');
  }

  Future<void> updateOrderStatusInFirestore(String orderId, String newStatus) async {
    try {
      // Fetch booking details first to know who the user is
      final docSnap = await _firestore.collection('bookings').doc(orderId).get();
      if (docSnap.exists) {
        final data = docSnap.data()!;
        final userUid = data['user_uid'] as String?;
        final category = data['category'] ?? 'Layanan Kebersihan';
        
        await _firestore.collection('bookings').doc(orderId).update({'status': newStatus});

        // Update local status
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = _orders[index].copyWith(status: newStatus);
          notifyListeners();
        }

        // Send notification to resident
        if (userUid != null) {
          String notifTitle = 'Update Status Pesanan 📢';
          String notifBody = 'Pesanan Anda untuk $category statusnya kini berubah menjadi: $newStatus.';
          
          if (newStatus == 'Diproses') {
            notifTitle = 'Pesanan Terkonfirmasi! 🎉';
            notifBody = 'Pesanan $category Anda telah diverifikasi oleh Admin. Petugas segera menuju lokasi.';
          } else if (newStatus == 'Dibatalkan') {
            notifTitle = 'Pesanan Dibatalkan/Ditolak ⚠️';
            notifBody = 'Pesanan $category Anda telah dibatalkan atau ditolak.';
          } else if (newStatus == 'Selesai') {
            notifTitle = 'Pekerjaan Selesai! ✨';
            notifBody = 'Layanan $category telah selesai dikerjakan. Silakan berikan ulasan Anda.';
          }

          await NotificationServiceAngga().addNotification(
            userId: userUid,
            title: notifTitle,
            body: notifBody,
          );
        }
      }
    } catch (e) {
      debugPrint('Error updating status in Firestore: $e');
    }
  }

  void updateOrderStatus(String orderId, String newStatus) {
    updateOrderStatusInFirestore(orderId, newStatus);
  }
}