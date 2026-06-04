import 'package:flutter/material.dart';
import '../models/notification_model_angga.dart';
import '../services/auth_service.dart';
import '../services/notification_service_angga.dart';
import '../utils/constants.dart';

class NotificationScreenAngga extends StatelessWidget {
  final VoidCallback? onBack;

  const NotificationScreenAngga({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final userId = AuthService().currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Silakan login terlebih dahulu')),
      );
    }

    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColor),
      body: Column(
        children: [
          _buildHeader(context, userId),
          Expanded(
            child: StreamBuilder<List<NotificationModelAngga>>(
              stream: NotificationServiceAngga().getNotificationsStream(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Terjadi kesalahan: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final notifications = snapshot.data ?? [];

                if (notifications.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    return _buildDismissibleNotificationCard(context, notif);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userId) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(28, statusBarHeight + 16, 28, 20),
      decoration: BoxDecoration(
        color: Color(AppConstants.primaryColor),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (onBack != null) {
                    onBack!();
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'Notifikasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () => NotificationServiceAngga().markAllAsRead(userId),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: const Text(
              'Baca Semua',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDismissibleNotificationCard(BuildContext context, NotificationModelAngga notif) {
    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        NotificationServiceAngga().deleteNotification(notif.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifikasi dihapus'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Color(AppConstants.dangerRed),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      child: GestureDetector(
        onTap: () {
          if (!notif.isRead) {
            NotificationServiceAngga().markAsRead(notif.id);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notif.isRead 
                ? Color(AppConstants.cardColor) 
                : Color(AppConstants.primaryColor).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: notif.isRead
                  ? Colors.white
                  : Color(AppConstants.primaryColor).withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: notif.isRead
                      ? Color(AppConstants.accentColor).withValues(alpha: 0.5)
                      : Color(AppConstants.accentColor),
                ),
                child: Icon(
                  notif.title.contains('Sukses') || notif.title.contains('Berhasil') || notif.title.contains('Konfirmasi')
                      ? Icons.check_circle_outline_rounded
                      : notif.title.contains('Batal') || notif.title.contains('Tolak')
                          ? Icons.cancel_outlined
                          : Icons.notifications_none_rounded,
                  color: Color(AppConstants.primaryColor),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w700,
                              color: Color(AppConstants.textDark),
                            ),
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(AppConstants.primaryColor),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notif.body,
                      style: TextStyle(
                        fontSize: 13,
                        color: notif.isRead 
                            ? Color(AppConstants.textLight) 
                            : Color(AppConstants.textDark).withValues(alpha: 0.8),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTimestamp(notif.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(AppConstants.textLight).withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(AppConstants.accentColor).withValues(alpha: 0.5),
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 56,
              color: Color(AppConstants.primaryColor).withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada notifikasi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(AppConstants.textDark),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Anda akan menerima notifikasi di sini saat\nstatus pesanan Anda diperbarui.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(AppConstants.textLight),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else {
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    }
  }
}
