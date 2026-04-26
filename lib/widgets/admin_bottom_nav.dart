import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AdminBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool hasUnverifiedOrders;

  const AdminBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.hasUnverifiedOrders = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Color(AppConstants.primaryColor),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(AppConstants.primaryColor).withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            icon: Icons.dashboard_rounded,
            label: 'Home',
            index: 0,
          ),
          _navItem(
            icon: Icons.list_alt_rounded,
            label: 'Pesanan',
            index: 1,
            showBadge: hasUnverifiedOrders,
          ),
          _navItem(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Pesan',
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
    bool showBadge = false,
  }) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive 
              ? Colors.white.withValues(alpha: 0.15) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: Colors.white,
                ),
                if (showBadge)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(AppConstants.primaryColor), width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: Colors.white.withValues(alpha: isActive ? 1.0 : 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
