import 'package:flutter/material.dart';
import 'package:frontend/providers/notification_provider.dart';
import 'package:provider/provider.dart';

class NotificationBadge extends StatelessWidget {
  final Widget child;
  final double top;
  final double right;
  final double badgeSize;

  const NotificationBadge({
    Key? key,
    required this.child,
    this.top = -5,
    this.right = -5,
    this.badgeSize = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        final unreadCount = notificationProvider.unreadCount;
        
        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            if (unreadCount > 0)
              Positioned(
                top: top,
                right: right,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: BoxConstraints(
                    minWidth: badgeSize,
                    minHeight: badgeSize,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: (badgeSize * 0.6).clamp(8.0, 12.0),
                      fontWeight: FontWeight.bold,
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
