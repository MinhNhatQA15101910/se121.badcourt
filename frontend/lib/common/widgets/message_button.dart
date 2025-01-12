import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/message/pages/message_screen.dart';

class MessageButton extends StatelessWidget {
  final String userId;
  final int unreadMessages; // Nhận số tin nhắn chưa đọc từ bên ngoài
  final VoidCallback onMessageButtonPressed; // Callback khi nhấn vào nút

  const MessageButton({
    Key? key,
    required this.userId,
    required this.unreadMessages,
    required this.onMessageButtonPressed, // Thêm tham số này
  }) : super(key: key);

  void _navigateToMessageScreen(BuildContext context) {
    Navigator.of(context)
        .pushNamed(
      MessageScreen.routeName,
      arguments: userId,
    )
        .then((_) {
      // Gọi callback để reset số tin nhắn chưa đọc khi quay lại
      onMessageButtonPressed(); // Reset index và unreadMessages
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: () {
            _navigateToMessageScreen(context);
          },
          iconSize: 24,
          icon: const Icon(
            Icons.message_outlined,
            color: GlobalVariables.white,
          ),
        ),
        if (unreadMessages > 0) // Hiển thị khi có tin nhắn chưa đọc
          Positioned(
            right: 6,
            bottom: 4,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 12,
                minHeight: 12,
              ),
              child: Center(
                child: Text(
                  '$unreadMessages', // Hiển thị số tin nhắn chưa đọc
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
