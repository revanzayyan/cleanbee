import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import '../models/booking_model.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';
import '../services/booking_service.dart';
import '../services/auth_service.dart';

class BeforeAfterScreen extends StatefulWidget {
  final BookingModel order;
  final int rating;
  final String? comment;

  const BeforeAfterScreen({
    super.key,
    required this.order,
    required this.rating,
    this.comment,
  });

  @override
  State<BeforeAfterScreen> createState() => _BeforeAfterScreenState();
}

class _BeforeAfterScreenState extends State<BeforeAfterScreen> {
  bool _isSubmitting = false;
  final ReviewService _reviewService = ReviewService();
  final BookingService _bookingService = BookingService();
  final AuthService _authService = AuthService();

  bool get _hasPhotos =>
      widget.order.beforePhotoUrl != null &&
      widget.order.afterPhotoUrl != null;

  Future<void> _onKonfirmasi() async {
    if (!_hasPhotos || _isSubmitting) return;
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
        staffId: widget.order.petugasName, // pakai nama sebagai ID sementara
        staffName: widget.order.petugasName,
        rating: widget.rating,
        comment: widget.comment,
        afterPhotoUrl: widget.order.afterPhotoUrl,
        beforePhotoUrl: widget.order.beforePhotoUrl,
      );

      // Simpan ulasan ke Firestore
      await _reviewService.addReview(review);

      // Ubah status pesanan ke Selesai
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );

      // Kembali ke Home (pop semua screen review)
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
                onPressed: _onKonfirmasi,
                child: const Text('Coba Lagi',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
            _buildHeader(statusBarHeight),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info petugas & rating ringkas
                    _buildInfoCard(),
                    const SizedBox(height: 24),
                    // Foto Sebelum
                    _buildPhotoLabel('Sebelum'),
                    const SizedBox(height: 10),
                    _buildPhotoCard(widget.order.beforePhotoUrl),
                    const SizedBox(height: 20),
                    // Foto Sesudah
                    _buildPhotoLabel('Sesudah'),
                    const SizedBox(height: 10),
                    _buildPhotoCard(widget.order.afterPhotoUrl),
                    if (!_hasPhotos) ...[
                      const SizedBox(height: 16),
                      _buildWaitingPhotosNotice(),
                    ],
                    const SizedBox(height: 32),
                    _buildKonfirmasiButton(),
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
      padding: EdgeInsets.fromLTRB(20, statusBarHeight + 16, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Color(0x400284C7),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Tombol back
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
          const Expanded(
            child: Center(
              child: Text(
                'Hasil Pekerjaan',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Tombol Report (stub)
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Fitur report akan segera hadir.'),
                  backgroundColor: Colors.orange.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4), width: 1),
              ),
              child: const Text(
                'Report',
                style: TextStyle(
                  color: Color(0xFFFF6B6B),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(AppConstants.accentColor),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 28,
                  color: Color(AppConstants.primaryColor),
                ),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(AppConstants.primaryColor),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Colors.yellow, size: 10),
                      const SizedBox(width: 2),
                      Text(
                        widget.order.petugasRating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.order.petugasName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(AppConstants.textDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.order.timeRange,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(AppConstants.textLight),
                  ),
                ),
              ],
            ),
          ),
          // Rating yang sudah dipilih
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < widget.rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: i < widget.rating
                        ? const Color(0xFFFFD700)
                        : Colors.grey.withValues(alpha: 0.3),
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${widget.rating}/5',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(AppConstants.textLight),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(AppConstants.primaryColor),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(AppConstants.textDark),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoCard(String? photoUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 200,
        color: const Color(AppConstants.accentColor),
        child: photoUrl != null
            ? Image.network(
                photoUrl,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: const Color(AppConstants.primaryColor),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image_outlined,
                        size: 36,
                        color: Color(AppConstants.primaryColor)
                            .withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gagal memuat foto',
                        style: TextStyle(
                          color: Color(AppConstants.textLight),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_camera_outlined,
                      size: 40,
                      color: Color(AppConstants.primaryColor)
                          .withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Foto belum tersedia',
                      style: TextStyle(
                        color: Color(AppConstants.textLight),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildWaitingPhotosNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Colors.orange.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: Colors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Menunggu petugas mengunggah foto hasil pekerjaan',
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKonfirmasiButton() {
    final isEnabled = _hasPhotos && !_isSubmitting;

    return AnimatedOpacity(
      opacity: isEnabled ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 250),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: isEnabled ? _onKonfirmasi : null,
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
                  'Konfirmasi',
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
