import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import '../widgets/custom_bottom_nav.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';
import '../services/review_service.dart';
import '../models/booking_model.dart';
import '../services/notification_service_angga.dart';
import '../models/review_model.dart';
import 'booking_screen.dart';
import 'chat_detail_screen.dart';
import 'chat_screen.dart';
import 'jadwal_screen.dart';
import 'notification_screen_angga.dart';
import 'rating_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _bottomNavIndex = 0;
  final BookingService _bookingService = BookingService();

  void _goHome() {
    setState(() => _bottomNavIndex = 0);
  }

  void _goToJadwal() {
    setState(() => _bottomNavIndex = 1);
  }

  @override
  void initState() {
    super.initState();
    _bookingService.addListener(_onBookingChanged);
    // Sync current user bookings from Firestore in real-time
    final currentUser = AuthService().currentUser;
    if (currentUser != null) {
      _bookingService.syncUserBookings(currentUser.uid);
    }

    // Mulai dengarkan ulasan dari Firestore
    ReviewService().ensureListening();
  }


  @override
  void dispose() {
    _bookingService.removeListener(_onBookingChanged);
    _bookingService.disposeSync();
    super.dispose();
  }

  void _onBookingChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userId = AuthService().currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: PopScope(
        canPop: _bottomNavIndex == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _goHome();
        },
        child: _getCurrentScreen(),
      ),
      bottomNavigationBar: StreamBuilder<int>(
        stream: NotificationServiceAngga().getUnreadCountStream(userId),
        builder: (context, snapshot) {
          final unreadCount = snapshot.data ?? 0;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              CustomBottomNav(
                currentIndex: _bottomNavIndex,
                hasUnverifiedOrders: unreadCount > 0,
                onTap: (index) {
                  if (index == 2) return;
                  setState(() => _bottomNavIndex = index);
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 22,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BookingScreen()),
                      );
                    },
                    child: Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1A3A6B),
                            Color(0xFF2E6DB4),
                            Color(0xFF5BA3E6)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1A3A6B).withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          const Center(
                              child: Icon(Icons.add_rounded,
                                  color: Colors.white, size: 30)),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              height: 18,
                              width: 18,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4ADE80),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: const Center(
                                  child: Icon(Icons.arrow_upward_rounded,
                                      color: Colors.white, size: 11)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _getCurrentScreen() {
    switch (_bottomNavIndex) {
      case 0:
        return _HomeContent(
            bookingService: _bookingService, onGoToJadwal: _goToJadwal);
      case 1:
        return JadwalScreen(onBack: _goHome);
      case 3:
        return NotificationScreenAngga(onBack: _goHome);
      case 4:
        return ChatScreen(onBack: _goHome);
      default:
        return _HomeContent(
            bookingService: _bookingService, onGoToJadwal: _goToJadwal);
    }
  }
}
// ---------------------------------------------------------
// HOME CONTENT
// ---------------------------------------------------------
class _HomeContent extends StatelessWidget {
  final BookingService bookingService;
  final VoidCallback onGoToJadwal;

  const _HomeContent(
      {required this.bookingService, required this.onGoToJadwal});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi!';
    if (hour < 15) return 'Selamat Siang!';
    if (hour < 18) return 'Selamat Sore!';
    return 'Selamat Malam!';
  }

  String _getUserName() {
    // ✅ FIX: Added try block
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
    final headerHeight = statusBarHeight + 84.0;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: headerHeight,
          collapsedHeight: headerHeight,
          toolbarHeight: 0,
          floating: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          flexibleSpace:
              _buildHeader(context, statusBarHeight, activeOrders.length),
        ),
        SliverToBoxAdapter(child: _buildOrderStatus(context, activeOrders)),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        SliverToBoxAdapter(child: _buildFeatureSection(context)),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        SliverToBoxAdapter(child: _buildReviewSection(context)),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildHeader(
      BuildContext context, double statusBarHeight, int orderCount) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(28, statusBarHeight + 16, 28, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0284C7),
            Color(0xFF38BDF8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getUserName(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: Colors.black26,
                        offset: Offset(0, 1),
                      )
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // ✅ FIX: Use placeholder instead of undefined SettingScreen
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const _SettingScreenPlaceholder()),
            ),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.settings_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatus(
      BuildContext context, List<BookingModel> activeOrders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pesanan Aktif',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(AppConstants.textDark))),
              if (activeOrders.isNotEmpty)
                GestureDetector(
                  onTap: onGoToJadwal,
                  child: Text('Lihat Semua',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(AppConstants.primaryColor))),
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
                        offset: const Offset(0, 2))
                  ]),
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 48,
                      color:
                          Color(AppConstants.textLight).withValues(alpha: 0.4)),
                  const SizedBox(height: 12),
                  Text('Belum ada pesanan aktif',
                      style: TextStyle(
                          fontSize: 14,
                          color: Color(AppConstants.textLight),
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('Pesan sekarang untuk mulai!',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(AppConstants.textLight)
                              .withValues(alpha: 0.7))),
                ],
              ),
            ),
          )
        else
          ...activeOrders.reversed
              .take(3)
              .map((order) => _buildOrderCard(context, order: order)),
      ],
    );
  }

  Widget _buildOrderCard(BuildContext context, {required BookingModel order}) {
    Color statusColor;
    Color statusBgColor;
    switch (order.status) {
      case 'Diproses':
        statusColor = Color(AppConstants.primaryColor);
        statusBgColor = Color(AppConstants.primaryColor).withValues(alpha: 0.1);
        break;
      case 'Petugas Ditugaskan':
        statusColor = Colors.purple;
        statusBgColor = Colors.purple.withValues(alpha: 0.1);
        break;
      case 'Selesai':
        statusColor = Colors.green;
        statusBgColor = Colors.green.withValues(alpha: 0.1);
        break;
      case 'menunggu_konfirmasi':
        statusColor = Colors.orange;
        statusBgColor = Colors.orange.withValues(alpha: 0.1);
        break;
      default:
        statusColor = Colors.orange;
        statusBgColor = Colors.orange.withValues(alpha: 0.1);
    }

    final bool showSelesaiBtn = order.status == 'menunggu_konfirmasi';

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
                    offset: const Offset(0, 4))
              ]),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(alignment: Alignment.bottomCenter, children: [
                    Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(AppConstants.accentColor)),
                        child: Icon(Icons.cleaning_services_rounded,
                            color: Color(AppConstants.primaryColor))),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: Color(AppConstants.primaryColor),
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.star,
                              color: Colors.yellow, size: 10),
                          const SizedBox(width: 2),
                          Text('${order.petugasRating}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold))
                        ])),
                  ]),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(order.category,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(AppConstants.textDark))),
                        const SizedBox(height: 4),
                        Text(order.fullAddress,
                            style: const TextStyle(
                                fontSize: 13,
                                color: Color(AppConstants.textLight)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ])),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                          order.status == 'menunggu_konfirmasi'
                              ? 'Tunggu Konfirmasi'
                              : order.status,
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold))),
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
                          Text('JADWAL',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(AppConstants.primaryColor))),
                          const SizedBox(height: 4),
                          Text('${order.formattedDate}, ${order.timeRange}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(AppConstants.textDark))),
                        ]),
                    if (showSelesaiBtn)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RatingScreen(order: order),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Tulis Ulasan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    else
                      Text('Klik untuk lihat detail',
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(AppConstants.primaryColor),
                              fontWeight: FontWeight.bold)),
                  ]),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetail(BuildContext context, {required BookingModel order}) {
    String headerTitle;
    String headerSubtitle;
    IconData headerIcon;
    Color headerColor;

    switch (order.status) {
      case 'Menunggu Pembayaran':
        headerTitle = 'Menunggu Pembayaran';
        headerSubtitle = 'Silakan selesaikan pembayaran Anda.';
        headerIcon = Icons.payment_rounded;
        headerColor = Colors.orange;
        break;
      case 'Diproses':
        headerTitle = 'Sedang Diproses';
        headerSubtitle = 'Pesanan terkonfirmasi, menunggu petugas ditugaskan.';
        headerIcon = Icons.hourglass_empty_rounded;
        headerColor = Color(AppConstants.primaryColor);
        break;
      case 'Petugas Ditugaskan':
        headerTitle = 'Petugas Ditugaskan';
        headerSubtitle = '${order.petugasName} sedang menuju lokasi kamu.';
        headerIcon = Icons.directions_car_rounded;
        headerColor = Colors.purple;
        break;
      case 'menunggu_konfirmasi':
        headerTitle = 'Pekerjaan Selesai';
        headerSubtitle = 'Silakan konfirmasi & beri ulasan pekerjaan.';
        headerIcon = Icons.clean_hands_rounded;
        headerColor = Colors.green;
        break;
      case 'Selesai':
        headerTitle = 'Pesanan Selesai';
        headerSubtitle = 'Terima kasih telah menggunakan Cleanbee!';
        headerIcon = Icons.check_circle_rounded;
        headerColor = Colors.green;
        break;
      default:
        headerTitle = 'Status: ${order.status}';
        headerSubtitle = '';
        headerIcon = Icons.info_outline;
        headerColor = Colors.grey;
    }

    int getPriceForCategory(String category) {
      switch (category) {
        case 'Kamar Tidur':
          return 50000;
        case 'Kamar Mandi':
          return 40000;
        case 'Kamar Tidur + Kamar Mandi':
          return 85000;
        default:
          return 50000;
      }
    }

    String formatPrice(int price) {
      final str = price.toString();
      if (str.length > 3) {
        return 'Rp ${str.substring(0, str.length - 3)}.${str.substring(str.length - 3)}';
      }
      return 'Rp $str';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Detail Pesanan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close)),
            ]),
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
                          color: headerColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16)),
                      child: Row(children: [
                        Icon(headerIcon, color: headerColor),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(headerTitle,
                                  style: TextStyle(
                                      color: headerColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              const SizedBox(height: 2),
                              Text(headerSubtitle,
                                  style: TextStyle(
                                      color: headerColor.withValues(alpha: 0.7),
                                      fontSize: 13))
                            ]))
                      ])),
                  const SizedBox(height: 20),
                  const Text('Detail Pekerjaan',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  _detailRow('Kategori', order.category),
                  _detailRow('Gedung', order.buildingType),
                  _detailRow('Alamat Detail', order.fullAddress),
                  _detailRow(
                      'Jadwal', '${order.formattedDate}, ${order.timeRange}'),
                  _detailRow('ID Pesanan', order.id),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('Petugas',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                          backgroundColor: Color(AppConstants.accentColor),
                          child: Icon(Icons.person,
                              color: Color(AppConstants.primaryColor))),
                      title: Text(order.petugasName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Petugas Cleaning'),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                            icon: Icon(Icons.chat_rounded,
                                color: Color(AppConstants.primaryColor)),
                            onPressed: () {
                              Navigator.pop(context);
                              // ✅ FIX: Use placeholder
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ChatDetailScreen(
                                            chatId: order.id,
                                            name: order.petugasName,
                                            isOnline: true,
                                          )));
                            }),
                        IconButton(
                            icon: const Icon(Icons.call_rounded,
                                color: Colors.green),
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Menghubungi petugas...')));
                            })
                      ])),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('Detail Pembayaran',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: order.status == 'Menunggu Pembayaran'
                              ? Colors.orange.withValues(alpha: 0.1)
                              : Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16)),
                      child: Row(children: [
                        Icon(
                          order.status == 'Menunggu Pembayaran'
                              ? Icons.hourglass_empty
                              : Icons.check_circle,
                          color: order.status == 'Menunggu Pembayaran'
                              ? Colors.orange
                              : Colors.green,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(
                                order.status == 'Menunggu Pembayaran'
                                    ? 'Menunggu Pembayaran'
                                    : 'Telah Dibayar',
                                style: TextStyle(
                                    color: order.status == 'Menunggu Pembayaran'
                                        ? Colors.orange
                                        : Colors.green,
                                    fontWeight: FontWeight.bold))),
                        Text(
                            formatPrice(getPriceForCategory(order.category)),
                            style: TextStyle(
                                color: order.status == 'Menunggu Pembayaran'
                                    ? Colors.orange
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16))
                      ]))
                ]))),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                // Menunggu Pembayaran => tampil: Bayar + Batalkan
                if (order.status == 'Menunggu Pembayaran')
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 140, maxWidth: 240),
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: implementasi redirect ke payment (invoice_url)
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(AppConstants.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Bayar Sekarang',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                if (order.status == 'Menunggu Pembayaran')
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 140, maxWidth: 240),
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text('Batalkan Pesanan?'),
                            content:
                                const Text('Slot jam akan tersedia kembali.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Tidak'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  if (order.id.isEmpty) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Gagal membatalkan: ID pesanan kosong',
                                          ),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                    }
                                    return;
                                  }
                                  bookingService.cancelOrder(order.id);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Pesanan dibatalkan'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Ya, Batalkan',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: Colors.red.shade400),
                      ),
                      child: Text(
                        'Batalkan',
                        style: TextStyle(
                          color: Colors.red.shade400,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Diproses => tidak ada tombol
                if (order.status == 'Diproses' || order.status == 'Menunggu Diproses')
                  const SizedBox.shrink(),

                // Selesai => tidak ada tombol
                if (order.status == 'Selesai')
                  const SizedBox.shrink(),

                // Menunggu Konfirmasi => tampil: Konfirmasi & Ulas
                if (order.status == 'menunggu_konfirmasi')
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 140, maxWidth: 240),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RatingScreen(order: order),
                          ),
                        );
                      },
                      icon: const Icon(Icons.rate_review_rounded, color: Colors.white),
                      label: const Text(
                        'Konfirmasi & Ulas',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
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
  }

  Widget _detailRow(String label, String value) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 120,
              child: Text(label, style: const TextStyle(color: Colors.grey))),
          const Text(': '),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600)))
        ]));
  }

  Widget _buildFeatureSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fitur Aplikasi',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(AppConstants.textDark))),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _featureCard(context,
                      icon: Icons.calendar_month_rounded, label: 'Jadwal')),
              const SizedBox(width: 12),
              Expanded(
                  child: _featureCard(context,
                      icon: Icons.add_shopping_cart_rounded, label: 'Memesan')),
              const SizedBox(width: 12),
              Expanded(
                  child: _featureCard(context,
                      icon: Icons.headset_mic_rounded, label: 'CS')),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ FIX: Removed unused onTap parameter
  Widget _featureCard(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: () {
        if (label == 'Jadwal') {
          onGoToJadwal();
        } else if (label == 'Memesan') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const BookingScreen()));
        } else if (label == 'CS') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(
                        chatId: 'cs_support',
                        name: 'Customer Service',
                        isOnline: true,
                      )));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
            color: Color(AppConstants.primaryColor),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color:
                      Color(AppConstants.primaryColor).withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ]),
        child: Column(
          children: [
            Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2)),
                child: Icon(icon, color: Colors.white, size: 24)),
            const SizedBox(height: 10),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection(BuildContext context) {
    final reviewService = ReviewService();
    final reviews = reviewService.reviews;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Ulasan Pelanggan',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(AppConstants.textDark))),
            GestureDetector(
                onTap: () {},
                child: Text('Lihat Semua',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(AppConstants.primaryColor)))),
          ]),
          const SizedBox(height: 16),
          if (reviews.isNotEmpty)
            ...reviews.take(3).map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildReviewCard(context, review: r),
                ))
          else
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
                        offset: const Offset(0, 2))
                  ]),
              child: Column(
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                          width: double.infinity,
                          height: 140,
                          color: Color(AppConstants.accentColor),
                          child: Stack(alignment: Alignment.center, children: [
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
                                        borderRadius: BorderRadius.circular(20)),
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
                                                  color: Colors.black87))
                                        ]))),
                            Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle),
                                    child: const Icon(Icons.favorite,
                                        color: Colors.red, size: 16)))
                          ]))),
                  const SizedBox(height: 14),
                  Row(children: [
                    Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(AppConstants.accentColor)),
                        child: Icon(Icons.person,
                            size: 18, color: Color(AppConstants.primaryColor))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          const Text('Revan Zayyan',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(AppConstants.textDark))),
                          const SizedBox(height: 2),
                          Row(
                              children: List.generate(
                                  5,
                                  (_) => const Icon(Icons.star_rounded,
                                      size: 14, color: Color(0xFFFFD700))))
                        ])),
                    Text('2 hari lalu',
                        style: TextStyle(
                            fontSize: 11, color: Color(AppConstants.textLight)))
                  ]),
                  const SizedBox(height: 10),
                  const Text(
                      'Kamarnya jadi bersih dan wangi! Petugasnya ramah dan hasilnya sangat memuaskan. Recommended banget!',
                      style: TextStyle(
                          fontSize: 13,
                          color: Color(AppConstants.textLight),
                          height: 1.5)),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.withValues(alpha: 0.2)),
                  const SizedBox(height: 8),
                  Row(children: [
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
                                            Colors.grey.withValues(alpha: 0.3))),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                        color: Colors.grey
                                            .withValues(alpha: 0.3)))))),
                    const SizedBox(width: 8),
                    TextButton(
                        onPressed: () => ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                                content: Text('Balasan terkirim'))),
                        style: TextButton.styleFrom(
                            foregroundColor: Color(AppConstants.primaryColor),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            backgroundColor: Color(AppConstants.primaryColor)
                                .withValues(alpha: 0.1)),
                        child: const Text('Kirim',
                            style: TextStyle(fontWeight: FontWeight.bold)))
                  ]),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, {required ReviewModel review}) {
    final TextEditingController replyCtrl = TextEditingController();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Color(AppConstants.cardColor),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 2))
          ]),
      child: Column(
        children: [
          // Foto after (atau placeholder)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 140,
              color: Color(AppConstants.accentColor),
              child: review.afterPhotoUrl != null
                  ? Image.network(
                      review.afterPhotoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(Icons.photo_camera_outlined,
                            size: 40,
                            color: Color(AppConstants.primaryColor)
                                .withValues(alpha: 0.4)),
                      ),
                    )
                  : Stack(alignment: Alignment.center, children: [
                      Icon(Icons.photo_camera_outlined,
                          size: 40,
                          color: Color(AppConstants.primaryColor)
                              .withValues(alpha: 0.4)),
                    ]),
            ),
          ),
          // Rating badge overlay (top-right)
          Transform.translate(
            offset: const Offset(0, -8),
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2))
                    ]),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFFFD700), size: 16),
                  const SizedBox(width: 4),
                  Text('${review.rating}.0',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87))
                ]),
              ),
            ),
          ),
          // Avatar + nama + waktu
          Row(children: [
            Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(AppConstants.accentColor)),
                child: Icon(Icons.person,
                    size: 18, color: Color(AppConstants.primaryColor))),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(review.customerName,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(AppConstants.textDark))),
                  const SizedBox(height: 2),
                  Row(
                      children: List.generate(
                          5,
                          (i) => Icon(
                              i < review.rating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 14,
                              color: i < review.rating
                                  ? const Color(0xFFFFD700)
                                  : Colors.grey.withValues(alpha: 0.4))))
                ])),
            Text(review.relativeTime,
                style: TextStyle(
                    fontSize: 11, color: Color(AppConstants.textLight)))
          ]),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(review.comment!,
                  style: const TextStyle(
                      fontSize: 13,
                      color: Color(AppConstants.textLight),
                      height: 1.5)),
            ),
          ],
          const SizedBox(height: 16),
          Divider(color: Colors.grey.withValues(alpha: 0.2)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: TextField(
                    controller: replyCtrl,
                    decoration: InputDecoration(
                        hintText: 'Balas ulasan...',
                        hintStyle: const TextStyle(fontSize: 13),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                                color: Colors.grey.withValues(alpha: 0.3))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                                color:
                                    Colors.grey.withValues(alpha: 0.3)))))),
            const SizedBox(width: 8),
            TextButton(
                onPressed: () {
                  if (replyCtrl.text.trim().isNotEmpty) {
                    ReviewService()
                        .replyToReview(review.id, replyCtrl.text.trim());
                    replyCtrl.clear();
                  }
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Balasan terkirim')));
                },
                style: TextButton.styleFrom(
                    foregroundColor: Color(AppConstants.primaryColor),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    backgroundColor: Color(AppConstants.primaryColor)
                        .withValues(alpha: 0.1)),
                child: const Text('Kirim',
                    style: TextStyle(fontWeight: FontWeight.bold)))
          ]),
        ],
      ),
    );
  }
}


// ✅ Placeholder classes for undefined screens
class _SettingScreenPlaceholder extends StatelessWidget {
  const _SettingScreenPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: const Center(
        child: Text('Halaman Pengaturan',
            style: TextStyle(fontSize: 18, color: Colors.grey)),
      ),
    );
  }
}// test
