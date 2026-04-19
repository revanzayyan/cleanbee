import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      // Tidak ada margin agar menempel sempurna di bawah
      decoration: BoxDecoration(
        color: Color(AppConstants.primaryColor), // Background solid biru
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24), // Sudut membulat hanya di atas
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(AppConstants.primaryColor).withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, -4), // Shadow ke atas
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            icon: Icons.history_rounded,
            label: 'Riwayat',
            index: 0,
          ),
          _navItem(
            icon: Icons.notifications_outlined,
            label: 'Notifikasi',
            index: 1,
          ),
          _navItem(
            icon: Icons.chat_bubble_outline_rounded, // Ikon chat untuk "Pesan"
            label: 'Pesan',                         // Sesuai gambar
            index: 2,
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          // Efek aktif: lingkaran putih transparan di belakang item
          color: isActive 
              ? Colors.white.withValues(alpha: 0.15) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: Colors.white, // Ikon selalu putih
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                // Teks aktif putih solid, tidak aktif putih sedikit transparan
                color: Colors.white.withValues(alpha: isActive ? 1.0 : 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}