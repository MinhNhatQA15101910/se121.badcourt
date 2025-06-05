import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/message/pages/message_detail_screen.dart';
import 'package:frontend/providers/group_provider.dart';
import 'package:frontend/providers/online_users_provider.dart';
import 'package:provider/provider.dart';

class UserMessageBox extends StatelessWidget {
  final String userName;
  final String lastMessage;
  final String timestamp;
  final String userImageUrl;
  final String role;
  final String userId;
  final String? roomId;
  final bool hasUnreadMessage;

  const UserMessageBox({
    Key? key,
    required this.userName,
    required this.lastMessage,
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
    return Consumer<OnlineUsersProvider>(
      builder: (context, onlineUsersProvider, child) {
        final bool isOnline = onlineUsersProvider.isUserOnline(userId);
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // Giảm margin vertical
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _navigateToMessageScreen(context, userId),
              borderRadius: BorderRadius.circular(12), // Giảm border radius
              child: Container(
                decoration: BoxDecoration(
                  color: hasUnreadMessage 
                      ? GlobalVariables.lightGreen.withOpacity(0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasUnreadMessage 
                        ? GlobalVariables.green.withOpacity(0.3) // Viền xanh nếu chưa đọc
                        : const Color(0xFFE0E0E0), // Viền xám nếu đã đọc
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(12), // Giảm padding từ 16 xuống 12
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
                                color: Colors.black.withOpacity(0.08), // Giảm shadow
                                blurRadius: 6, // Giảm blur
                                offset: const Offset(0, 1), // Giảm offset
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 24, // Giảm từ 30 xuống 24
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
                                      fontSize: 16, // Giảm font size
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        // Online status indicator
                        Positioned(
                          right: 1,
                          bottom: 1,
                          child: Container(
                            width: 14, // Giảm từ 16 xuống 14
                            height: 14,
                            decoration: BoxDecoration(
                              color: isOnline ? const Color(0xFF4CAF50) : const Color(0xFF9E9E9E),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2, // Giảm border width
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12), // Giảm spacing
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
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600, // Luôn cố định
                                    color: Color(0xFF1A1A1A), // Luôn cố định màu đen
                                    letterSpacing: -0.1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Role badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), // Giảm padding
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      GlobalVariables.green.withOpacity(0.1),
                                      GlobalVariables.lightGreen.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12), // Giảm border radius
                                  border: Border.all(
                                    color: GlobalVariables.green.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  role,
                                  style: TextStyle(
                                    fontSize: 11, // Giảm từ 12 xuống 11
                                    fontWeight: FontWeight.w600,
                                    color: GlobalVariables.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3), // Giảm spacing
                          // Online/Offline status text
                          Text(
                            _getStatusText(isOnline, timestamp),
                            style: TextStyle(
                              fontSize: 12, // Giảm từ 13 xuống 12
                              fontWeight: FontWeight.w500,
                              color: isOnline 
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFF9E9E9E),
                            ),
                          ),
                          const SizedBox(height: 4), // Giảm spacing
                          // Last message
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  lastMessage,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400, // Luôn cố định
                                    color: hasUnreadMessage 
                                        ? GlobalVariables.green // Màu xanh nếu chưa đọc
                                        : const Color(0xFF616161), // Màu xám nếu đã đọc
                                    height: 1.2,
                                  ),
                                  maxLines: 1, // Giảm từ 2 xuống 1 line
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Unread indicator dot
                              if (hasUnreadMessage)
                                Container(
                                  margin: const EdgeInsets.only(left: 8), // Giảm margin
                                  width: 8, // Giảm size
                                  height: 8,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        GlobalVariables.green,
                                        GlobalVariables.green.withOpacity(0.8),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: GlobalVariables.green.withOpacity(0.3),
                                        blurRadius: 3, // Giảm blur
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
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
