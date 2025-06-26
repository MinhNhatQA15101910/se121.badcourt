import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/notification/Services/notification_service.dart';
import 'package:frontend/features/notification/widgets/notification_item.dart';
import 'package:frontend/features/booking_details/screens/booking_detail_screen.dart';
import 'package:frontend/features/post/screens/post_detail_screen.dart';
import 'package:frontend/models/notification_dto.dart';
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
  final NotificationService _notificationService = NotificationService();
  final ScrollController _scrollController = ScrollController();

  // Pagination state
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;
  bool _hasMorePages = false;
  List<NotificationDto> _allNotifications = [];

  @override
  void initState() {
    super.initState();

    // Add scroll listener for infinite pagination
    _scrollController.addListener(_onScroll);

    // Initialize SignalR and load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotifications();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Initialize SignalR connection and sync with provider notifications
  Future<void> _initializeNotifications() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    // Ensure we're connected to the notification hub
    if (!notificationProvider.isConnected) {
      await notificationProvider
          .initializeNotificationHub(userProvider.user.token);
    }

    // Refresh notifications via SignalR
    await notificationProvider.refreshNotifications();

    // Sync initial data from provider
    _syncWithProvider();

    // Check pagination info after initial load
    await _checkPaginationInfo();
  }

  // Sync local state with NotificationProvider
  void _syncWithProvider() {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    setState(() {
      _allNotifications = List.from(notificationProvider.notifications);
      _currentPage = 1; // SignalR provides first page
      // Don't assume there are more pages, let REST API determine this
      _hasMorePages = true; // We'll check this on first REST API call
      _totalPages = 1; // Will be updated by first REST API call
    });
  }

  // Scroll listener for infinite pagination
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreNotifications();
    }
  }

  // Load more notifications using REST API
  Future<void> _loadMoreNotifications() async {
    if (_isLoadingMore) {
      return;
    }

    // For the first REST API call, we don't know total pages yet
    if (_totalPages > 1 && _currentPage >= _totalPages) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      print('Loading notifications page $nextPage'); // Debug log

      final paginatedResponse = await _notificationService.fetchNotification(
        context: context,
        pageNumber: nextPage,
      );

      if (mounted) {
        setState(() {
          // Update pagination info from REST API response
          _totalPages = paginatedResponse.totalPages;

          if (paginatedResponse.items.isNotEmpty) {
            // Add new notifications to the list
            _allNotifications.addAll(paginatedResponse.items);
            _currentPage = paginatedResponse.currentPage;
            _hasMorePages = _currentPage < _totalPages;
          } else {
            _hasMorePages = false;
          }

          print(
              'Updated: currentPage=$_currentPage, totalPages=$_totalPages, hasMore=$_hasMorePages');
        });

        print(
            'Loaded ${paginatedResponse.items.length} notifications. Total: ${_allNotifications.length}');
      }
    } catch (error) {
      if (mounted) {
        print('Error loading more notifications: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load more notifications: $error'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  // Refresh all notifications
  Future<void> _refreshNotifications() async {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    setState(() {
      _currentPage = 1;
      _totalPages = 1;
      _hasMorePages = true;
      _allNotifications.clear();
    });

    // Refresh via SignalR first
    await notificationProvider.refreshNotifications();

    // Sync with provider
    _syncWithProvider();
  }

  // Check pagination info by making a test call to page 2
  Future<void> _checkPaginationInfo() async {
    try {
      final testResponse = await _notificationService.fetchNotification(
        context: context,
        pageNumber: 2, // Check if page 2 exists
      );

      if (mounted) {
        setState(() {
          _totalPages = testResponse.totalPages;
          _hasMorePages = _currentPage < _totalPages;
        });

        print(
            'Pagination info: totalPages=$_totalPages, hasMore=$_hasMorePages');
      }
    } catch (error) {
      print('Error checking pagination info: $error');
      // If error, assume no more pages
      setState(() {
        _hasMorePages = false;
      });
    }
  }

  // CẢI TIẾN: Handle notification tap - gọi API và cập nhật UI
  Future<void> _handleNotificationTap(NotificationDto notification) async {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    // Nếu notification chưa đọc, đánh dấu đã đọc
    if (!notification.isRead) {
      final success = await notificationProvider.markNotificationAsRead(
          notification.id, context);

      if (success) {
        // Cập nhật local state
        setState(() {
          final index =
              _allNotifications.indexWhere((n) => n.id == notification.id);
          if (index != -1) {
            _allNotifications[index] =
                _allNotifications[index].copyWith(isRead: true);
          }
        });
      }
    }

    // Handle navigation based on notification type and data
    _navigateBasedOnNotificationType(notification);
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
                      onPressed: () async {
                        final success = await notificationProvider
                            .markAllNotificationsAsRead(context);
                        if (success) {
                          // Cập nhật local state
                          setState(() {
                            for (int i = 0; i < _allNotifications.length; i++) {
                              if (!_allNotifications[i].isRead) {
                                _allNotifications[i] =
                                    _allNotifications[i].copyWith(isRead: true);
                              }
                            }
                          });
                        }
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
            // Listen for new notifications from SignalR
            if (notificationProvider.notifications.length >
                _allNotifications.length) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _syncWithProvider();
              });
            }

            if (notificationProvider.isLoading && _allNotifications.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: GlobalVariables.green,
                ),
              );
            }

            if (notificationProvider.error != null &&
                _allNotifications.isEmpty) {
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
                      onPressed: _refreshNotifications,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GlobalVariables.green,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (_allNotifications.isEmpty) {
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
              onRefresh: _refreshNotifications,
              color: GlobalVariables.green,
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  // Additional scroll detection for better infinite scroll
                  if (scrollInfo is ScrollEndNotification &&
                      scrollInfo.metrics.pixels >=
                          scrollInfo.metrics.maxScrollExtent - 100) {
                    _loadMoreNotifications();
                  }
                  return false;
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // Notifications list
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final notification = _allNotifications[index];
                          return NotificationItem(
                            notification: notification,
                            onTap: () => _handleNotificationTap(notification),
                          );
                        },
                        childCount: _allNotifications.length,
                      ),
                    ),

                    // Loading more indicator
                    if (_isLoadingMore)
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          GlobalVariables.green),
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Loading more notifications...',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: GlobalVariables.darkGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    // End of list indicator
                    if (_allNotifications.isNotEmpty &&
                        !_hasMorePages &&
                        !_isLoadingMore)
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 16,
                                color: GlobalVariables.green,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'All notifications loaded',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: GlobalVariables.darkGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Bottom spacing
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 20),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigateBasedOnNotificationType(NotificationDto notification) {
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
        if (data.orderId != null) {
          Navigator.of(context).pushNamed(
            BookingDetailScreen.routeName,
            arguments: data.orderId,
          );
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
        if (data.postId != null) {
          Navigator.of(context).pushNamed(
            PostDetailScreen.routeName,
            arguments: data.postId,
          );
        }
        break;

      case 'facilityrated':
        if (data.roomId != null) {
          print('Navigate to facility: ${data.roomId}');
          // TODO: Navigate to facility detail screen
        }
        break;

      default:
        print('Unknown notification type: ${notification.type}');
    }
  }
}
