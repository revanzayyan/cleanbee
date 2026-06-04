import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

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
      return savedOrder;
    } catch (e) {
      debugPrint('Error saving to Firebase: $e');
      _orders.add(order);
      notifyListeners();
      return order;
    }
  }

  void cancelOrder(String orderId) => updateOrderStatus(orderId, 'Dibatalkan');

  void updateOrderStatus(String orderId, String newStatus) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }
}