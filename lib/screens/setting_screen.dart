import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

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

  String _getUserEmail() {
    final user = AuthService().currentUser;
    if (user?.email != null && user!.email!.isNotEmpty) {
      return user.email!;
    }
    return '-';
  }

  Future<void>_handleLogout(BuildContext context) async {
    Navigator.pop(context);

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Color(AppConstants.primaryColor),
          ),
        ),
      );

      await AuthService().signOut();

      if (!context.mounted) return;
      Navigator.pop(context);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Gagal keluar: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Color(AppConstants.dangerRed),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        ),
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(AppConstants.accentColor),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    size: 30,
                    color: Color(AppConstants.primaryColor),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Apakah anda ingin keluar?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(AppConstants.textDark),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleLogout(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(AppConstants.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Ya',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(AppConstants.accentColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Tidak',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(AppConstants.textDark),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Color(AppConstants.cardColor),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(AppConstants.textDark).withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(AppConstants.accentColor),
              ),
              child: Icon(
                icon,
                size: 22,
                color: Color(AppConstants.primaryColor),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(AppConstants.textDark),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: Color(AppConstants.textLight).withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColor),
      appBar: AppBar(
        backgroundColor: Color(AppConstants.primaryColor),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pengaturan',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header Profil ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
              decoration: BoxDecoration(
                color: Color(AppConstants.primaryColor),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getUserName(),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getUserEmail(),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Menu Items ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  // _menuItem(
                  //   icon: Icons.person_outline_rounded,
                  //   title: 'Akun',
                  //   onTap: () {},
                  // ),
                  // const SizedBox(height: 14),
                  // _menuItem(
                  //   icon: Icons.history_rounded,
                  //   title: 'Riwayatku',
                  //   onTap: () {},
                  // ),
                  // const SizedBox(height: 14),
                  // _menuItem(
                  //   icon: Icons.notifications_none_rounded,
                  //   title: 'Notifikasi',
                  //   onTap: () {},
                  // ),
                  // const SizedBox(height: 14),
                  // _menuItem(
                  //   icon: Icons.help_outline_rounded,
                  //   title: 'Bantuan',
                  //   onTap: () {},
                  // ),
                  const SizedBox(height: 14),
                  _menuItem(
                    icon: Icons.info_outline_rounded,
                    title: 'Tentang Aplikasi',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Tombol Keluar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showLogoutDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(AppConstants.dangerRed).withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: Color(AppConstants.dangerRed).withValues(alpha: 0.85),
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Keluar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(AppConstants.dangerRed).withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}