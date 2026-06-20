class NotificationModelAngga {
  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;

  NotificationModelAngga({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
  });

  factory NotificationModelAngga.fromMap(Map<String, dynamic> map, String docId) {
    return NotificationModelAngga(
      id: docId,
      userId: map['user_id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
      isRead: map['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
    };
  }

  NotificationModelAngga copyWith({bool? isRead}) {
    return NotificationModelAngga(
      id: id,
      userId: userId,
      title: title,
      body: body,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
