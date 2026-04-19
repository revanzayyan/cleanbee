import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/social_button.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColor),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ── Ilustrasi dengan background biru muda ──
                Container(
                  height: 290,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(AppConstants.accentColor), // Biru sangat muda
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Lingkaran dekoratif atas kanan
                      Positioned(
                        top: -30,
                        right: -20,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(AppConstants.primaryLight)
                                .withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      // Lingkaran dekoratif bawah kiri
                      Positioned(
                        bottom: -20,
                        left: -10,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(AppConstants.primaryLight)
                                .withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      // Lingkaran dekoratif kecil
                      Positioned(
                        top: 20,
                        left: 20,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(AppConstants.primaryLight)
                                .withValues(alpha: 0.3),
                          ),
                        ),
                      ),

                      // ── GANTI dengan ilustrasi asli ──
                      // Image.asset(
                      //   'assets/images/welcome_illustration.png',
                      //   height: 240,
                      //   fit: BoxFit.contain,
                      // ),

                      // Placeholder sementara
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(AppConstants.primaryColor)
                                  .withValues(alpha: 0.15),
                            ),
                            child: Icon(
                              Icons.cleaning_services_rounded,
                              size: 70,
                              color: Color(AppConstants.primaryColor)
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tambahkan ilustrasi',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(AppConstants.textLight),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Judul ──
                const Text(
                  'Selamat Datang di Cleaning \n Service Asrama Telkom',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(AppConstants.textDark),
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 10),

                // ── Subtitle ──
                const Text(
                  'Bersih, Rapi, dan Nyaman\nUntuk Kenyamananmu',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(AppConstants.textLight),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                // ── Button Daftar (Biru muda) ──
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppConstants.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      shadowColor: Color(AppConstants.primaryColor)
                          .withValues(alpha: 0.25),
                    ),
                    child: const Text(
                      'Daftar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ── Button Masuk (Putih, border biru) ──
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Color(AppConstants.cardColor),
                      side: const BorderSide(
                        color: Color(AppConstants.primaryColor),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(AppConstants.primaryColor),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                // ── Divider "Atau lewat email" ──
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Color(AppConstants.inputBorder),
                        thickness: 1.5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'Atau lewat email',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(AppConstants.textLight)
                              .withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Color(AppConstants.inputBorder),
                        thickness: 1.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ── Social Buttons (Putih, border biru pucat) ──
                Row(
                  children: [
                    SocialButton(
                      label: 'Google',
                      icon: Icons.g_mobiledata,
                      iconColor: Color(AppConstants.buttonGoogle),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 14),
                    SocialButton(
                      label: 'Apple',
                      icon: Icons.apple,
                      iconColor: Color(AppConstants.buttonApple),
                      onPressed: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}