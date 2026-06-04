import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../utils/constants.dart';
import '../widgets/admin_bottom_nav_angga.dart';
import 'login_screen.dart';
import 'admin_cs_chat_screen_angga.dart';
import 'admin_orders_screen_angga.dart';

class AdminDashboardScreenAngga extends StatefulWidget {
  const AdminDashboardScreenAngga({super.key});

  @override
  State<AdminDashboardScreenAngga> createState() =>
      _AdminDashboardScreenAnggaState();
}

class _AdminDashboardScreenAnggaState extends State<AdminDashboardScreenAngga> {
  int _bottomNavIndex = 0;
  final BookingService _bookingService = BookingService();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi!';
    if (hour < 15) return 'Selamat Siang!';
    if (hour < 18) return 'Selamat Sore!';
    return 'Selamat Malam!';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BookingModel>>(
      stream: _bookingService.getBookingsStream(),
      builder: (context, snapshot) {
        final bookings = snapshot.data ?? [];
        final unverifiedBookings =
            bookings.where((b) => b.status == 'Menunggu Verifikasi').toList();
        final hasUnverified = unverifiedBookings.isNotEmpty;

        return Scaffold(
          backgroundColor: Color(AppConstants.backgroundColor),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildIncomingOrdersSection(unverifiedBookings),
                  const SizedBox(height: 28),
                  _buildReviewSection(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          bottomNavigationBar: AdminBottomNavAngga(
            currentIndex: _bottomNavIndex,
            hasUnverifiedOrders: hasUnverified,
            onTap: (index) {
              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminOrdersScreenAngga()),
                );
              } else if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CsChatListScreenAngga()),
                );
              } else {
                setState(() => _bottomNavIndex = index);
              }
            },
          ),
        );
      },
    );
  }

  // Header Admin
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
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Admin Angga',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_getGreeting()} ☀️',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // Logout Admin
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    child: const Icon(
                      Icons.logout_outlined,
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

  // Pesanan Masuk (Incoming Order)
  Widget _buildIncomingOrdersSection(List<BookingModel> unverifiedBookings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pesanan Masuk',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(AppConstants.textDark),
                ),
              ),
              if (unverifiedBookings.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${unverifiedBookings.length} Pending',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (unverifiedBookings.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36),
              decoration: BoxDecoration(
                color: Color(AppConstants.cardColor),
                borderRadius: BorderRadius.circular(20),
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
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 44,
                    color: Colors.green.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Semua pesanan terverifikasi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(AppConstants.textDark),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tidak ada antrean pesanan baru saat ini.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(AppConstants.textLight),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...unverifiedBookings
              .take(2)
              .map((booking) => _buildOrderCard(booking)),
      ],
    );
  }

  Widget _buildOrderCard(BookingModel booking) {
    return GestureDetector(
      onTap: () => _showFullOrderDetail(booking),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 6),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(AppConstants.cardColor),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(AppConstants.accentColor),
                        ),
                        child:
                            const Icon(Icons.person, color: Colors.blueAccent),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.yellow, size: 10),
                            SizedBox(width: 2),
                            Text(
                              '4.5',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // User Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.userEmail != null
                              ? booking.userEmail!.split('@')[0]
                              : 'Pengguna',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(AppConstants.textDark),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.category,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(AppConstants.textLight),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Label Pesanan Baru
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Pesanan Baru',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              // Illustration & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'WAKTU',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${booking.formattedDate}, ${booking.timeRange}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(AppConstants.textDark),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Klik untuk detail',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(AppConstants.primaryColor),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullOrderDetail(BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Color(AppConstants.backgroundColor),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Detail Pesanan Masuk',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                )
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Detail Pemesan
                    const Text('Detail Pemesan',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
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
                        icon:
                            const Icon(Icons.chat_rounded, color: Colors.blue),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CsChatListScreenAngga()),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    // Komponen Booking
                    const Text('Detail Pekerjaan',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    _buildDetailRow('Kategori', booking.category),
                    _buildDetailRow('Gedung', booking.buildingType),
                    _buildDetailRow('Alamat Detail', booking.fullAddress),
                    _buildDetailRow('Jadwal',
                        '${booking.formattedDate}, ${booking.timeRange}'),
                    const Divider(),
                    const SizedBox(height: 8),
                    // Detail Pembayaran
                    const Text('Detail Pembayaran',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Telah Dibayar (Transfer)',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          TextButton(
                              onPressed: () {},
                              child: const Text('Lihat Bukti')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _bookingService.updateOrderStatusInFirestore(
                          booking.id, 'Dibatalkan');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pesanan ditolak dan dibatalkan.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Tolak',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _bookingService.updateOrderStatusInFirestore(
                          booking.id, 'Diproses');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text(
                              'Pesanan diverifikasi. Notifikasi dikirim ke pelanggan.'),
                          backgroundColor: Colors.green,
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Verifikasi',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 120,
              child: Text(label, style: const TextStyle(color: Colors.grey))),
          const Text(': '),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  // Ulasan Pelanggan
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
                              color: Colors.white,
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
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.favorite,
                                color: Colors.red, size: 16),
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
                          const Text('Alfa Rajel',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(AppConstants.textDark))),
                          const SizedBox(height: 2),
                          Row(
                            children: List.generate(
                                5,
                                (_) => const Icon(Icons.star_rounded,
                                    size: 14, color: Color(0xFFFFD700))),
                          ),
                        ],
                      ),
                    ),
                    Text('2 jam lalu',
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(AppConstants.textLight))),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Mantap sekali pelayanannya, petugas sangat ramah dan ruangan menjadi sangat bersih.',
                  style: TextStyle(
                      fontSize: 13,
                      color: Color(AppConstants.textLight),
                      height: 1.5),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey.withValues(alpha: 0.2)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Balas ulasan...',
                          hintStyle: const TextStyle(fontSize: 13),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
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
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Balasan terkirim')),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Color(AppConstants.primaryColor),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Color(AppConstants.primaryColor)
                            .withValues(alpha: 0.1),
                      ),
                      child: const Text('Kirim',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
