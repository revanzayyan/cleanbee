import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingService extends ChangeNotifier {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  // Lazy access so Firestore is resolved only after Firebase.initializeApp() runs.
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  final List<BookingModel> _orders = [];

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _bookingSub;

  bool _isListening = false;

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

  void ensureListening(String userUid) {
    if (_isListening) return;
    _isListening = true;

    // Prevent leaking wrong UID into query if uid is empty
    if (userUid.isEmpty) return;

    _bookingSub = _firestore
        .collection('bookings')
        .where('user_uid', isEqualTo: userUid)
        .snapshots()
        .listen((snapshot) {
      final nextOrders = snapshot.docs.map((doc) {
        final data = doc.data();
        return BookingModel(
          id: doc.id,
          category: (data['category'] ?? '') as String,
          buildingType: (data['building_type'] ?? '') as String,
          buildingDetail: (data['building_detail'] ?? '') as String,
          floorDetail: (data['floor_detail'] ?? '') as String,
          roomDetail: (data['room_detail'] ?? '') as String,
          date: (data['date'] is String)
              ? DateTime.parse(data['date'] as String)
              : DateTime.now(),
          timeRange: (data['time_range'] ?? '') as String,
          userUid: data['user_uid'] as String?,
          userEmail: data['user_email'] as String?,
          createdAt: (data['created_at'] is String)
              ? DateTime.parse(data['created_at'] as String)
              : DateTime.now(),
          status: (data['status'] ?? 'Diproses') as String,
          petugasName: (data['petugas_name'] ?? 'Sari Dewi') as String,
          petugasRating: (data['petugas_rating'] ?? 4.9) is num
              ? (data['petugas_rating'] as num).toDouble()
              : 4.9,
        );
      }).toList();

      _orders
        ..clear()
        ..addAll(nextOrders);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _bookingSub?.cancel();
    super.dispose();
  }

  // Digunakan oleh BookingConfirmationScreen
  Future<BookingModel?> saveBooking(BookingModel order) async {
    if (!isSlotAvailable(order.scheduleKey, order.timeRange)) return null;

    try {
      // Firestore tidak bisa menerima field bernilai null/undefined.
      // Pastikan model export ke map sudah non-null untuk field wajib.
      final normalizedOrder = order.copyWith(
        category: order.category.isEmpty ? 'Cleaning' : order.category,
      );

      final hasCustomId = normalizedOrder.id.isNotEmpty;


      if (hasCustomId) {
        // Jika id sudah diberikan, pakai id itu sebagai docId.
        await _firestore.collection('bookings').doc(order.id).set(normalizedOrder.toMap(), SetOptions(merge: true));
        final savedOrder = order;
        _orders.add(savedOrder);
        notifyListeners();
        return savedOrder;
      }

      // fallback: auto-id
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

  Future<void> cancelOrder(String orderId) async {
    if (orderId.isEmpty) return;

    try {
      await _firestore.collection('bookings').doc(orderId).set(
        {
          'status': 'Dibatalkan',
          'cancelled_at': DateTime.now().toIso8601String(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Error cancelling order ($orderId): $e');
      // tetap update lokal agar UI responsif
    }

    updateOrderStatus(orderId, 'Dibatalkan');
  }

  void updateOrderStatus(String orderId, String newStatus) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }
}