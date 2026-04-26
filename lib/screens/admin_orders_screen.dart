import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColor),
      appBar: AppBar(
        title: const Text('Pesanan Masuk'),
        backgroundColor: Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Hide back button if used in bottom nav
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildOrderListItem(
            context,
            name: 'Alfa Rajel',
            phone: '089323459587',
            time: '08.00 - 10.00',
            service: 'General Cleaning (2 Jam)',
            isVerified: false,
          ),
          const SizedBox(height: 16),
          _buildOrderListItem(
            context,
            name: 'Budi Santoso',
            phone: '081234567890',
            time: '13.00 - 15.00',
            service: 'Deep Cleaning (4 Jam)',
            isVerified: false,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderListItem(
    BuildContext context, {
    required String name,
    required String phone,
    required String time,
    required String service,
    required bool isVerified,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(AppConstants.textDark),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Menunggu Verifikasi',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(phone, style: TextStyle(color: Color(AppConstants.textLight), fontSize: 13)),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.withValues(alpha: 0.2)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.cleaning_services_rounded, size: 16, color: Color(AppConstants.primaryColor)),
              const SizedBox(width: 8),
              Text(service, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Text(time, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
