import 'package:flutter/material.dart';

class BookingOrder {
  final String id;
  final String category;
  final String buildingType;
  final String buildingDetail;
  final String floorDetail;
  final String roomDetail;
  final DateTime date;
  final String timeRange;
  final String status;
  final DateTime createdAt;
  final String petugasName;
  final double petugasRating;

  BookingOrder({
    required this.id,
    required this.category,
    required this.buildingType,
    required this.buildingDetail,
    required this.floorDetail,
    required this.roomDetail,
    required this.date,
    required this.timeRange,
    this.status = 'Diproses',
    DateTime? createdAt,
    this.petugasName = 'Sari Dewi',
    this.petugasRating = 4.9,
  }) : createdAt = createdAt ?? DateTime.now();

  String get scheduleKey => '${date.year}-${date.month}-${date.day}';

  String get formattedDate =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  String get fullAddress =>
      '$buildingType, $buildingDetail, Lantai $floorDetail, Kamar $roomDetail';

  BookingOrder copyWith({String? status}) {
    return BookingOrder(
      id: id,
      category: category,
      buildingType: buildingType,
      buildingDetail: buildingDetail,
      floorDetail: floorDetail,
      roomDetail: roomDetail,
      date: date,
      timeRange: timeRange,
      status: status ?? this.status,
      createdAt: createdAt,
      petugasName: petugasName,
      petugasRating: petugasRating,
    );
  }
}

class BookingService extends ChangeNotifier {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  final List<BookingOrder> _orders = [];

  // ─── Data jadwal dasar ──────────────────────────────────────
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

  // ─── GETTERS ────────────────────────────────────────────────

  List<BookingOrder> get orders => List.unmodifiable(_orders);

  List<BookingOrder> getActiveOrders() {
    return _orders
        .where((o) => o.status != 'Selesai' && o.status != 'Dibatalkan')
        .toList();
  }

  BookingOrder? get latestActiveOrder {
    final active = getActiveOrders();
    return active.isEmpty ? null : active.last;
  }

  // ─── SCHEDULE (gabungkan data dasar + booking) ──────────────

  /// Ambil slot untuk tanggal tertentu.
  /// Slot yang sudah di-booking akan otomatis jadi isAvailable: false.
  List<Map<String, dynamic>> getSlotsForDate(String scheduleKey) {
    List<Map<String, dynamic>> slots;

    if (_baseScheduleData.containsKey(scheduleKey)) {
      slots = _baseScheduleData[scheduleKey]!
          .map((s) => Map<String, dynamic>.from(s))
          .toList();
    } else {
      slots = [
        {'time': '07:00 - 08:00', 'isAvailable': true},
        {'time': '10:00 - 11:00', 'isAvailable': true},
        {'time': '11:00 - 12:00', 'isAvailable': true},
      ];
    }

    // Override: tandai slot yang sudah di-booking
    for (var slot in slots) {
      final isBooked = _orders.any((o) =>
          o.scheduleKey == scheduleKey &&
          o.timeRange == slot['time'] &&
          o.status != 'Dibatalkan');
      if (isBooked) {
        slot['isAvailable'] = false;
      }
    }

    return slots;
  }

  bool hasScheduleForDate(String scheduleKey) {
    if (_baseScheduleData.containsKey(scheduleKey)) return true;
    return _orders.any(
        (o) => o.scheduleKey == scheduleKey && o.status != 'Dibatalkan');
  }

  bool isSlotAvailable(String scheduleKey, String timeRange) {
    final isBooked = _orders.any((o) =>
        o.scheduleKey == scheduleKey &&
        o.timeRange == timeRange &&
        o.status != 'Dibatalkan');
    if (isBooked) return false;

    final slots = getSlotsForDate(scheduleKey);
    final match = slots.firstWhere(
      (s) => s['time'] == timeRange,
      orElse: () => {'isAvailable': false},
    );
    return match['isAvailable'] == true;
  }

  // ─── BOOKING ────────────────────────────────────────────────

  /// Return order jika berhasil, null jika slot sudah penuh.
  BookingOrder? createBooking({
    required String category,
    required String buildingType,
    required String buildingDetail,
    required String floorDetail,
    required String roomDetail,
    required DateTime date,
    required String timeRange,
  }) {
    final scheduleKey = '${date.year}-${date.month}-${date.day}';

    if (!isSlotAvailable(scheduleKey, timeRange)) {
      return null;
    }

    final order = BookingOrder(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      category: category,
      buildingType: buildingType,
      buildingDetail: buildingDetail,
      floorDetail: floorDetail,
      roomDetail: roomDetail,
      date: date,
      timeRange: timeRange,
      status: 'Diproses',
    );

    _orders.add(order);
    notifyListeners();
    return order;
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