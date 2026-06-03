import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/booking_model.dart';
import '../services/payment_service.dart';
import '../utils/constants.dart';
import 'payment_verification_screen.dart';

class PaymentQrScreen extends StatefulWidget {
  final BookingModel booking;
  final double amount;

  const PaymentQrScreen({
    super.key,
    required this.booking,
    required this.amount,
  });

  @override
  State<PaymentQrScreen> createState() => _PaymentQrScreenState();
}

class _PaymentQrScreenState extends State<PaymentQrScreen> {
  final _paymentService = DokuPaymentService();
  bool _isLoading = true;
  String? _qrString;
  String? _referenceId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generateQrCode();
  }

  Future<void> _generateQrCode() async {
    try {
      setState(() => _isLoading = true);

      final response = await _paymentService.createQrPayment(
        bookingId: widget.booking.id,
        amount: widget.amount,
        description: '${widget.booking.category} - ${widget.booking.fullAddress}',
        customerId: widget.booking.userUid,
      );

      setState(() {
        _qrString = response.qrString;
        _referenceId = response.referenceId;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat QR: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _proceedToVerification() {
    if (_referenceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reference ID tidak tersedia')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentVerificationScreen(
          referenceId: _referenceId!,
          bookingId: widget.booking.id,
          amount: widget.amount,
        ),
      ),
    ).then((result) {
      if (result == true && mounted) {
        // Payment completed successfully
        Navigator.pop(context, true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppConstants.primaryColor),
      appBar: AppBar(
        backgroundColor: Color(AppConstants.primaryColor),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pembayaran QR Code', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(AppConstants.backgroundColor),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(AppConstants.inputBorder)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(AppConstants.textLight)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp ${widget.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(AppConstants.primaryColor)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // QR Code Section
              if (_isLoading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: Color(AppConstants.primaryColor)),
                        const SizedBox(height: 16),
                        Text(
                          'Membuat QR Code...',
                          style: TextStyle(fontSize: 14, color: Color(AppConstants.textLight)),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Color(AppConstants.dangerRed)),
                        const SizedBox(height: 16),
                        Text(
                          'Gagal membuat QR Code',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(AppConstants.textDark)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Color(AppConstants.textLight)),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _generateQrCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(AppConstants.primaryColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    Text(
                      'Pindai dengan Aplikasi Bank Anda',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(AppConstants.textDark)),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Color(AppConstants.inputBorder)),
                      ),
                      child: _qrString != null
                          ? QrImageView(
                              data: _qrString!,
                              version: QrVersions.auto,
                              size: 200.0,
                              embeddedImage: null,
                            )
                          : const SizedBox(
                              height: 200,
                              child: Center(child: Text('QR Code tidak tersedia')),
                            ),
                    ),
                    const SizedBox(height: 16),
                    if (_referenceId != null)
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reference ID disalin'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(AppConstants.primaryColor).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reference ID',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(AppConstants.textLight)),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _referenceId!,
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(AppConstants.textDark), fontFamily: 'monospace'),
                                  ),
                                  Icon(Icons.copy, size: 16, color: Color(AppConstants.primaryColor)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 28),

              // Instructions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(AppConstants.primaryColor).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(AppConstants.primaryColor).withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cara Pembayaran:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(AppConstants.textDark)),
                    ),
                    const SizedBox(height: 10),
                    ...[
                      '1. Buka aplikasi bank atau e-wallet Anda',
                      '2. Pilih fitur "Pindai QR Code"',
                      '3. Arahkan ke QR code di atas',
                      '4. Ikuti proses pembayaran',
                      '5. Tunggu konfirmasi pembayaran',
                    ].map(
                      (instruction) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          instruction,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(AppConstants.textDark)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading || _errorMessage != null ? null : _proceedToVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(AppConstants.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Lanjut ke Verifikasi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _generateQrCode,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(AppConstants.primaryColor)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('Buat QR Baru', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(AppConstants.primaryColor))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
