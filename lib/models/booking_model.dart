class BookingModel {
  final String id;
  final String category;
  final String buildingType;
  final String buildingDetail;
  final String floorDetail;
  final String roomDetail;
  final DateTime date;
  final String timeRange;
  final String? userUid;
  final String? userEmail;
  final DateTime createdAt;
  // status: 'Diproses' | 'Menunggu Pembayaran' | 'menunggu_konfirmasi' | 'Selesai' | 'Dibatalkan'
  final String status;
  final String petugasName;
  final double petugasRating;
  final String? beforePhotoUrl;
  final String? afterPhotoUrl;

  BookingModel({
    this.id = '',
    required this.category,
    required this.buildingType,
    required this.buildingDetail,
    required this.floorDetail,
    required this.roomDetail,
    required this.date,
    required this.timeRange,
    this.userUid,
    this.userEmail,
    DateTime? createdAt,
    this.status = 'Menunggu Verifikasi',
    this.petugasName = 'Sari Dewi',
    this.petugasRating = 4.9,
    this.beforePhotoUrl,
    this.afterPhotoUrl,
  }) : createdAt = createdAt ?? DateTime.now();

  String get scheduleKey => '${date.year}-${date.month}-${date.day}';
  String get formattedDate =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  String get fullAddress =>
      '$buildingType, $buildingDetail, Lantai $floorDetail, Kamar $roomDetail';

  factory BookingModel.fromMap(Map<String, dynamic> map, String docId) {
    return BookingModel(
      id: docId,
      category: map['category'] ?? '',
      buildingType: map['building_type'] ?? '',
      buildingDetail: map['building_detail'] ?? '',
      floorDetail: map['floor_detail'] ?? '',
      roomDetail: map['room_detail'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      timeRange: map['time_range'] ?? '',
      userUid: map['user_uid'],
      userEmail: map['user_email'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      status: map['status'] ?? 'Menunggu Verifikasi',
      petugasName: map['petugas_name'] ?? 'Sari Dewi',
      petugasRating: (map['petugas_rating'] ?? 4.9).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'building_type': buildingType,
      'building_detail': buildingDetail,
      'floor_detail': floorDetail,
      'room_detail': roomDetail,
      'date': date.toIso8601String(),
      'time_range': timeRange,
      'user_uid': userUid,
      'user_email': userEmail,
      'created_at': createdAt.toIso8601String(),
      'status': status,
      'petugas_name': petugasName,
      'petugas_rating': petugasRating,
      if (beforePhotoUrl != null) 'before_photo_url': beforePhotoUrl,
      if (afterPhotoUrl != null) 'after_photo_url': afterPhotoUrl,
    };
  }

  BookingModel copyWith({
    String? status,
    String? id,
    String? category,
    String? beforePhotoUrl,
    String? afterPhotoUrl,
  }) {
    return BookingModel(
      id: id ?? this.id,
      category: category ?? this.category,
      buildingType: buildingType,
      buildingDetail: buildingDetail,
      floorDetail: floorDetail,
      roomDetail: roomDetail,
      date: date,
      timeRange: timeRange,
      userUid: userUid,
      userEmail: userEmail,
      createdAt: createdAt,
      status: status ?? this.status,
      petugasName: petugasName,
      petugasRating: petugasRating,
      beforePhotoUrl: beforePhotoUrl ?? this.beforePhotoUrl,
      afterPhotoUrl: afterPhotoUrl ?? this.afterPhotoUrl,
    );
  }
}