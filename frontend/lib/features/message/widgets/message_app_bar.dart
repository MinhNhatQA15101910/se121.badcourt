import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/user.dart';

class MessageAppBar extends StatelessWidget {
  final User? otherUser;
  final bool isConnected;

  const MessageAppBar({
    Key? key,
    required this.otherUser,
    required this.isConnected,
  }) : super(key: key);

  // CẢI TIẾN: Kiểm tra user có online không dựa trên lastOnlineAt
  bool _isUserOnline(DateTime? lastOnlineAt) {
    return lastOnlineAt == null; // null = online, có giá trị = offline
  }

  // CẢI TIẾN: Tính thời gian offline dựa trên lastOnlineAt
  String _getOfflineTimeText(DateTime? lastOnlineAt) {
    if (lastOnlineAt == null) {
      return 'Online'; // User đang online
    }
    
    final now = DateTime.now();
    final difference = now.difference(lastOnlineAt);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'Last seen ${years} year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'Last seen ${months} month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return 'Last seen ${weeks} week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return 'Last seen ${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return 'Last seen ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return 'Last seen ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Last seen just now';
    }
  }

  // CẢI TIẾN: Lấy text hiển thị trạng thái
  String _getStatusText() {
    if (otherUser == null) {
      return 'Unknown status';
    }
    
    final isOnline = _isUserOnline(otherUser!.lastOnlineAt);
    return isOnline ? 'Online' : _getOfflineTimeText(otherUser!.lastOnlineAt);
  }

  @override
  Widget build(BuildContext context) {
    // CẢI TIẾN: Sử dụng lastOnlineAt thay vì OnlineUsersProvider
    final bool isOnline = otherUser != null && _isUserOnline(otherUser!.lastOnlineAt);
    final String statusText = _getStatusText();

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leadingWidth: 40,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              Hero(
                tag: 'avatar-${otherUser?.id ?? "unknown"}',
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: otherUser?.photoUrl != null && otherUser!.photoUrl.isNotEmpty
                      ? NetworkImage(otherUser!.photoUrl) 
                      : null,
                  child: otherUser?.photoUrl == null || otherUser!.photoUrl.isEmpty
                      ? Icon(Icons.person, color: Colors.grey[600], size: 24)
                      : null,
                ),
              ),
              // Online status indicator
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isOnline ? GlobalVariables.green : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isOnline 
                            ? GlobalVariables.green.withOpacity(0.3)
                            : Colors.black.withOpacity(0.15),
                        blurRadius: isOnline ? 4 : 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherUser?.username ?? 'Unknown User',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                // CẢI TIẾN: Hiển thị trạng thái với animation
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Row(
                    key: ValueKey(statusText),
                    children: [
                      Icon(
                        isOnline ? Icons.circle : Icons.access_time,
                        size: 10,
                        color: isOnline ? GlobalVariables.green : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: isOnline ? GlobalVariables.green : Colors.grey[600],
                            fontSize: 12,
                            fontWeight: isOnline ? FontWeight.w500 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Thêm actions nếu cần
      actions: [
        // Connection status indicator
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: Icon(
            isConnected ? Icons.wifi : Icons.wifi_off,
            color: isConnected ? GlobalVariables.green : Colors.red,
            size: 20,
          ),
        ),
      ],
    );
  }
}