import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../utils/constants.dart';
import 'payment_qr_screen.dart';
import 'payment_virtual_account_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  final BookingModel booking;
  final double amount;

  const PaymentMethodScreen({
    super.key,
    required this.booking,
    required this.amount,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String? _selectedMethod;

  @override
  void initState() {
    super.initState();
    // Default method so tapping "Lanjutkan" always navigates.
    _selectedMethod = 'qr_code';
  }


  Widget _methodCard({
    required String method,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _selectedMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Color(AppConstants.primaryColor) : Color(AppConstants.inputBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? Color(AppConstants.primaryColor).withValues(alpha: 0.1) : Color(AppConstants.backgroundColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Color(AppConstants.primaryColor), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(AppConstants.textDark))),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(AppConstants.textLight))),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Color(AppConstants.primaryColor), size: 24),
          ],
        ),
      ),
    );
  }

  void _proceedToPayment() {
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih metode pembayaran')),
      );
      return;
    }

    if (_selectedMethod == 'qr_code') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentQrScreen(
            booking: widget.booking,
            amount: widget.amount,
          ),
        ),
      );
    } else if (_selectedMethod == 'virtual_account') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentVirtualAccountScreen(
            booking: widget.booking,
            amount: widget.amount,
          ),
        ),
      );
    }
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
        title: const Text('Pilih Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
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
              Text(
                'Total Pembayaran',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(AppConstants.textLight)),
              ),
              const SizedBox(height: 8),
              Text(
                'Rp ${widget.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(AppConstants.primaryColor)),
              ),
              const SizedBox(height: 28),
              Text(
                'Pilih Metode Pembayaran',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(AppConstants.textDark)),
              ),
              const SizedBox(height: 16),
              _methodCard(
                method: 'qr_code',
                title: 'QR Code',
                description: 'Bayar menggunakan QR code QRIS',
                icon: Icons.qr_code_2,
              ),
              const SizedBox(height: 12),
              _methodCard(
                method: 'virtual_account',
                title: 'Transfer Bank',
                description: 'Bayar melalui nomor rekening virtual',
                icon: Icons.account_balance,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _proceedToPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(AppConstants.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Lanjutkan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(AppConstants.dangerRed),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Batalkan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
