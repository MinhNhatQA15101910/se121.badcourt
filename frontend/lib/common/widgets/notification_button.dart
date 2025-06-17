import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/notification/screens/notification_screen.dart';

class NotificationButton extends StatelessWidget {
  final String userId;
  final VoidCallback? onNotificationButtonPressed;

  const NotificationButton({
    Key? key,
    required this.userId,
    this.onNotificationButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () {
            // Navigate to notification screen
            Navigator.pushNamed(context, NotificationScreen.routeName);

            // Call callback if provided
            if (onNotificationButtonPressed != null) {
              onNotificationButtonPressed!();
            }
          },
        ),

        // Static badge for now - will be dynamic later when provider is properly set up
        Positioned(
          left: 26,
          top: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GlobalVariables.white, width: 0.5)
            ),
            constraints: const BoxConstraints(
              minWidth: 12,
              minHeight: 12,
            ),
            child: const Text(
              '3',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
