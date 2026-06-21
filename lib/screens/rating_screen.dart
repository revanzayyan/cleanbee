import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import '../models/booking_model.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';
import '../services/booking_service.dart';
import '../services/auth_service.dart';

class RatingScreen extends StatefulWidget {
  final BookingModel order;

  const RatingScreen({super.key, required this.order});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen>
    with SingleTickerProviderStateMixin {
  int _selectedRating = 0;
  bool _isSubmitting = false;
  final TextEditingController _commentController = TextEditingController();
  late AnimationController _animController;
  final List<Animation<double>> _starScales = [];

  final ReviewService _reviewService = ReviewService();
  final BookingService _bookingService = BookingService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    for (int i = 0; i < 5; i++) {
      _starScales.add(
        Tween<double>(begin: 1.0, end: 1.35).animate(
          CurvedAnimation(
            parent: _animController,
            curve: Interval(i * 0.1, 0.5 + i * 0.1, curve: Curves.elasticOut),
          ),
        ),
      );
    }

    // Restore draft jika ada
    if (_reviewService.draftOrderId == widget.order.id &&
        _reviewService.draftRating != null) {
      _selectedRating = _reviewService.draftRating!;
      _commentController.text = _reviewService.draftComment ?? '';
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _onStarTap(int starIndex) {
    setState(() => _selectedRating = starIndex + 1);
    _animController.forward(from: 0);
    HapticFeedback.lightImpact();

    // Simpan draft
    _reviewService.saveDraft(
      orderId: widget.order.id,
      rating: _selectedRating,
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
    );
  }

  Future<void> _onLanjutkan() async {
    if (_selectedRating == 0 || _isSubmitting) return;

    final comment = _commentController.text.trim().isEmpty
        ? null
        : _commentController.text.trim();

    setState(() => _isSubmitting = true);

    try {
      final user = _authService.currentUser;
      final customerName = (user?.displayName?.isNotEmpty == true)
          ? user!.displayName!
          : (user?.email?.split('@').first ?? 'Pelanggan');

      final review = ReviewModel(
        orderId: widget.order.id,
        customerId: user?.uid ?? '',
        customerName: customerName,
        staffId: widget.order.petugasName,
        staffName: widget.order.petugasName,
        rating: _selectedRating,
        comment: comment,
        afterPhotoUrl: widget.order.afterPhotoUrl,
        beforePhotoUrl: widget.order.beforePhotoUrl,
      );

      await _reviewService.addReview(review);
      await _bookingService.completeOrder(widget.order.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Terima kasih atas ulasan Anda! 🌟',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: const Color(AppConstants.primaryColor),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Gagal mengirim ulasan. Coba lagi.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: _onLanjutkan,
                child: const Text('Coba Lagi',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(AppConstants.backgroundColor),
        body: Column(
          children: [
            // ── Header biru gradient ──
            _buildHeader(statusBarHeight),
            // ── Konten utama ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
                child: Column(
                  children: [
                    _buildStarRating(),
                    const SizedBox(height: 32),
                    _buildCommentField(),
                    const SizedBox(height: 40),
                    _buildLanjutkanButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double statusBarHeight) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, statusBarHeight + 16, 20, 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: Color(0x400284C7),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // Back button
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Avatar petugas + badge rating
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5), width: 2),
                ),
                child: const Icon(Icons.person_rounded,
                    color: Colors.white, size: 52),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(AppConstants.primaryColor),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Colors.yellow, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        widget.order.petugasRating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.order.petugasName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              shadows: [
                Shadow(blurRadius: 4, color: Colors.black26, offset: Offset(0, 1))
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Penilaian Cleaning',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating() {
    return Column(
      children: [
        Text(
          _selectedRating == 0
              ? 'Berikan penilaian Anda'
              : _ratingLabel(_selectedRating),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(AppConstants.textDark),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final filled = i < _selectedRating;
            return GestureDetector(
              onTap: () => _onStarTap(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (_, __) {
                    final scale =
                        filled ? _starScales[i].value : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(
                          filled ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: filled
                              ? const Color(0xFFFFD700)
                              : Colors.grey.withValues(alpha: 0.4),
                          size: 44,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Sangat Buruk 😞';
      case 2:
        return 'Kurang Memuaskan 😕';
      case 3:
        return 'Cukup 😐';
      case 4:
        return 'Bagus! 😊';
      case 5:
        return 'Luar Biasa! 🌟';
      default:
        return '';
    }
  }

  Widget _buildCommentField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(AppConstants.inputBorder),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _commentController,
        maxLines: 5,
        minLines: 4,
        onChanged: (_) {
          if (_selectedRating > 0) {
            _reviewService.saveDraft(
              orderId: widget.order.id,
              rating: _selectedRating,
              comment: _commentController.text.trim().isEmpty
                  ? null
                  : _commentController.text.trim(),
            );
          }
        },
        decoration: InputDecoration(
          hintText: 'Tulis Ulasan…',
          hintStyle: TextStyle(
            color: Color(AppConstants.textLight).withValues(alpha: 0.6),
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
        style: TextStyle(
          fontSize: 14,
          color: Color(AppConstants.textDark),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildLanjutkanButton() {
    final isEnabled = _selectedRating > 0 && !_isSubmitting;

    return AnimatedOpacity(
      opacity: isEnabled ? 1.0 : 0.45,
      duration: const Duration(milliseconds: 250),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: isEnabled ? _onLanjutkan : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(AppConstants.primaryColor),
            disabledBackgroundColor: const Color(AppConstants.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: isEnabled ? 4 : 0,
            shadowColor:
                const Color(AppConstants.primaryColor).withValues(alpha: 0.4),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  'Kirim Ulasan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
