import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../services/auth_service.dart';
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
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Color(AppConstants.backgroundColor),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Error loading bookings: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final bookings = snapshot.data ?? [];
        // Only show incoming/unverified bookings (Menunggu Verifikasi or Menunggu Pembayaran)
        final activeBookings = bookings.where((b) => b.status == 'Menunggu Verifikasi' || b.status == 'Menunggu Pembayaran').toList();
        final hasUnverified = bookings.any((b) => b.status == 'Menunggu Verifikasi');

        return Scaffold(
          backgroundColor: Color(AppConstants.backgroundColor),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildIncomingOrdersSection(activeBookings),
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
                      Text(
                        'Admin Angga (${AuthService().currentUser?.email ?? "Unauthenticated"})',
                        style: const TextStyle(
                          fontSize: 14,
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
  Widget _buildIncomingOrdersSection(List<BookingModel> activeBookings) {
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
              if (activeBookings.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${activeBookings.length} Aktif',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (activeBookings.isEmpty)
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
                    'Tidak ada pesanan aktif',
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
          ...activeBookings
              .map((booking) => _buildOrderCard(booking)),
      ],
    );
  }

  Widget _buildOrderCard(BookingModel booking) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 6),
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
          // Header card
          InkWell(
            onTap: () => _showFullOrderDetail(booking),
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
          // Action Buttons
          _buildCardActions(context, booking, _bookingService),
        ],
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
            _buildModalActions(context, booking, _bookingService, context),
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
