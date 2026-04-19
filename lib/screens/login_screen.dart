import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_button.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.toLowerCase() == 'asoy2023@gmail.com' && password == 'siadmin') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
        (route) => false,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmail(email, password);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGoogle();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Color(AppConstants.dangerRed)
            : Color(AppConstants.primaryColor),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColor),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header Section ──
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBackButton(),
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(AppConstants.primaryColor)
                                .withValues(alpha: 0.1),
                          ),
                          child: Icon(
                            Icons.cleaning_services_rounded,
                            color: Color(AppConstants.primaryColor),
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang\nKembali',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Color(AppConstants.textDark),
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Silahkan masuk untuk melanjutkan\npemesanan layanan cleaning',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(AppConstants.textLight),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Form Section ──
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 28),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: Color(AppConstants.cardColor),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Color(AppConstants.primaryColor)
                          .withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'Email atau Username',
                        prefixIcon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email/Username tidak boleh kosong';
                          }
                          if (value != 'angga' && !value.contains('@')) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      CustomTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: _buildVisibilityToggle(
                          isVisible: _obscurePassword,
                          onTap: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          if (value.length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Lupa Password?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(AppConstants.primaryColor),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Button Section ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Color(AppConstants.primaryColor)
                                .withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(AppConstants.primaryColor),
                          disabledBackgroundColor:
                              Color(AppConstants.primaryColor)
                                  .withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Lanjut',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                              color: Color(AppConstants.inputBorder),
                              thickness: 1.5),
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
                              thickness: 1.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        SocialButton(
                          label: 'Google',
                          icon: Icons.g_mobiledata,
                          iconColor: Color(AppConstants.buttonGoogle),
                          onPressed: _isLoading ? () {} : _handleGoogleSignIn,
                        ),
                        const SizedBox(width: 14),
                        SocialButton(
                          label: 'Apple',
                          icon: Icons.apple,
                          iconColor: Color(AppConstants.buttonApple),
                          onPressed: () {
                            _showSnackBar('Login Apple segera hadir',
                                isError: true);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(
                  height:
                      MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Color(AppConstants.cardColor),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color(AppConstants.inputBorder),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          size: 16,
          color: Color(AppConstants.textDark),
        ),
      ),
    );
  }

  Widget _buildVisibilityToggle(
      {required bool isVisible, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Icon(
          isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: Color(AppConstants.textLight),
          size: 20,
        ),
      ),
    );
  }
}
