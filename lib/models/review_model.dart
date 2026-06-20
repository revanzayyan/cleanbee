class ReviewModel {
  final String id;
  final String orderId;
  final String customerId;
  final String customerName;
  final String staffId;
  final String staffName;
  final int rating; // 1–5
  final String? comment;
  final String? afterPhotoUrl;
  final String? beforePhotoUrl;
  final DateTime createdAt;
  final String? adminReply;

  ReviewModel({
    this.id = '',
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.staffId,
    required this.staffName,
    required this.rating,
    this.comment,
    this.afterPhotoUrl,
    this.beforePhotoUrl,
    DateTime? createdAt,
    this.adminReply,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'customer_id': customerId,
      'customer_name': customerName,
      'staff_id': staffId,
      'staff_name': staffName,
      'rating': rating,
      'comment': comment,
      'after_photo_url': afterPhotoUrl,
      'before_photo_url': beforePhotoUrl,
      'created_at': createdAt.toIso8601String(),
      'admin_reply': adminReply,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> data, {String id = ''}) {
    return ReviewModel(
      id: id,
      orderId: (data['order_id'] ?? '') as String,
      customerId: (data['customer_id'] ?? '') as String,
      customerName: (data['customer_name'] ?? 'Pengguna') as String,
      staffId: (data['staff_id'] ?? '') as String,
      staffName: (data['staff_name'] ?? '') as String,
      rating: (data['rating'] ?? 5) as int,
      comment: data['comment'] as String?,
      afterPhotoUrl: data['after_photo_url'] as String?,
      beforePhotoUrl: data['before_photo_url'] as String?,
      createdAt: data['created_at'] is String
          ? DateTime.parse(data['created_at'] as String)
          : DateTime.now(),
      adminReply: data['admin_reply'] as String?,
    );
  }

  ReviewModel copyWith({String? adminReply, String? id}) {
    return ReviewModel(
      id: id ?? this.id,
      orderId: orderId,
      customerId: customerId,
      customerName: customerName,
      staffId: staffId,
      staffName: staffName,
      rating: rating,
      comment: comment,
      afterPhotoUrl: afterPhotoUrl,
      beforePhotoUrl: beforePhotoUrl,
      createdAt: createdAt,
      adminReply: adminReply ?? this.adminReply,
    );
  }

  /// Waktu relatif untuk ditampilkan di UI
  String get relativeTime {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} minggu lalu';
    return '${(diff.inDays / 30).floor()} bulan lalu';
  }
}
