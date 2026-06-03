import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/payment_callback_handler.dart';

class PaymentVerificationScreen extends StatefulWidget {
  final String referenceId;
  final String bookingId;
  final double amount;

  const PaymentVerificationScreen({
    super.key,
    required this.referenceId,
    required this.bookingId,
    required this.amount,
  });

  @override
  State<PaymentVerificationScreen> createState() => _PaymentVerificationScreenState();
}

class _PaymentVerificationScreenState extends State<PaymentVerificationScreen> {
  final _callbackHandler = PaymentCallbackHandler();
  bool _isVerifying = true;
  bool _paymentSuccessful = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startVerification();
  }

  Future<void> _startVerification() async {
    try {
      // Start polling for payment status (max 30 attempts, 2 seconds apart)
      final isSuccess = await _callbackHandler.pollPaymentStatus(
        widget.referenceId,
        maxAttempts: 30,
        interval: const Duration(seconds: 2),
      );

      if (!mounted) return;

      if (isSuccess) {
        // Payment verified successfully
        setState(() {
          _isVerifying = false;
          _paymentSuccessful = true;
        });
      } else {
        // Check one more time via API
        try {
          final verified = await _callbackHandler.verifyPaymentStatus(widget.referenceId);
          if (!mounted) return;

          final payment = await _callbackHandler.getPaymentByReference(widget.referenceId);
          setState(() {
            _isVerifying = false;
            _paymentSuccessful = verified || (payment?.status == 'success');
          });
        } catch (e) {
          if (!mounted) return;
          setState(() {
            _isVerifying = false;
            _paymentSuccessful = false;
            _errorMessage = 'Verifikasi pembayaran sedang diproses. Silakan tunggu atau periksa status nanti.';
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _retryVerification() {
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });
    _startVerification();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isVerifying,
      child: Scaffold(
        backgroundColor: Color(AppConstants.primaryColor),
        appBar: AppBar(
          backgroundColor: Color(AppConstants.primaryColor),
          elevation: 0,
          automaticallyImplyLeading: !_isVerifying,
          title: const Text('Verifikasi Pembayaran', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(AppConstants.backgroundColor),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_isVerifying)
                  _buildVerifyingState()
                else if (_paymentSuccessful)
                  _buildSuccessState()
                else
                  _buildFailureState(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyingState() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Color(AppConstants.primaryColor).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: Color(AppConstants.primaryColor),
                strokeWidth: 3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Memverifikasi Pembayaran',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(AppConstants.textDark),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Silakan tunggu, kami sedang memeriksa status pembayaran Anda...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(AppConstants.textLight),
          ),
        ),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F4F8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(AppConstants.primaryColor).withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detail Pembayaran',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(AppConstants.textLight),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Jumlah',
                    style: TextStyle(fontSize: 12, color: Color(AppConstants.textLight)),
                  ),
                  Text(
                    'Rp ${widget.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(AppConstants.textDark)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reference',
                    style: TextStyle(fontSize: 12, color: Color(AppConstants.textLight)),
                  ),
                  Text(
                    widget.referenceId,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFD4EDDA),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.check_circle,
              size: 48,
              color: const Color(0xFF28A745),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Pembayaran Berhasil!',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(AppConstants.textDark),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Transaksi Anda telah dikonfirmasi. Terima kasih!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(AppConstants.textLight),
          ),
        ),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFD4EDDA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFC3E6CB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detail Transaksi',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF155724),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Status',
                    style: TextStyle(fontSize: 12, color: const Color(0xFF155724)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF28A745),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Berhasil',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Jumlah',
                    style: TextStyle(fontSize: 12, color: const Color(0xFF155724)),
                  ),
                  Text(
                    'Rp ${widget.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF155724)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppConstants.primaryColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Selesai', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  Widget _buildFailureState() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFF8D7DA),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: Color(AppConstants.dangerRed),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _errorMessage != null ? 'Verifikasi Tertunda' : 'Pembayaran Gagal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(AppConstants.textDark),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _errorMessage ?? 'Sepertinya ada masalah saat memverifikasi pembayaran Anda. Silakan coba lagi.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(AppConstants.textLight),
          ),
        ),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8D7DA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF5C6CB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informasi',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF721C24),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '• Sistem sedang memverifikasi pembayaran Anda\n• Cek email atau dashboard untuk update\n• Hubungi customer service jika ada kendala',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF721C24), height: 1.6),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _retryVerification,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppConstants.primaryColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Periksa Lagi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Color(AppConstants.primaryColor)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text('Kembali', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(AppConstants.primaryColor))),
          ),
        ),
      ],
    );
  }
}
