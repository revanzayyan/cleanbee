import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/payment_service.dart';
import '../utils/constants.dart';
import 'payment_verification_screen.dart';

class PaymentVirtualAccountScreen extends StatefulWidget {
  final BookingModel booking;
  final double amount;

  const PaymentVirtualAccountScreen({
    super.key,
    required this.booking,
    required this.amount,
  });

  @override
  State<PaymentVirtualAccountScreen> createState() => _PaymentVirtualAccountScreenState();
}

class _PaymentVirtualAccountScreenState extends State<PaymentVirtualAccountScreen> {
  final _paymentService = DokuPaymentService();
  bool _isLoading = true;
  String? _virtualAccountNumber;
  String? _selectedBank = 'BCA';
  String? _referenceId;
  String? _errorMessage;

  final Map<String, String> _bankCodes = {
    'BCA': 'BCA',
    'Mandiri': 'MANDIRI',
    'BNI': 'BNI',
    'Permata': 'PERMATA',
  };

  @override
  void initState() {
    super.initState();
    _generateVirtualAccount();
  }

  Future<void> _generateVirtualAccount() async {
    try {
      setState(() => _isLoading = true);

      final response = await _paymentService.createVirtualAccount(
        bookingId: widget.booking.id,
        amount: widget.amount,
        description: '${widget.booking.category} - ${widget.booking.fullAddress}',
        bankCode: _bankCodes[_selectedBank] ?? 'BCA',
        customerId: widget.booking.userUid,
        customerName: widget.booking.userEmail ?? 'Customer',
      );

      setState(() {
        _virtualAccountNumber = response.virtualAccountNumber;
        _referenceId = response.referenceId;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat VA: $e')),
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

  Widget _bankOption(String name, String code) {
    final isSelected = _selectedBank == name;
    return GestureDetector(
      onTap: _isLoading
          ? null
          : () {
              setState(() => _selectedBank = name);
              _generateVirtualAccount();
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Color(AppConstants.primaryColor) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Color(AppConstants.primaryColor) : Color(AppConstants.inputBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          name,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : Color(AppConstants.textDark),
          ),
        ),
      ),
    );
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
        title: const Text('Pembayaran Transfer Bank', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
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
              const SizedBox(height: 24),

              // Bank Selection
              Text(
                'Pilih Bank',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(AppConstants.textDark)),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _bankCodes.keys.map((bank) => _bankOption(bank, _bankCodes[bank]!)).toList(),
              ),
              const SizedBox(height: 28),

              // Virtual Account Section
              if (_isLoading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: Color(AppConstants.primaryColor)),
                        const SizedBox(height: 16),
                        Text(
                          'Membuat Nomor Rekening Virtual...',
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
                          'Gagal membuat Rekening Virtual',
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
                          onPressed: _generateVirtualAccount,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nomor Rekening Virtual',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(AppConstants.textDark)),
                    ),
                    const SizedBox(height: 12),
                    if (_virtualAccountNumber != null)
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Nomor Rekening disalin')),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Color(AppConstants.inputBorder)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$_selectedBank Virtual Account',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(AppConstants.textLight)),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _virtualAccountNumber!,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'monospace'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(Icons.copy, size: 18, color: Color(AppConstants.primaryColor)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (_referenceId != null)
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reference ID disalin')),
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
                      '1. Salin nomor rekening virtual di atas',
                      '2. Buka aplikasi mobile banking Anda',
                      '3. Pilih menu "Transfer" atau "Pembayaran"',
                      '4. Masukkan nomor rekening virtual',
                      '5. Masukkan jumlah Rp ${widget.amount.toStringAsFixed(0)}',
                      '6. Lakukan konfirmasi dan pembayaran',
                      '7. Transaksi selesai, status akan diperbarui otomatis',
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
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFE69C)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 18, color: const Color(0xFFF39C12)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Nomor rekening virtual berlaku 24 jam. Pastikan transfer sesuai jumlah yang ditentukan.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF8B6F00)),
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
                  onPressed: _generateVirtualAccount,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(AppConstants.primaryColor)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('Buat VA Baru', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(AppConstants.primaryColor))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
