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
  final String status;
  final String petugasName;
  final double petugasRating;

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
    this.status = 'Diproses',
    this.petugasName = 'Sari Dewi',
    this.petugasRating = 4.9,
  }) : createdAt = createdAt ?? DateTime.now();

  String get scheduleKey => '${date.year}-${date.month}-${date.day}';
  String get formattedDate =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  String get fullAddress =>
      '$buildingType, $buildingDetail, Lantai $floorDetail, Kamar $roomDetail';

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
    };
  }

  BookingModel copyWith({String? status, String? id, String? category}) {
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
    );
  }
}