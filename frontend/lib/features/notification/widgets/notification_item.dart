import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/notification_dto.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationItem extends StatefulWidget {
  final NotificationDto notification;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  State<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem>
    with TickerProviderStateMixin {
  late AnimationController _thumbUpController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _colorAnimation;

  bool _isLiked = false;

  @override
  void initState() {
    super.initState();

    // Animation controller for thumb up
    _thumbUpController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Animation controller for pulse effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Scale animation for thumb up
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _thumbUpController,
      curve: Curves.elasticOut,
    ));

    // Pulse animation
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    ));

    // Color animation
    _colorAnimation = ColorTween(
      begin: Colors.pink,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _thumbUpController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _thumbUpController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onThumbUpTap() async {
    if (_isLiked) return; // Prevent multiple taps

    setState(() {
      _isLiked = true;
    });

    // Start animations
    _thumbUpController.forward();
    _pulseController.forward();

    // Reset pulse animation after completion
    _pulseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.reset();
      }
    });

    // Add haptic feedback
    // HapticFeedback.lightImpact();

    // TODO: Call API to like the post
    // await _likePost();
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  IconData _getNotificationIcon(String type) {
  switch (type.toLowerCase()) {
    case 'courtbookingcreated':
      return Icons.event_available;
    case 'courtbookingcancelled':
      return Icons.event_busy;
    case 'postliked':
      return Icons.thumb_up;
    case 'postcommented':
      return Icons.comment;
    case 'commentliked':
      return Icons.thumb_up_alt;
    case 'facilityrated':
      return Icons.star;
    default:
      return Icons.notifications;
  }
}


  Color _getNotificationColor(String type) {
  switch (type.toLowerCase()) {
    case 'courtbookingcreated':
      return GlobalVariables.green;
    case 'courtbookingcancelled':
      return Colors.red;
    case 'postliked':
      return GlobalVariables.green;
    case 'postcommented':
      return Colors.orange;
    case 'commentliked':
      return Colors.blue;
    case 'facilityrated':
      return Colors.amber;
    default:
      return Colors.grey;
  }
}


  String _getNotificationTypeText(String type) {
  switch (type.toLowerCase()) {
    case 'courtbookingcreated':
      return 'Court Booking Created';
    case 'courtbookingcancelled':
      return 'Court Booking Cancelled';
    case 'postliked':
      return 'Post Liked';
    case 'postcommented':
      return 'Post Commented';
    case 'commentliked':
      return 'Comment Liked';
    case 'facilityrated':
      return 'Facility Rated';
    default:
      return 'Notification';
  }
}


  @override
  Widget build(BuildContext context) {
    final notificationColor = _getNotificationColor(widget.notification.type);
    final isUnread = !widget.notification.isRead;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color:
            isUnread ? GlobalVariables.green.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread
              ? GlobalVariables.green.withOpacity(0.2)
              : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: notificationColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: notificationColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _getNotificationIcon(widget.notification.type),
                    color: notificationColor,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row with type and time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Type badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: notificationColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: notificationColor.withOpacity(0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              _getNotificationTypeText(
                                  widget.notification.type),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: notificationColor,
                              ),
                            ),
                          ),

                          // Time
                          Text(
                            _formatTimeAgo(widget.notification.createdAt),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Title
                      Text(
                        widget.notification.title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight:
                              isUnread ? FontWeight.w600 : FontWeight.w500,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Content
                      Text(
                        widget.notification.content,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: isUnread
                              ? Colors.grey.shade700
                              : Colors.grey.shade600,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Action button and unread indicator
                Column(
                  children: [
                    // Unread indicator
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: GlobalVariables.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
