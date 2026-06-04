import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';

class DokuPaymentService {
  static final DokuPaymentService _instance = DokuPaymentService._internal();
  factory DokuPaymentService() => _instance;
  DokuPaymentService._internal();

  final Dio _dio = Dio();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // DOKU credentials should NOT be used on the client (Flutter Web) due to CORS/network-layer issues.
  // Virtual Account creation must be proxied via your backend.


  // Base URL for your backend proxy (must be reachable from Flutter Web)
  static const String backendBaseUrl = 'http://localhost:3000';



  // Keeping these constants for now, but createVirtualAccount will use backend.
  static const String clientId = 'BRN-0262-1780146553005';
  static const String clientSecret = 'SK-60L1YUXahdcWnHQ7ezUX';

  static const String baseUrl = 'https://staging-api.doku.com'; // Staging/Sandbox (unused for VA creation)


  String _generateTimestamp() {
    return DateTime.now().toUtc().toIso8601String();
  }

  String _generateSignature(String method, String path, String timestamp, String body) {
    final signatureString = '$method\n$path\n$clientId\n$timestamp\n$body';
    final signature = Hmac(sha256, utf8.encode(clientSecret))
        .convert(utf8.encode(signatureString))
        .toString();
    return signature;
  }

  Future<DokuQrResponse> createQrPayment({
    required String bookingId,
    required double amount,
    required String description,
    String? customerId,
  }) async {
    try {
      final timestamp = _generateTimestamp();
      final requestBody = {
        'amount': amount.toInt(),
        'invoice_ref_no': bookingId,
        'reference': 'QR-$bookingId-${DateTime.now().millisecondsSinceEpoch}',
        'currency': 'IDR',
        'order': {
          'items': [
            {
              'name': description,
              'quantity': 1,
              'price': amount.toInt(),
            }
          ]
        },
        'customer': {
          'id': customerId ?? bookingId,
          'name': 'Customer',
        },
        'payment_type': 'QR_CODE',
        'callback_url': 'https://headlock-sternum-tinker.ngrok-free.dev/api/payment/callback',
        'expiry': {
          'unit': 'HOUR',
          'value': 24,
        }
      };

      final jsonBody = jsonEncode(requestBody);
      final path = '/payment/qr-dynamic/v2/generate';
      final signature = _generateSignature('POST', path, timestamp, jsonBody);

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'DOKU $clientId:$signature',
        'X-DOKU-Timestamp': timestamp,
        'X-DOKU-Idempotency-Key': '${DateTime.now().millisecondsSinceEpoch}',
      };

      final response = await _dio.post(
        '$baseUrl$path',
        options: Options(headers: headers),
        data: jsonBody,
      );

      if (response.statusCode == 200) {
        final qrResponse = DokuQrResponse.fromJson(response.data);

        // Save payment to Firestore
        await _savePaymentToFirestore(
          bookingId: bookingId,
          amount: amount,
          paymentMethod: 'qr_code',
          referenceId: qrResponse.referenceId,
          qrString: qrResponse.qrString,
          expiresAt: qrResponse.expiresAt,
        );

        return qrResponse;
      } else {
        throw Exception('Failed to create QR payment: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error creating QR payment: $e');
    }
  }

  Future<DokuVirtualAccountResponse> createVirtualAccount({
    required String bookingId,
    required double amount,
    required String description,
    required String bankCode, // e.g., 'BCA', 'MANDIRI', 'BNI', 'PERMATA'
    String? customerId,
    String? customerName,
  }) async {
    try {
      final response = await _dio.post(
        '$backendBaseUrl/api/payment/virtual-account/create',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'bookingId': bookingId,
          'amount': amount,
          'description': description,
          'bankCode': bankCode,
          'customerId': customerId,
          'customerName': customerName,
          // must match the backend URL that DOKU can call
          'callbackUrl': '$backendBaseUrl/api/payment/callback',

        },
      );

      // Backend returns: { requestId, data: <DOKU response> }
      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        final dokuData = body['data'];

        final vaResponse = DokuVirtualAccountResponse.fromJson(dokuData);

        await _savePaymentToFirestore(
          bookingId: bookingId,
          amount: amount,
          paymentMethod: 'virtual_account',
          referenceId: vaResponse.referenceId,
          virtualAccountNumber: vaResponse.virtualAccountNumber,
          expiresAt: vaResponse.expiresAt,
        );

        return vaResponse;
      }

      throw Exception('Failed to create virtual account: ${response.statusMessage}');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      throw Exception(
        'Error creating virtual account via backend (Dio): ${e.type} - ${e.message} (status: $status, data: $data)',
      );
    } catch (e) {
      throw Exception('Error creating virtual account: $e');
    }
  }


  Future<Map<String, dynamic>> checkPaymentStatus(String referenceId) async {
    try {
      final timestamp = _generateTimestamp();
      final path = '/payment/check-status/v2/$referenceId';
      final signature = _generateSignature('GET', path, timestamp, '');

      final headers = {
        'Authorization': 'DOKU $clientId:$signature',
        'X-DOKU-Timestamp': timestamp,
      };

      final response = await _dio.get(
        '$baseUrl$path',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return response.data['data'] ?? {};
      } else {
        throw Exception('Failed to check payment status: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error checking payment status: $e');
    }
  }

  /// Helper to normalize DOKU / backend payment status values.
  ///
  /// Backend webhook maps DOKU to: success/failed/pending/expired/cancelled.
  /// DOKU polling may return: SETTLED, SUCCESS, COMPLETED, FAILED, etc.
  bool isSuccessfulStatus(dynamic statusValue) {
    final s = statusValue?.toString().trim().toUpperCase();
    if (s == null || s.isEmpty) return false;

    // Backend mapped statuses
    if (s == 'SUCCESS') return true;

    // DOKU statuses
    const successSet = {
      'SETTLED',
      'SUCCESS',
      'COMPLETED',
    };

    return successSet.contains(s);
  }

  bool isFailedStatus(dynamic statusValue) {
    final s = statusValue?.toString().trim().toUpperCase();
    if (s == null || s.isEmpty) return false;

    // Backend mapped statuses
    if (s == 'FAILED') return true;

    const failedSet = {
      'FAILED',
      'REJECTED',
    };

    return failedSet.contains(s);
  }

  Future<void> _savePaymentToFirestore({
    required String bookingId,
    required double amount,
    required String paymentMethod,
    required String referenceId,
    String? qrString,
    String? virtualAccountNumber,
    required DateTime expiresAt,
  }) async {
    try {
      await _firestore.collection('payments').add({
        'booking_id': bookingId,
        'amount': amount,
        'payment_method': paymentMethod,
        'reference_id': referenceId,
        'qr_string': qrString,
        'virtual_account_number': virtualAccountNumber,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error saving payment: $e');
    }
  }

  Future<PaymentModel?> getPaymentByBookingId(String bookingId) async {
    try {
      final querySnapshot = await _firestore
          .collection('payments')
          .where('booking_id', isEqualTo: bookingId)
          .orderBy('created_at', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        return PaymentModel.fromMap({...data, 'id': querySnapshot.docs.first.id});
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching payment: $e');
    }
  }

  Future<void> updatePaymentStatus(String paymentId, String status) async {
    try {
      await _firestore.collection('payments').doc(paymentId).update({
        'status': status,
        'paid_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error updating payment status: $e');
    }
  }
}
