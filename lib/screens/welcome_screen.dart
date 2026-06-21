import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ── Ilustrasi dengan background biru muda ──
                SizedBox(
                  height: 290,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'lib/assets/images/welcome.png',
                        height: 290,
                        fit: BoxFit.contain,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
