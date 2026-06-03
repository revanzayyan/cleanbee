class PaymentModel {
  final String id;
  final String bookingId;
  final double amount;
  final String status; // pending, success, failed, expired
  final String paymentMethod; // qr_code, virtual_account
  final String? referenceId; // DOKU reference ID
  final String? virtualAccountNumber;
  final String? qrString;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? paidAt;
  final Map<String, dynamic>? metadata;

  PaymentModel({
    this.id = '',
    required this.bookingId,
    required this.amount,
    this.status = 'pending',
    required this.paymentMethod,
    this.referenceId,
    this.virtualAccountNumber,
    this.qrString,
    DateTime? createdAt,
    this.expiresAt,
    this.paidAt,
    this.metadata,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isPaid => status == 'success' && paidAt != null;

  Map<String, dynamic> toMap() {
    return {
      'booking_id': bookingId,
      'amount': amount,
      'status': status,
      'payment_method': paymentMethod,
      'reference_id': referenceId,
      'virtual_account_number': virtualAccountNumber,
      'qr_string': qrString,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] ?? '',
      bookingId: map['booking_id'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      paymentMethod: map['payment_method'] ?? 'qr_code',
      referenceId: map['reference_id'],
      virtualAccountNumber: map['virtual_account_number'],
      qrString: map['qr_string'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      expiresAt: map['expires_at'] != null ? DateTime.parse(map['expires_at']) : null,
      paidAt: map['paid_at'] != null ? DateTime.parse(map['paid_at']) : null,
      metadata: map['metadata'],
    );
  }

  PaymentModel copyWith({
    String? id,
    String? bookingId,
    double? amount,
    String? status,
    String? paymentMethod,
    String? referenceId,
    String? virtualAccountNumber,
    String? qrString,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? paidAt,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      referenceId: referenceId ?? this.referenceId,
      virtualAccountNumber: virtualAccountNumber ?? this.virtualAccountNumber,
      qrString: qrString ?? this.qrString,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      paidAt: paidAt ?? this.paidAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

class DokuQrResponse {
  final String referenceId;
  final String qrString;
  final double amount;
  final DateTime expiresAt;
  final String status;

  DokuQrResponse({
    required this.referenceId,
    required this.qrString,
    required this.amount,
    required this.expiresAt,
    this.status = 'pending',
  });

  factory DokuQrResponse.fromJson(Map<String, dynamic> json) {
    return DokuQrResponse(
      referenceId: json['data']?['reference'] ?? '',
      qrString: json['data']?['qr_string'] ?? '',
      amount: (json['data']?['amount'] ?? 0).toDouble(),
      expiresAt: json['data']?['expires_at'] != null
          ? DateTime.parse(json['data']['expires_at'])
          : DateTime.now().add(const Duration(hours: 24)),
      status: json['data']?['status'] ?? 'pending',
    );
  }
}

class DokuVirtualAccountResponse {
  final String referenceId;
  final String virtualAccountNumber;
  final double amount;
  final DateTime expiresAt;
  final String bankCode;
  final String status;

  DokuVirtualAccountResponse({
    required this.referenceId,
    required this.virtualAccountNumber,
    required this.amount,
    required this.expiresAt,
    required this.bankCode,
    this.status = 'pending',
  });

  factory DokuVirtualAccountResponse.fromJson(Map<String, dynamic> json) {
    return DokuVirtualAccountResponse(
      referenceId: json['data']?['reference'] ?? '',
      virtualAccountNumber: json['data']?['virtual_account_number'] ?? '',
      amount: (json['data']?['amount'] ?? 0).toDouble(),
      expiresAt: json['data']?['expires_at'] != null
          ? DateTime.parse(json['data']['expires_at'])
          : DateTime.now().add(const Duration(hours: 24)),
      bankCode: json['data']?['bank_code'] ?? '',
      status: json['data']?['status'] ?? 'pending',
    );
  }
}
