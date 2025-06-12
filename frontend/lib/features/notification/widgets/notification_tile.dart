import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/notification_dto.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationTile extends StatelessWidget {
  final NotificationDto notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year(s) ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month(s) ago';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} week(s) ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'order':
        return Icons.shopping_cart;
      case 'message':
        return Icons.message;
      case 'post':
        return Icons.article;
      case 'comment':
        return Icons.comment;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'order':
        return Colors.orange;
      case 'message':
        return Colors.blue;
      case 'post':
        return Colors.green;
      case 'comment':
        return Colors.purple;
      case 'system':
        return Colors.grey;
      default:
        return GlobalVariables.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : GlobalVariables.lightGreen.withOpacity(0.1),
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getNotificationColor(notification.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: _getNotificationColor(notification.type),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and time
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: notification.isRead 
                                ? FontWeight.w500 
                                : FontWeight.w600,
                            color: GlobalVariables.darkGreen,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTimeAgo(notification.createdAt),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Content
                  Text(
                    notification.content,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: notification.isRead 
                          ? Colors.grey[600] 
                          : GlobalVariables.darkGreen,
                      fontWeight: notification.isRead 
                          ? FontWeight.normal 
                          : FontWeight.w500,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Type badge
                  if (notification.type.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getNotificationColor(notification.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getNotificationColor(notification.type).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          notification.type.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _getNotificationColor(notification.type),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Unread indicator
            if (!notification.isRead)
              Container(
                margin: const EdgeInsets.only(left: 8, top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: GlobalVariables.green,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
