import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/custom_bottom_nav.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';
import 'booking_screen.dart';
import 'setting_screen.dart';
import 'chat_screen.dart';
import 'chat_detail_screen.dart';
import 'jadwal_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _bottomNavIndex = -1;
  final BookingService _bookingService = BookingService();

  bool get _hasActiveOrder => _bookingService.getActiveOrders().isNotEmpty;

  void _goHome() {
    setState(() => _bottomNavIndex = -1);
  }

  @override
  void initState() {
    super.initState();
    _bookingService.addListener(_onBookingChanged);
  }

  @override
  void dispose() {
    _bookingService.removeListener(_onBookingChanged);
    super.dispose();
  }

  void _onBookingChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PopScope(
        canPop: _bottomNavIndex == -1,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _goHome();
        },
        child: _getCurrentScreen(),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _bottomNavIndex,
        hasUnverifiedOrders: _hasActiveOrder,
        onTap: (index) {
          if (index == 2) {
            setState(() => _bottomNavIndex = 2);
          }
        },
      ),
    );
  }

  Widget _getCurrentScreen() {
    switch (_bottomNavIndex) {
      case 2:
        return ChatScreen(onBack: _goHome);
      default:
        return _HomeContent(bookingService: _bookingService);
    }
  }
}

class _HomeContent extends StatelessWidget {
  final BookingService bookingService;

  const _HomeContent({required this.bookingService});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi!';
    if (hour < 15) return 'Selamat Siang!';
    if (hour < 18) return 'Selamat Sore!';
    return 'Selamat Malam!';
  }

  String _getUserName() {
    try {
      final user = AuthService().currentUser;
      if (user != null) {
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          return user.displayName!;
        }
        if (user.email != null && user.email!.isNotEmpty) {
          return user.email!.split('@')[0];
        }
      }
    } catch (e) {
      debugPrint('Error getting user: $e');
    }
    return 'Pengguna';
  }

  @override
  Widget build(BuildContext context) {
    final activeOrders = bookingService.getActiveOrders();
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    // Hitung tinggi header: statusBar + paddingTop(16) + tinggi avatar(48) + paddingBottom(24)
    final headerHeight = statusBarHeight + 88.0;

    return CustomScrollView(
      slivers: [
        // ── HEADER: Sticky (Ditempel di atas) ──
        SliverAppBar(
          pinned: true, // Membuat header sticky
          expandedHeight: headerHeight,
          toolbarHeight: headerHeight, // Samakan agar tidak bisa di-collapse
          primary: false, // Kita handle safe area status bar manual di dalam widget
          backgroundColor: Color(AppConstants.primaryColor),
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: _buildHeader(context, statusBarHeight, activeOrders.length),
        ),

        // ── PESANAN AKTIF ──
        SliverToBoxAdapter(
          child: _buildOrderStatus(context, activeOrders),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 28)),

        // ── FITUR APLIKASI ──
        SliverToBoxAdapter(
          child: _buildFeatureSection(context),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 28)),

        // ── ULASAN PELANGGAN ──
        SliverToBoxAdapter(
          child: _buildReviewSection(context),
        ),

        // Spacer bawah agar tidak ketutupan bottom nav
        const SliverToBoxAdapter(child: SizedBox(height: 90)),
      ],
    );
  }

  // ─── HEADER ────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, double statusBarHeight, int orderCount) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(28, statusBarHeight + 16, 28, 24),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4), width: 1.5),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getUserName(),
                  style: const TextStyle(
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
                      color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingScreen()),
            ),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              child: const Icon(Icons.settings_outlined,
                  color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  // ─── PESANAN AKTIF ─────────────────────────────────────────

  Widget _buildOrderStatus(
      BuildContext context, List<BookingOrder> activeOrders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pesanan Aktif',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(AppConstants.textDark),
                ),
              ),
              if (activeOrders.isNotEmpty)
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const JadwalScreen()),
                  ),
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
        ),
        const SizedBox(height: 16),
        if (activeOrders.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
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
                  Icon(Icons.inbox_outlined,
                      size: 48,
                      color: Color(AppConstants.textLight)
                          .withValues(alpha: 0.4)),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada pesanan aktif',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(AppConstants.textLight),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pesan sekarang untuk mulai!',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          Color(AppConstants.textLight).withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...activeOrders.reversed.take(3).map((order) {
            return _buildOrderCard(context, order: order);
          }),
      ],
    );
  }

  Widget _buildOrderCard(BuildContext context, {required BookingOrder order}) {
    Color statusColor;
    Color statusBgColor;

    switch (order.status) {
      case 'Diproses':
        statusColor = Color(AppConstants.primaryColor);
        statusBgColor =
            Color(AppConstants.primaryColor).withValues(alpha: 0.1);
        break;
      case 'Selesai':
        statusColor = Colors.green;
        statusBgColor = Colors.green.withValues(alpha: 0.1);
        break;
      default:
        statusColor = Colors.orange;
        statusBgColor = Colors.orange.withValues(alpha: 0.1);
    }

    return GestureDetector(
      onTap: () => _showOrderDetail(context, order: order),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 28, right: 28),
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
                        child: Icon(Icons.cleaning_services_rounded,
                            color: Color(AppConstants.primaryColor)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Color(AppConstants.primaryColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.yellow, size: 10),
                            const SizedBox(width: 2),
                            Text(
                              '${order.petugasRating}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
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
                          order.category,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(AppConstants.textDark),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.fullAddress,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(AppConstants.textLight),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'JADWAL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(AppConstants.primaryColor),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.formattedDate}, ${order.timeRange}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(AppConstants.textDark),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Klik untuk lihat detail',
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

  // ─── DETAIL BOTTOM SHEET ───────────────────────────────────

  void _showOrderDetail(BuildContext context, {required BookingOrder order}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Detail Pesanan',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(AppConstants.primaryColor)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.hourglass_top_rounded,
                              color: Color(AppConstants.primaryColor)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sedang Diproses',
                                    style: TextStyle(
                                        color: Color(
                                            AppConstants.primaryColor),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                const SizedBox(height: 2),
                                Text(
                                    'Petugas sedang menuju lokasi kamu',
                                    style: TextStyle(
                                        color: Color(
                                            AppConstants.primaryColor)
                                            .withValues(alpha: 0.7),
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Detail Pekerjaan',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    _detailRow('Kategori', order.category),
                    _detailRow('Gedung', order.buildingType),
                    _detailRow('Alamat Detail', order.fullAddress),
                    _detailRow('Jadwal',
                        '${order.formattedDate}, ${order.timeRange}'),
                    _detailRow('ID Pesanan', order.id),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text('Petugas',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Color(AppConstants.accentColor),
                        child: Icon(Icons.person,
                            color: Color(AppConstants.primaryColor)),
                      ),
                      title: Text(order.petugasName,
                          style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Petugas Cleaning'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.chat_rounded,
                                color: Color(AppConstants.primaryColor)),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatDetailScreen(
                                    name: order.petugasName,
                                    isOnline: true,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.call_rounded,
                                color: Colors.green),
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Menghubungi petugas...')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text('Detail Pembayaran',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text('Telah Dibayar',
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Text('Rp 35.000',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                if (order.status != 'Selesai')
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            title: const Text('Batalkan Pesanan?'),
                            content: const Text(
                                'Slot jam akan tersedia kembali.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Tidak'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  bookingService.cancelOrder(order.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Pesanan dibatalkan'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                },
                                child: Text('Ya, Batalkan',
                                    style: TextStyle(
                                        color: Colors.red.shade400,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(color: Colors.red.shade400),
                      ),
                      child: Text('Batalkan',
                          style: TextStyle(
                              color: Colors.red.shade400,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (order.status != 'Selesai') const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Membuka live tracking...'),
                          backgroundColor:
                              Color(AppConstants.primaryColor),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppConstants.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Lacak Pesanan',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 120,
              child:
                  Text(label, style: const TextStyle(color: Colors.grey))),
          const Text(': '),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  // ─── FITUR APLIKASI ────────────────────────────────────────

  Widget _buildFeatureSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fitur Aplikasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(AppConstants.textDark),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _featureCard(context,
                    icon: Icons.calendar_month_rounded, label: 'Jadwal'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _featureCard(context,
                    icon: Icons.add_shopping_cart_rounded,
                    label: 'Memesan'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _featureCard(context,
                    icon: Icons.headset_mic_rounded, label: 'CS'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _featureCard(BuildContext context,
      {required IconData icon, required String label}) {
    return GestureDetector(
      onTap: () {
        if (label == 'Jadwal') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const JadwalScreen()),
          );
        } else if (label == 'Memesan') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BookingScreen()),
          );
        } else if (label == 'CS') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatDetailScreen(
                  name: 'Customer Service', isOnline: true),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Color(AppConstants.primaryColor),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(AppConstants.primaryColor)
                  .withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── ULASAN PELANGGAN ──────────────────────────────────────

  Widget _buildReviewSection(BuildContext context) {
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
                        Icon(Icons.photo_camera_outlined,
                            size: 40,
                            color: Color(AppConstants.primaryColor)
                                .withValues(alpha: 0.4)),
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
                                Text('4.9',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87)),
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
                              color: Colors.white, shape: BoxShape.circle,
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
                          size: 18,
                          color: Color(AppConstants.primaryColor)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Revan Zayyan',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Color(AppConstants.textDark))),
                          const SizedBox(height: 2),
                          Row(
                            children: List.generate(
                              5,
                              (_) => const Icon(Icons.star_rounded,
                                  size: 14, color: Color(0xFFFFD700)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text('2 hari lalu',
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(AppConstants.textLight))),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Kamarnya jadi bersih dan wangi! Petugasnya ramah dan hasilnya sangat memuaskan. Recommended banget!',
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
                                color:
                                    Colors.grey.withValues(alpha: 0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                                color:
                                    Colors.grey.withValues(alpha: 0.3)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Balasan terkirim')),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor:
                            Color(AppConstants.primaryColor),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Color(AppConstants.primaryColor)
                            .withValues(alpha: 0.1),
                      ),
                      child: const Text('Kirim',
                          style:
                              TextStyle(fontWeight: FontWeight.bold)),
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