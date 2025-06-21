import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/message/pages/message_detail_screen.dart';
import 'package:frontend/providers/group_provider.dart';
import 'package:frontend/providers/online_users_provider.dart';
import 'package:provider/provider.dart';

class UserMessageBox extends StatelessWidget {
  final String userName;
  final String timestamp;
  final String userImageUrl;
  final String role;
  final String userId;
  final String? roomId;
  final bool hasUnreadMessage;
  // Bỏ lastMessage prop vì sẽ lấy real-time từ provider

  const UserMessageBox({
    Key? key,
    required this.userName,
    required this.timestamp,
    required this.userImageUrl,
    required this.role,
    required this.userId,
    this.roomId,
    this.hasUnreadMessage = false,
  }) : super(key: key);

  void _navigateToMessageScreen(BuildContext context, String userId) {
    if (roomId != null) {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      groupProvider.markGroupAsRead(roomId!);
      groupProvider.markGroupAsReadViaSignalR(roomId!);

      // Mark messages as read for this specific user
      groupProvider.markMessagesAsReadForUser(userId);
    }

    Navigator.of(context).pushNamed(
      MessageDetailScreen.routeName,
      arguments: userId,
    );
  }

  String _getStatusText(bool isOnline, String timestamp) {
    if (isOnline) {
      return 'Online';
    } else {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<OnlineUsersProvider, GroupProvider>(
      builder: (context, onlineUsersProvider, groupProvider, child) {
        final bool isOnline = onlineUsersProvider.isUserOnline(userId);

        // Get unread count for this specific user
        final unreadCount = groupProvider.getUnreadCountForUser(userId);
        final hasUnread = unreadCount > 0 || hasUnreadMessage;

        // Lấy lastMessage real-time từ GroupProvider
        String lastMessage = 'Start a conversation';
        String messageTimestamp = timestamp;

        if (roomId != null) {
          final group = groupProvider.getGroupById(roomId!);
          if (group != null && group.lastMessage != null) {
            lastMessage = group.lastMessage!.content;

            // Kiểm tra nếu có attachment
            if (group.lastMessage!.resources.isNotEmpty) {
              final resourceCount = group.lastMessage!.resources.length;
              if (lastMessage.isEmpty) {
                lastMessage = resourceCount == 1
                    ? '📎 Attachment'
                    : '📎 $resourceCount attachments';
              } else {
                lastMessage = '$lastMessage 📎';
              }
            }

            // Truncate message nếu quá dài
            if (lastMessage.length > 50) {
              lastMessage = '${lastMessage.substring(0, 47)}...';
            }
          } else if (group?.lastMessageAttachment != null) {
            lastMessage = '📎 Attachment';
          }
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _navigateToMessageScreen(context, userId),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: GlobalVariables.green.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Avatar with online status dot
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: GlobalVariables.lightGreen,
                            backgroundImage: userImageUrl.isNotEmpty
                                ? NetworkImage(userImageUrl)
                                : null,
                            child: userImageUrl.isEmpty
                                ? Text(
                                    userName.isNotEmpty
                                        ? userName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        // Online status indicator
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: isOnline
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFF9E9E9E),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isOnline
                                      ? const Color(0xFF4CAF50).withOpacity(0.3)
                                      : Colors.black.withOpacity(0.15),
                                  blurRadius: isOnline ? 6 : 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User name and role badge row
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  userName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: hasUnread
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: hasUnread
                                        ? GlobalVariables.green
                                        : const Color(0xFF1A1A1A),
                                    letterSpacing: -0.1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Role badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      GlobalVariables.green.withOpacity(0.1),
                                      GlobalVariables.lightGreen
                                          .withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        GlobalVariables.green.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  role,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: GlobalVariables.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          // Online/Offline status text với message timestamp
                          Row(
                            children: [
                              Text(
                                _getStatusText(isOnline, timestamp),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isOnline
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFF9E9E9E),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Last message with unread count - Real-time update
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment:
                                CrossAxisAlignment.start, // đã đúng
                            children: [
                              Expanded(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (Widget child,
                                      Animation<double> animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                  layoutBuilder: (Widget? currentChild,
                                      List<Widget> previousChildren) {
                                    return Stack(
                                      alignment: Alignment
                                          .topLeft, // 👈 Căn trái trên cùng
                                      children: [
                                        ...previousChildren,
                                        if (currentChild != null) currentChild,
                                      ],
                                    );
                                  },
                                  child: Text(
                                    lastMessage,
                                    key: ValueKey(lastMessage),
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: hasUnread
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: hasUnread
                                          ? GlobalVariables.green
                                          : const Color(0xFF616161),
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              if (unreadCount > 0)
                                AnimatedScale(
                                  scale: 1.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.red,
                                          Colors.red.withOpacity(0.8)
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      child: Text(
                                        unreadCount > 99
                                            ? '99+'
                                            : unreadCount.toString(),
                                        key: ValueKey(unreadCount),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
