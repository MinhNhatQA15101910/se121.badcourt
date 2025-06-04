import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_container.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/message/pages/message_detail_screen.dart';
import 'package:frontend/providers/group_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class UserMessageBox extends StatelessWidget {
  final String userName;
  final String lastMessage;
  final String timestamp;
  final String userImageUrl;
  final String role;
  final String userId;
  final String? roomId; // Thêm roomId để đánh dấu đã đọc
  final bool hasUnreadMessage; // Thêm để hiển thị trạng thái chưa đọc

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
    // Đánh dấu tin nhắn đã đọc khi tap vào
    if (roomId != null) {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      groupProvider.markGroupAsRead(roomId!); // Sửa từ markMessageRoomAsRead thành markGroupAsRead
      groupProvider.markGroupAsReadViaSignalR(roomId!);
    }

    Navigator.of(context).pushNamed(
      MessageDetailScreen.routeName,
      arguments: userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToMessageScreen(context, userId),
      child: CustomContainer(
        child: Container(
          decoration: BoxDecoration(
            color: hasUnreadMessage 
                ? GlobalVariables.lightGreen.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
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
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),
                  // Indicator cho tin nhắn chưa đọc
                  if (hasUnreadMessage)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            userName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: hasUnreadMessage 
                                  ? FontWeight.w700 
                                  : FontWeight.w600,
                              color: hasUnreadMessage 
                                  ? GlobalVariables.darkGreen 
                                  : GlobalVariables.blackGrey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: GlobalVariables.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            role,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: GlobalVariables.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timestamp,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: hasUnreadMessage 
                            ? GlobalVariables.green 
                            : GlobalVariables.darkGrey,
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMessage,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: hasUnreadMessage 
                                  ? FontWeight.w600 
                                  : FontWeight.w400,
                              color: hasUnreadMessage 
                                  ? GlobalVariables.darkGreen 
                                  : GlobalVariables.darkGrey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Badge cho tin nhắn chưa đọc
                        if (hasUnreadMessage)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: GlobalVariables.green,
                              shape: BoxShape.circle,
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
    );
  }
}
