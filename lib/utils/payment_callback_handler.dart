import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';

class PaymentCallbackHandler {
  static final PaymentCallbackHandler _instance = PaymentCallbackHandler._internal();
  factory PaymentCallbackHandler() => _instance;
  PaymentCallbackHandler._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DokuPaymentService _paymentService = DokuPaymentService();

  /// Handle DOKU webhook callback
  /// This should be called from your backend webhook endpoint
  Future<void> handlePaymentCallback({
    required String referenceId,
    required String status,
    required int amount,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Find payment record by reference_id
      final paymentSnapshot = await _firestore
          .collection('payments')
          .where('reference_id', isEqualTo: referenceId)
          .limit(1)
          .get();

      if (paymentSnapshot.docs.isEmpty) {
        throw Exception('Payment record not found for reference: $referenceId');
      }

      final paymentDoc = paymentSnapshot.docs.first;
      final paymentData = paymentDoc.data();
      final bookingId = paymentData['booking_id'];

      // Update payment status
      await _firestore.collection('payments').doc(paymentDoc.id).update({
        'status': status,
        'paid_at': DateTime.now().toIso8601String(),
        'metadata': metadata,
      });

      // If payment successful, update booking status
      if (status == 'success') {
        await _updateBookingStatus(bookingId, 'Dibayar');
      } else if (status == 'failed') {
        await _updateBookingStatus(bookingId, 'Pembayaran Gagal');
      }

      if (kDebugMode) {
        print('✅ Payment callback handled: $referenceId -> $status');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error handling payment callback: $e');
      }
      rethrow;
    }
  }

  /// Update booking status after payment
  Future<void> _updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      });
      if (kDebugMode) {
        print('✅ Booking status updated: $bookingId -> $status');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating booking status: $e');
      }
      rethrow;
    }
  }

  /// Verify payment status by calling DOKU API
  /// Use this when webhook doesn't arrive or for manual verification
  Future<bool> verifyPaymentStatus(String referenceId) async {
    try {
      final status = await _paymentService.checkPaymentStatus(referenceId);
      final paymentStatus = status['status'];

      if (paymentStatus == 'SETTLED' || paymentStatus == 'success') {
        // Find and update the payment record
        await handlePaymentCallback(
          referenceId: referenceId,
          status: 'success',
          amount: (status['amount'] as num?)?.toInt() ?? 0,
          metadata: status,
        );
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error verifying payment status: $e');
      }
      rethrow;
    }
  }

  /// Get payment by reference ID
  Future<PaymentModel?> getPaymentByReference(String referenceId) async {
    try {
      final snapshot = await _firestore
          .collection('payments')
          .where('reference_id', isEqualTo: referenceId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return PaymentModel.fromMap({...data, 'id': snapshot.docs.first.id});
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching payment: $e');
    }
  }

  /// Stream payment status updates (for real-time UI updates)
  Stream<PaymentModel?> streamPaymentByReference(String referenceId) {
    return _firestore
        .collection('payments')
        .where('reference_id', isEqualTo: referenceId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return PaymentModel.fromMap({...data, 'id': snapshot.docs.first.id});
      }
      return null;
    });
  }

  /// Stream payment status by booking ID
  Stream<PaymentModel?> streamPaymentByBookingId(String bookingId) {
    return _firestore
        .collection('payments')
        .where('booking_id', isEqualTo: bookingId)
        .orderBy('created_at', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return PaymentModel.fromMap({...data, 'id': snapshot.docs.first.id});
      }
      return null;
    });
  }

  /// Initiate manual payment verification poll
  /// Call this after user completes payment to check status multiple times
  Future<bool> pollPaymentStatus(
    String referenceId, {
    int maxAttempts = 30,
    Duration interval = const Duration(seconds: 2),
  }) async {
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final payment = await getPaymentByReference(referenceId);

        if (payment != null && payment.status == 'success') {
          if (kDebugMode) {
            print('✅ Payment verified after ${attempts + 1} attempts');
          }
          return true;
        }

        attempts++;
        if (attempts < maxAttempts) {
          await Future.delayed(interval);
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Poll attempt $attempts failed: $e');
        }
        attempts++;
        await Future.delayed(interval);
      }
    }

    if (kDebugMode) {
      print('❌ Payment verification timeout after $maxAttempts attempts');
    }
    return false;
  }
}
