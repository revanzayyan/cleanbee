import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const ChatScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),

          // ── Header Pesan Saya ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 12),
            color: Color(AppConstants.primaryColor).withValues(alpha: 0.08),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pesan Saya',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(AppConstants.primaryColor),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),

          // ── Daftar Chat ──
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _chatList.length,
              separatorBuilder: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Divider(
                  height: 1,
                  color: Color(AppConstants.inputBorder).withValues(alpha: 0.5),
                ),
              ),
              itemBuilder: (context, index) {
                final chat = _chatList[index];
                return _chatTile(context, chat: chat);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            'Pesan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatTile(BuildContext context, {required ChatModel chat}) {
    final isUnread = chat.unreadCount > 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              name: chat.name,
              avatarUrl: chat.avatarUrl,
              isOnline: chat.isOnline,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        color: isUnread
            ? Color(AppConstants.primaryColor).withValues(alpha: 0.04)
            : Colors.transparent,
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(AppConstants.accentColor),
                    image: chat.avatarUrl != null
                        ? DecorationImage(
                            image: NetworkImage(chat.avatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    border: Border.all(
                      color: chat.isOnline
                          ? Color(AppConstants.primaryColor)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: chat.avatarUrl == null
                      ? Icon(
                          Icons.person,
                          size: 26,
                          color: Color(AppConstants.primaryColor),
                        )
                      : null,
                ),
                if (chat.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF22C55E),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                          color: Color(AppConstants.textDark),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        chat.date,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                          color: isUnread
                              ? Color(AppConstants.primaryColor)
                              : Color(AppConstants.textLight).withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (chat.isFromMe)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.reply_rounded,
                            size: 14,
                            color: Color(AppConstants.textLight).withValues(alpha: 0.5),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.subdirectory_arrow_right_rounded,
                            size: 14,
                            color: Color(AppConstants.textLight).withValues(alpha: 0.5),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                            color: isUnread
                                ? Color(AppConstants.textDark)
                                : Color(AppConstants.textLight),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (isUnread)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(AppConstants.primaryColor),
                  boxShadow: [
                    BoxShadow(
                      color: Color(AppConstants.primaryColor).withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '${chat.unreadCount}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ChatModel {
  final String name;
  final String lastMessage;
  final String date;
  final String? avatarUrl;
  final bool isOnline;
  final bool isFromMe;
  final int unreadCount;

  const ChatModel({
    required this.name,
    required this.lastMessage,
    required this.date,
    this.avatarUrl,
    this.isOnline = false,
    this.isFromMe = false,
    this.unreadCount = 0,
  });
}

final List<ChatModel> _chatList = [
  const ChatModel(
    name: 'Raska',
    lastMessage: 'Menuju lokasi !',
    date: '17/04',
    isOnline: true,
    unreadCount: 2,
  ),
  const ChatModel(
    name: 'Rajel',
    lastMessage: 'Kamar sudah selesai kak',
    date: '20/03',
    unreadCount: 0,
  ),
  const ChatModel(
    name: 'Dimas Pratama',
    lastMessage: 'Siap, besok jam 10 ya',
    date: '18/02',
    isFromMe: true,
    unreadCount: 0,
  ),
  const ChatModel(
    name: 'Sinta',
    lastMessage: 'Terima kasih kak!',
    date: '30/01',
    unreadCount: 1,
  ),
  const ChatModel(
    name: 'Budi Santoso',
    lastMessage: 'Boleh minta reschedule?',
    date: '15/01',
    isFromMe: true,
    unreadCount: 0,
  ),
];