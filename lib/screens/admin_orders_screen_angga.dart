import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../utils/constants.dart';
import 'admin_cs_chat_screen_angga.dart';

class AdminOrdersScreenAngga extends StatelessWidget {
  const AdminOrdersScreenAngga({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingService bookingService = BookingService();

    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColor),
      appBar: AppBar(
        title: const Text(
          'Pesanan Masuk',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: bookingService.getBookingsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final bookings = snapshot.data ?? [];
          final pendingBookings = bookings
              .where((b) => b.status == 'Menunggu Verifikasi')
              .toList();

          if (pendingBookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withValues(alpha: 0.1),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 56,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Semua pesanan terverifikasi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(AppConstants.textDark),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tidak ada antrean pesanan baru saat ini.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(AppConstants.textLight),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            itemCount: pendingBookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final booking = pendingBookings[index];
              return _buildOrderCard(context, booking, bookingService);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    BookingModel booking,
    BookingService bookingService,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header ──
          InkWell(
            onTap: () => _showFullOrderDetail(context, booking, bookingService),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(AppConstants.accentColor),
                        ),
                        child: Icon(
                          Icons.person,
                          color: Color(AppConstants.primaryColor),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.userEmail != null
                                  ? booking.userEmail!.split('@')[0]
                                  : 'Pengguna',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(AppConstants.textDark),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              booking.userEmail ?? '-',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(AppConstants.textLight),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Pending',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(height: 1, color: Colors.grey.withValues(alpha: 0.15)),
                  const SizedBox(height: 12),
                  // Detail info
                  _infoRow(
                    icon: Icons.cleaning_services_rounded,
                    iconColor: Color(AppConstants.primaryColor),
                    text: booking.category,
                  ),
                  const SizedBox(height: 8),
                  _infoRow(
                    icon: Icons.location_on_outlined,
                    iconColor: Colors.deepOrange,
                    text: booking.fullAddress,
                  ),
                  const SizedBox(height: 8),
                  _infoRow(
                    icon: Icons.schedule_rounded,
                    iconColor: Colors.blue,
                    text: '${booking.formattedDate}  •  ${booking.timeRange}',
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Tap untuk detail lengkap →',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(AppConstants.primaryColor).withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Action Buttons ──
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            decoration: BoxDecoration(
              color: Color(AppConstants.backgroundColor),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleReject(context, booking, bookingService),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Tolak', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.red.withValues(alpha: 0.6)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleVerify(context, booking, bookingService),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Verifikasi', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({required IconData icon, required Color iconColor, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(AppConstants.textDark),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleVerify(
    BuildContext context,
    BookingModel booking,
    BookingService bookingService,
  ) async {
    await bookingService.updateOrderStatusInFirestore(booking.id, 'Diproses');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(child: Text('Pesanan diverifikasi! Notifikasi terkirim ke pelanggan.')),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _handleReject(
    BuildContext context,
    BookingModel booking,
    BookingService bookingService,
  ) async {
    // Confirm before reject
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tolak Pesanan?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Pesanan dari ${booking.userEmail ?? "pengguna"} akan dibatalkan dan pelanggan akan mendapat notifikasi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: TextStyle(color: Color(AppConstants.textLight))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Ya, Tolak', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await bookingService.updateOrderStatusInFirestore(booking.id, 'Dibatalkan');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.cancel_outlined, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Expanded(child: Text('Pesanan ditolak dan notifikasi terkirim.')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _showFullOrderDetail(
    BuildContext context,
    BookingModel booking,
    BookingService bookingService,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.85,
        decoration: BoxDecoration(
          color: Color(AppConstants.backgroundColor),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Detail Pesanan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close),
                )
              ],
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Detail Pemesan
                    _sectionLabel('Detail Pemesan'),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Color(AppConstants.accentColor),
                        child: const Icon(Icons.person, color: Colors.blue),
                      ),
                      title: Text(
                        booking.userEmail != null
                            ? booking.userEmail!.split('@')[0]
                            : 'Pengguna',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(booking.userEmail ?? 'No Email'),
                      trailing: IconButton(
                        icon: const Icon(Icons.chat_rounded, color: Colors.blue),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CsChatListScreenAngga(),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 24),
                    _sectionLabel('Detail Pekerjaan'),
                    const SizedBox(height: 10),
                    _buildDetailRow('Kategori', booking.category),
                    _buildDetailRow('Gedung', booking.buildingType),
                    _buildDetailRow('Alamat', booking.fullAddress),
                    _buildDetailRow('Tanggal', booking.formattedDate),
                    _buildDetailRow('Jam', booking.timeRange),
                    const Divider(height: 24),
                    _sectionLabel('Status Pembayaran'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Telah Dibayar (Transfer)',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Lihat Bukti',
                              style: TextStyle(color: Color(AppConstants.primaryColor)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            // Action buttons inside bottom sheet too
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _handleReject(context, booking, bookingService);
                    },
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Tolak', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _handleVerify(context, booking, bookingService);
                    },
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Verifikasi', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          const Text(': ', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
