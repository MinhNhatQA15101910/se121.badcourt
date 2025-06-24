import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/notification/screens/notification_screen.dart';
import 'package:frontend/providers/notification_provider.dart';
import 'package:provider/provider.dart';

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
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final unreadCount = notificationProvider.unreadCount;

        return Stack(
          children: [
            IconButton(
              icon: Icon(
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

            // Dynamic badge showing unread count
            if (unreadCount > 0)
              Positioned(
                left: 26,
                top: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: GlobalVariables.white, width: 0.5)),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
