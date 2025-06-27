import 'package:flutter/material.dart';
import 'package:frontend/providers/online_users_provider.dart';
import 'package:provider/provider.dart';

class OnlineStatusIndicator extends StatelessWidget {
  final String userId;
  final double size;
  final bool showText;

  const OnlineStatusIndicator({
    Key? key,
    required this.userId,
    this.size = 8.0,
    this.showText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OnlineUsersProvider>(
      builder: (context, onlineUsersProvider, child) {
        final bool isOnline = onlineUsersProvider.isUserOnline(userId);
        
        // Debug print
        print('[OnlineStatusIndicator] Building for user $userId, isOnline: $isOnline');
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: isOnline ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
                boxShadow: isOnline ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ] : null,
              ),
            ),
            if (showText) ...[
              const SizedBox(width: 4),
              Text(
                isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  color: isOnline ? Colors.green : Colors.grey[600],
                  fontSize: 12,
                  fontWeight: isOnline ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
