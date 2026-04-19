import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/custom_bottom_nav.dart';
import '../services/auth_service.dart';
import 'booking_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _bottomNavIndex = 0;

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
      // 1. Coba ambil displayName (Biasanya terisi dari Login Google)
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        return user.displayName!;
      }

      // 2. Jika tidak ada displayName, ambil email lalu potong bagian "@..."
      if (user.email != null && user.email!.isNotEmpty) {
        return user.email!.split('@')[0];
      }
    }

    // 3. Fallback jika tidak ada data sama sekali
    return 'Pengguna';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColor),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildOrderStatus(),
              const SizedBox(height: 28),
              _buildFeatureSection(),
              const SizedBox(height: 28),
              _buildReviewSection(),
              const SizedBox(height: 28),
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
      // ── Panggil CustomBottomNav di sini ──
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _bottomNavIndex,
        onTap: (index) => setState(() => _bottomNavIndex = index),
      ),
    );
  }

  // header
  Widget _buildHeader() {
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
      child: SafeArea(
        top: false,
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
                // ── Ikon Setting ──
                GestureDetector(
                  onTap: () {
                    // TODO: Navigasi ke halaman Setting
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
      ),
    );
  }

// status pesanan
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
                    color:
                        Color(AppConstants.primaryColor).withValues(alpha: 0.5),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(AppConstants.primaryColor)
                            .withValues(alpha: 0.15),
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

// fitur aplikasi
  Widget _buildFeatureSection() {
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
                      icon: Icons.calendar_month_rounded, label: 'Jadwal')),
              const SizedBox(width: 12),
              Expanded(
                  child: _featureCard(
                      icon: Icons.add_shopping_cart_rounded, label: 'Memesan')),
              const SizedBox(width: 12),
              Expanded(
                  child: _featureCard(
                      icon: Icons.headset_mic_rounded, label: 'CS')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _featureCard({required IconData icon, required String label}) {
    return GestureDetector(
      onTap: () {
        if (label == 'Memesan') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BookingScreen(),
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

// ulasan pelanggan
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
                          color: Color(AppConstants.primaryColor)
                              .withValues(alpha: 0.4),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(AppConstants.primaryColor),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded,
                                    color: Color(0xFFFFD700), size: 16),
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
                      child: Icon(Icons.person,
                          size: 18, color: Color(AppConstants.primaryColor)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Ahmad Fauzi',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(AppConstants.textDark))),
                          const SizedBox(height: 2),
                          Row(
                            children: List.generate(
                                5,
                                (_) => Icon(Icons.star_rounded,
                                    size: 14, color: Color(0xFFFFD700))),
                          ),
                        ],
                      ),
                    ),
                    Text('2 hari lalu',
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(AppConstants.textLight))),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Kamarnya jadi bersih dan wangi! Petugasnya ramah dan hasilnya sangat memuaskan. Recommended banget!',
                  style: TextStyle(
                      fontSize: 13,
                      color: Color(AppConstants.textLight),
                      height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
