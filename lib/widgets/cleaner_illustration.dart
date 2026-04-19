import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CleanerIllustration extends StatelessWidget {
  final double height;

  const CleanerIllustration({super.key, this.height = 280});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lingkaran dekoratif belakang
          Container(
            width: height * 0.85,
            height: height * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(AppConstants.primaryColor).withValues(alpha: 0.08),
            ),
          ),
          Container(
            width: height * 0.65,
            height: height * 0.65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(AppConstants.primaryColor).withValues(alpha: 0.05),
            ),
          ),
          // Ilustrasi cleaner
          _buildCleanerFigure(context),
        ],
      ),
    );
  }

  Widget _buildCleanerFigure(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Badan / Torso
        Container(
          width: 60,
          height: 70,
          decoration: BoxDecoration(
            color: Color(AppConstants.primaryColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.cleaning_services, color: Colors.white, size: 30),
          ),
        ),
        const SizedBox(height: 4),
        // Kepala
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFD4A574),
            shape: BoxShape.circle,
            border: Border.all(
              color: Color(AppConstants.primaryColor),
              width: 2,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Kaki
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 18,
              height: 40,
              decoration: BoxDecoration(
                color: Color(AppConstants.primaryDark),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 18,
              height: 40,
              decoration: BoxDecoration(
                color: Color(AppConstants.primaryDark),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Sapu
        Container(
          width: 8,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF8B6914),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Container(
          width: 40,
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFF8B6914),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}