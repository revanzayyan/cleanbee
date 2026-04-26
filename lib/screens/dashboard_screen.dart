import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/custom_bottom_nav.dart';
import '../services/auth_service.dart';
import 'booking_screen.dart';
import 'setting_screen.dart';
import 'chat_screen.dart';
import 'chat_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _bottomNavIndex = 0;

  // Index 0 → Home, Index 1 → Home (Riwayat belum ada), Index 2 → Pesan
  final List<Widget> _screens = [
    const _HomeContent(),
    const _HomeContent(),
    const ChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColor),
      body: IndexedStack(
        index: _bottomNavIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _bottomNavIndex,
        onTap: (index) => setState(() => _bottomNavIndex = index),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HOME CONTENT
// ═══════════════════════════════════════════════════════════════
class _HomeContent extends StatelessWidget {
  const _HomeContent();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi!';
    if (hour < 15) return 'Selamat Siang!';
    if (hour < 18) return 'Selamat Sore!';
    return 'Selamat Malam!';
  }

  String _getUserName() {
    final user = AuthService().currentUser;
    if (user != null) {
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        return user.displayName!;
      }
      if (user.email != null && user.email!.isNotEmpty) {
        return user.email!.split('@')[0];
      }
    }
    return 'Pengguna';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildOrderStatus(),
            const SizedBox(height: 28),
            _buildFeatureSection(context),
            const SizedBox(height: 28),
            _buildReviewSection(),
            const SizedBox(height: 28),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ── Header ──
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
      decoration: BoxDecoration(
        color: Color(AppConstants.primaryColor),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getUserName(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Ikon Pesan
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatScreen()),
                  );
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                            border: Border.all(
                              color: Color(AppConstants.primaryColor),
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              '3',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Ikon Setting
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingScreen()),
                  );
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  child: const Icon(
                    Icons.settings_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Status Pesanan ──
  Widget _buildOrderStatus() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: Color(AppConstants.cardColor),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(AppConstants.accentColor),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.delete_outline_rounded,
                    size: 34,
                    color: Color(AppConstants.primaryColor).withValues(alpha: 0.5),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(AppConstants.primaryColor).withValues(alpha: 0.15),
                        border: Border.all(
                          color: Color(AppConstants.cardColor),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.sentiment_satisfied_alt_rounded,
                        size: 14,
                        color: Color(AppConstants.primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada pesanan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(AppConstants.textDark),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Kamu belum memiliki pesanan cleaning.\nYuk buat sekarang!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(AppConstants.textLight),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Fitur Aplikasi ──
  Widget _buildFeatureSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fitur Aplikasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(AppConstants.textDark),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _featureCard(
                  context,
                  icon: Icons.calendar_month_rounded,
                  label: 'Jadwal',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _featureCard(
                  context,
                  icon: Icons.add_shopping_cart_rounded,
                  label: 'Memesan',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _featureCard(
                  context,
                  icon: Icons.headset_mic_rounded,
                  label: 'CS',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _featureCard(BuildContext context, {required IconData icon, required String label}) {
    return GestureDetector(
      onTap: () {
        if (label == 'Memesan') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BookingScreen()),
          );
        }
        if (label == 'CS') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatDetailScreen(
                name: 'Customer Service',
                isOnline: true,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Color(AppConstants.primaryColor),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(AppConstants.primaryColor).withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Ulasan Pelanggan ──
  Widget _buildReviewSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ulasan Pelanggan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(AppConstants.textDark),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(AppConstants.primaryColor),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(AppConstants.cardColor),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    height: 140,
                    color: Color(AppConstants.accentColor),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.photo_camera_outlined,
                          size: 40,
                          color: Color(AppConstants.primaryColor).withValues(alpha: 0.4),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(AppConstants.primaryColor),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 16),
                                SizedBox(width: 4),
                                Text(
                                  '4.9',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(AppConstants.accentColor),
                      ),
                      child: Icon(Icons.person, size: 18, color: Color(AppConstants.primaryColor)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Revan Zayyan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(AppConstants.textDark),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: List.generate(
                              5,
                              (_) => Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFD700)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '2 hari lalu',
                      style: TextStyle(fontSize: 11, color: Color(AppConstants.textLight)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Kamarnya jadi bersih dan wangi! Petugasnya ramah dan hasilnya sangat memuaskan. Recommended banget!',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(AppConstants.textLight),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}