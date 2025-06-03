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
          padding: const EdgeInsets.all(8),
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
                          child: _customText(
                            userName,
                            14,
                            hasUnreadMessage 
                                ? FontWeight.w700 
                                : FontWeight.w600,
                            hasUnreadMessage 
                                ? GlobalVariables.darkGreen 
                                : GlobalVariables.blackGrey,
                            1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _customText(
                          role,
                          12,
                          FontWeight.w500,
                          GlobalVariables.green,
                          1,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    _customText(
                      timestamp,
                      10,
                      FontWeight.w400,
                      hasUnreadMessage 
                          ? GlobalVariables.green 
                          : GlobalVariables.darkGrey,
                      1,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: _customText(
                            lastMessage.isNotEmpty 
                                ? lastMessage 
                                : 'No messages yet',
                            12,
                            hasUnreadMessage 
                                ? FontWeight.w600 
                                : FontWeight.w400,
                            hasUnreadMessage 
                                ? GlobalVariables.darkGreen 
                                : GlobalVariables.darkGrey,
                            1,
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

  Widget _customText(
      String text, double size, FontWeight weight, Color color, int maxLines) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: color,
        fontSize: size,
        fontWeight: weight,
      ),
    );
  }
}
