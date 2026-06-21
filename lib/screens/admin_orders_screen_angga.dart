import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../services/auth_service.dart';
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pesanan Kebersihan',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            Text(
              'Auth: ${bookingService.orders.isNotEmpty ? "Has orders" : "No orders"} | User: ${AuthService().currentUser?.email ?? "NONE"} (${AuthService().currentUser?.uid ?? "NONE"})',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: Colors.white70),
            ),
          ],
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
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Error loading bookings: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final bookings = snapshot.data ?? [];
          final activeBookings = bookings.where((b) => b.status != 'Dibatalkan').toList();

          if (activeBookings.isEmpty) {
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
                    'Tidak Ada Pesanan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(AppConstants.textDark),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            itemCount: activeBookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final booking = activeBookings[index];
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
                      _buildStatusBadge(booking.status),
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
          _buildCardActions(context, booking, bookingService),
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
            _buildModalActions(context, booking, bookingService, ctx),
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

  // ── Helper Widgets & Dialogs ──

  Widget _buildStatusBadge(String status) {
    Color color;
    Color bgColor;
    String label;

    switch (status) {
      case 'Menunggu Verifikasi':
        color = Colors.orange;
        bgColor = Colors.orange.withValues(alpha: 0.12);
        label = 'Pending';
        break;
      case 'Diproses':
        color = Colors.blue;
        bgColor = Colors.blue.withValues(alpha: 0.12);
        label = 'Terkonfirmasi';
        break;
      case 'Petugas Ditugaskan':
        color = Colors.purple;
        bgColor = Colors.purple.withValues(alpha: 0.12);
        label = 'Dikerjakan';
        break;
      case 'menunggu_konfirmasi':
        color = Colors.deepOrange;
        bgColor = Colors.deepOrange.withValues(alpha: 0.12);
        label = 'Tunggu Ulasan';
        break;
      case 'Selesai':
        color = Colors.green;
        bgColor = Colors.green.withValues(alpha: 0.12);
        label = 'Selesai';
        break;
      case 'Dibatalkan':
        color = Colors.red;
        bgColor = Colors.red.withValues(alpha: 0.12);
        label = 'Dibatalkan';
        break;
      default:
        color = Colors.grey;
        bgColor = Colors.grey.withValues(alpha: 0.12);
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCardActions(
    BuildContext context,
    BookingModel booking,
    BookingService bookingService,
  ) {
    if (booking.status == 'Menunggu Verifikasi') {
      return Container(
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
      );
    } else if (booking.status == 'Diproses') {
      return Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        decoration: BoxDecoration(
          color: Color(AppConstants.backgroundColor),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showAssignPetugasDialog(context, booking, bookingService),
            icon: const Icon(Icons.person_add_rounded, size: 16),
            label: const Text('Tugaskan Petugas', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      );
    } else if (booking.status == 'Petugas Ditugaskan') {
      return Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        decoration: BoxDecoration(
          color: Color(AppConstants.backgroundColor),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _handleMarkDone(context, booking, bookingService),
            icon: const Icon(Icons.check_circle_rounded, size: 16),
            label: const Text('Pesanan Selesai', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        decoration: BoxDecoration(
          color: Color(AppConstants.backgroundColor),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              booking.status == 'Selesai' ? Icons.check_circle : Icons.hourglass_empty,
              color: booking.status == 'Selesai' ? Colors.green : Colors.orange,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              booking.status == 'Selesai' ? 'Pesanan Selesai & Dinilai' : 'Menunggu Ulasan Pelanggan',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: booking.status == 'Selesai' ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildModalActions(
    BuildContext context,
    BookingModel booking,
    BookingService bookingService,
    BuildContext dialogContext,
  ) {
    if (booking.status == 'Menunggu Verifikasi') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                Navigator.pop(dialogContext);
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
                Navigator.pop(dialogContext);
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
      );
    } else if (booking.status == 'Diproses') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            Navigator.pop(dialogContext);
            await _showAssignPetugasDialog(context, booking, bookingService);
          },
          icon: const Icon(Icons.person_add_rounded, size: 16),
          label: const Text('Tugaskan Petugas', style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );
    } else if (booking.status == 'Petugas Ditugaskan') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            Navigator.pop(dialogContext);
            await _handleMarkDone(context, booking, bookingService);
          },
          icon: const Icon(Icons.check_circle_rounded, size: 16),
          label: const Text('Pesanan Selesai', style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: TextButton.icon(
          onPressed: () => Navigator.pop(dialogContext),
          icon: Icon(
            booking.status == 'Selesai' ? Icons.check_circle : Icons.hourglass_empty,
            color: booking.status == 'Selesai' ? Colors.green : Colors.orange,
          ),
          label: Text(
            booking.status == 'Selesai' ? 'Pesanan Selesai & Dinilai' : 'Menunggu Ulasan Pelanggan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: booking.status == 'Selesai' ? Colors.green : Colors.orange,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: (booking.status == 'Selesai' ? Colors.green : Colors.orange).withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );
    }
  }

  Future<void> _showAssignPetugasDialog(
    BuildContext context,
    BookingModel booking,
    BookingService bookingService,
  ) async {
    final cleaners = ['Raska', 'Rajel', 'Sari Dewi', 'Dimas Pratama', 'Sinta'];
    String selectedCleaner = cleaners[0];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Tugaskan Petugas', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pilih petugas yang akan dikirim untuk pesanan ini:'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCleaner,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                    ),
                    items: cleaners.map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c, style: const TextStyle(fontWeight: FontWeight.w600)),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedCleaner = val;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('Batal', style: TextStyle(color: Color(AppConstants.textLight))),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(AppConstants.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Tugaskan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
        );
      }
    );

    if (confirmed == true) {
      await bookingService.assignPetugas(booking.id, selectedCleaner);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('Petugas $selectedCleaner berhasil ditugaskan!')),
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
  }

  Future<void> _handleMarkDone(
    BuildContext context,
    BookingModel booking,
    BookingService bookingService,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Pesanan Selesai?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Konfirmasi bahwa petugas telah menyelesaikan pekerjaan ini. Status akan diubah ke menunggu ulasan pelanggan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: TextStyle(color: Color(AppConstants.textLight))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Ya, Selesai', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await bookingService.markOrderDone(booking.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Expanded(child: Text('Pesanan ditandai selesai! Menunggu konfirmasi & ulasan dari pelanggan.')),
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
  }
}
