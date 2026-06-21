import 'package:flutter/material.dart';

import '../services/chat_service.dart';
import '../utils/constants.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const ChatScreen({super.key, this.onBack});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).padding.top + 62),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            28,
            MediaQuery.of(context).padding.top + 4,
            28,
            16,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0284C7),
                Color(0xFF38BDF8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (widget.onBack != null) {
                      widget.onBack!();
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
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 12),
            color: const Color(0xFFF8FAFC),
          ),
          Expanded(
            child: StreamBuilder<List<ChatConversation>>(
              stream: _chatService.listenToChatList(),
              builder: (context, snapshot) {
                final chats = snapshot.data ?? [];

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (chats.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada pesan',
                      style: TextStyle(color: Colors.black54),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: chats.length,
                  separatorBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Divider(
                      height: 1,
                      color: Color(AppConstants.inputBorder)
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  itemBuilder: (context, index) {
                    return _chatTile(context, chat: chats[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatTile(BuildContext context, {required ChatConversation chat}) {
    final isUnread = chat.unreadAdmin > 0;

    final dateLabel = chat.lastMessageTime == null
        ? ''
        : '${chat.lastMessageTime!.toDate().day}/${chat.lastMessageTime!.toDate().month}';

    return GestureDetector(
      onTap: () async {
final chatId = await _chatService.startOrGetChat(chat.chatId);

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              chatId: chatId,
              name: chat.userName,
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
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFBFEFFF),
              ),
              child: const Icon(Icons.person, color: Color(0xFF0284C7)),
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
                        chat.userName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isUnread ? FontWeight.w700 : FontWeight.w600,
                          color: Color(AppConstants.textDark),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        dateLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isUnread ? FontWeight.w700 : FontWeight.w500,
                          color: isUnread
                              ? Color(AppConstants.primaryColor)
                              : Color(AppConstants.textLight)
                                  .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
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
                      color: Color(AppConstants.primaryColor)
                          .withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '${chat.unreadAdmin}',
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

