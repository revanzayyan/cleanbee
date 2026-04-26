class BookingModel {
  final String category;
  final String buildingType;
  final String building;
  final String floor;
  final String room;
  final DateTime date;
  final String time;
  final String? userUid;
  final String? userEmail;
  final DateTime createdAt;
  final String status;

  BookingModel({
    required this.category,
    required this.buildingType,
    required this.building,
    required this.floor,
    required this.room,
    required this.date,
    required this.time,
    this.userUid,
    this.userEmail,
    DateTime? createdAt,
    this.status = 'pending',
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'building_type': buildingType,
      'building': building,
      'floor': floor,
      'room': room,
      'date': date.toIso8601String(),
      'time': time,
      'user_uid': userUid,
      'user_email': userEmail,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }
}
