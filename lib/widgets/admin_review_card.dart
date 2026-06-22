import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';
import '../utils/constants.dart';

/// Kartu ulasan pelanggan untuk halaman admin.
/// Menampilkan info ulasan dan kolom balas (atau balasan yang sudah dikirim).
class AdminReviewCard extends StatefulWidget {
  final ReviewModel review;

  const AdminReviewCard({super.key, required this.review});

  @override
  State<AdminReviewCard> createState() => _AdminReviewCardState();
}

class _AdminReviewCardState extends State<AdminReviewCard> {
  final TextEditingController _replyController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    final reply = _replyController.text.trim();
    if (reply.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    try {
      await ReviewService().replyToReview(widget.review.id, reply);
      if (!mounted) return;
      _replyController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text('Balasan terkirim!',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          backgroundColor: const Color(AppConstants.primaryColor),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal mengirim balasan. Coba lagi.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final hasReply = review.adminReply != null && review.adminReply!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Baris atas: Avatar + Nama + Waktu ──
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(AppConstants.accentColor),
                  ),
                  child: Center(
                    child: Text(
                      review.customerName.isNotEmpty
                          ? review.customerName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(AppConstants.primaryColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.customerName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(AppConstants.textDark),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          // Bintang rating
                          ...List.generate(
                            5,
                            (i) => Icon(
                              i < review.rating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 13,
                              color: i < review.rating
                                  ? const Color(0xFFFFD700)
                                  : Colors.grey.withValues(alpha: 0.4),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${review.rating}/5',
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
                ),
                Text(
                  review.relativeTime,
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(AppConstants.textLight),
                  ),
                ),
              ],
            ),

            // ── Info petugas ──
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(AppConstants.accentColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cleaning_services_rounded,
                      size: 12, color: Color(AppConstants.primaryColor)),
                  const SizedBox(width: 5),
                  Text(
                    'Petugas: ${review.staffName}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(AppConstants.primaryColor),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // ── Komentar ──
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                review.comment!,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(AppConstants.textLight),
                  height: 1.5,
                ),
              ),
            ],

            // ── Foto before/after (jika ada) ──
            if (review.beforePhotoUrl != null ||
                review.afterPhotoUrl != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (review.beforePhotoUrl != null)
                    Expanded(
                        child: _PhotoThumbnail(
                            url: review.beforePhotoUrl!, label: 'Sebelum')),
                  if (review.beforePhotoUrl != null &&
                      review.afterPhotoUrl != null)
                    const SizedBox(width: 8),
                  if (review.afterPhotoUrl != null)
                    Expanded(
                        child: _PhotoThumbnail(
                            url: review.afterPhotoUrl!, label: 'Sesudah')),
                ],
              ),
            ],

            const SizedBox(height: 14),
            Divider(color: Colors.grey.withValues(alpha: 0.2)),
            const SizedBox(height: 10),

            // ── Area Balasan ──
            if (hasReply) ...[
              // Tampilkan balasan yang sudah ada
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(AppConstants.accentColor),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(AppConstants.primaryColor)
                        .withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.admin_panel_settings_rounded,
                      size: 16,
                      color: Color(AppConstants.primaryColor),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Balasan Admin',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(AppConstants.primaryColor),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            review.adminReply!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(AppConstants.textDark),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Tombol edit balasan
              GestureDetector(
                onTap: () {
                  _replyController.text = review.adminReply!;
                  setState(() {});
                },
                child: Text(
                  'Edit balasan',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(AppConstants.primaryColor),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ] else ...[
              // Kolom input balasan baru
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyController,
                      minLines: 1,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Tulis balasan untuk ulasan ini...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Color(AppConstants.textLight)
                              .withValues(alpha: 0.6),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                              color: Color(AppConstants.primaryColor),
                              width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _sendReply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(AppConstants.primaryColor),
                        disabledBackgroundColor:
                            const Color(AppConstants.primaryColor)
                                .withValues(alpha: 0.5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: _isSending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Kirim',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Thumbnail foto (before/after) dengan label di atas.
class _PhotoThumbnail extends StatelessWidget {
  final String url;
  final String label;

  const _PhotoThumbnail({required this.url, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(AppConstants.textLight),
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            url,
            height: 90,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 90,
              color: const Color(AppConstants.accentColor),
              child: Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color:
                      const Color(AppConstants.primaryColor).withValues(alpha: 0.4),
                ),
              ),
            ),
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Container(
                height: 90,
                color: const Color(AppConstants.accentColor),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
