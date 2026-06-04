import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool hasUnverifiedOrders;
  final VoidCallback? onAddTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.hasUnverifiedOrders = false,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home
          _navItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Home',
            index: 0,
          ),
          // Riwayat
          _navItem(
            icon: Icons.access_time_rounded,
            label: 'Jadwal',
            index: 1,
          ),
          // Spacer untuk button Add di tengah
          const SizedBox(width: 16),
          // Notifikasi
          _navItem(
            icon: Icons.notifications_outlined,
            label: 'Notifikasi',
            index: 3,
            showBadge: hasUnverifiedOrders,
          ),
          // Pesan
          _navItem(
            icon: Icons.message_outlined,
            label: 'Pesan',
            index: 4,
          ),
        ],
      ),
    );
  }

  /// Item navigasi biasa
  Widget _navItem({
    required IconData icon,
    IconData? activeIcon,
    required String label,
    required int index,
    bool showBadge = false,
  }) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isActive)
            Container(
              height: 3,
              width: 24,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: Color(AppConstants.primaryColor),
                borderRadius: BorderRadius.circular(2),
              ),
            )
          else
            const SizedBox(height: 7),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                isActive ? (activeIcon ?? icon) : icon,
                size: 22,
                color: isActive
                    ? Color(AppConstants.primaryColor)
                    : Colors.grey,
              ),
              if (showBadge)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive
                  ? Color(AppConstants.primaryColor)
                  : Colors.grey,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}