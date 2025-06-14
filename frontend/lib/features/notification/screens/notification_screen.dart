import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/notification/widgets/notification_item.dart';
import 'package:frontend/features/booking_details/screens/booking_detail_screen.dart';
import 'package:frontend/features/post/screens/post_detail_screen.dart';
import 'package:frontend/providers/notification_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  static const String routeName = '/notificationScreen';
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh notifications when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final notificationProvider =
          Provider.of<NotificationProvider>(context, listen: false);

      // Ensure we're connected to the notification hub
      if (!notificationProvider.isConnected) {
        notificationProvider.initializeNotificationHub(userProvider.user.token);
      }

      // Refresh notifications
      notificationProvider.refreshNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalVariables.green,
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.none,
            color: GlobalVariables.white,
          ),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, _) {
              return Row(
                children: [
                  // Connection status indicator
                  IconButton(
                    icon: Icon(
                      notificationProvider.isConnected
                          ? Icons.cloud_done
                          : Icons.cloud_off,
                      color: notificationProvider.isConnected
                          ? Colors.white
                          : Colors.red[300],
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            notificationProvider.isConnected
                                ? 'Connected to notification service'
                                : 'Disconnected from notification service',
                          ),
                        ),
                      );
                    },
                  ),
                  // Mark all as read button
                  if (notificationProvider.unreadCount > 0)
                    IconButton(
                      icon: const Icon(Icons.done_all, color: Colors.white),
                      onPressed: () {
                        notificationProvider.markAllNotificationsAsRead();
                      },
                      tooltip: 'Mark all as read',
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Container(
        color: GlobalVariables.defaultColor,
        child: Consumer<NotificationProvider>(
          builder: (context, notificationProvider, _) {
            if (notificationProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: GlobalVariables.green,
                ),
              );
            }

            if (notificationProvider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading notifications',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notificationProvider.error!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        notificationProvider.refreshNotifications();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GlobalVariables.green,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (notificationProvider.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You\'ll receive notifications here!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await notificationProvider.refreshNotifications();
              },
              color: GlobalVariables.green,
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent &&
                      notificationProvider.hasMorePages &&
                      !notificationProvider.isLoadingMore) {
                    notificationProvider.loadNextPage();
                    return true;
                  }
                  return false;
                },
                child: ListView.builder(
                  itemCount: notificationProvider.notifications.length +
                      (notificationProvider.hasMorePages ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Show loading indicator at the bottom when loading more
                    if (index == notificationProvider.notifications.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: GlobalVariables.green,
                          ),
                        ),
                      );
                    }

                    final notification =
                        notificationProvider.notifications[index];
                    return NotificationItem(
                      notification: notification,
                      onTap: () {
                        // Mark as read when tapped
                        if (!notification.isRead) {
                          notificationProvider
                              .markNotificationAsRead(notification.id);
                        }

                        // Handle navigation based on notification type and data
                        _handleNotificationTap(notification);
                      },
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleNotificationTap(notification) {
    final type = notification.type.toLowerCase();
    final data = notification.data;

    switch (type) {
      case 'courtbookingcreated':
        if (data.orderId != null) {
          Navigator.of(context).pushNamed(
            BookingDetailScreen.routeName,
            arguments: data.orderId,
          );
        }
        break;
      case 'courtbookingcancelled':
        if (data.bookingId != null) {
          print('Navigate to booking details: ${data.bookingId}');
          // TODO: Navigate to booking detail screen
          // Navigator.push(context, ...);
        }
        break;

      case 'postliked':
        if (data.postId != null) {
          Navigator.of(context).pushNamed(
            PostDetailScreen.routeName,
            arguments: data.postId,
          );
        }
      case 'postcommented':
        if (data.postId != null) {
          Navigator.of(context).pushNamed(
            PostDetailScreen.routeName,
            arguments: data.postId,
          );
        }
        break;

      case 'commentliked':
        if (data.commentId != null) {
          print('Navigate to comment: ${data.commentId}');
          // TODO: Navigate to comment or comment thread
        }
        break;

      case 'facilityrated':
        if (data.facilityId != null) {
          print('Navigate to facility: ${data.facilityId}');
          // TODO: Navigate to facility detail screen
        }
        break;

      default:
        print('Unknown notification type: ${notification.type}');
    }
  }
}
