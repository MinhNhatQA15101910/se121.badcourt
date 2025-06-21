import 'package:flutter/foundation.dart';
import 'package:frontend/common/services/notification_hub_service.dart';
import 'package:frontend/models/notification_dto.dart';
import 'package:frontend/models/paginated_notifications_dto.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationHubService _notificationHubService = NotificationHubService();
  
  List<NotificationDto> _notifications = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  bool _isConnected = false;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  int _unreadCount = 0;

  // Getters
  List<NotificationDto> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _isConnected;
  int get unreadCount => _unreadCount;
  int get totalCount => _totalCount;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMorePages => _currentPage < _totalPages;
  bool get isLoadingMore => _isLoadingMore;

  NotificationProvider() {
    _setupCallbacks();
  }

  void _setupCallbacks() {
    // Setup callback for receiving initial notifications
    _notificationHubService.onNotificationsReceived = (PaginatedNotificationsDto paginatedNotifications) {
      print('[NotificationProvider] Received ${paginatedNotifications.items.length} notifications');
      
      _notifications = paginatedNotifications.items;
      _currentPage = paginatedNotifications.currentPage;
      _totalPages = paginatedNotifications.totalPages;
      _totalCount = paginatedNotifications.totalCount;
      _updateUnreadCount();
      _isLoading = false;
      notifyListeners();
      
      print('[NotificationProvider] Updated: ${_notifications.length} notifications, unread: $_unreadCount');
    };

    // Setup callback for new notifications
    _notificationHubService.onNewNotification = (NotificationDto notification) {
      print('[NotificationProvider] New notification: ${notification.title}');
      
      // Add to beginning of list
      _notifications.insert(0, notification);
      _totalCount++;
      _updateUnreadCount();
      notifyListeners();
      
      print('[NotificationProvider] Added new notification, total: ${_notifications.length}, unread: $_unreadCount');
    };
  }

  // Initialize notification hub
  Future<void> initializeNotificationHub(String token) async {
    try {
      _isLoading = true;
      _error = null;
      _isConnected = false;
      notifyListeners();

      print('[NotificationProvider] Connecting to NotificationHub...');
      await _notificationHubService.startConnection(token);
      
      _isConnected = true;
      print('[NotificationProvider] NotificationHub connected successfully');
      
      // Wait a bit for initial notifications to arrive
      await Future.delayed(const Duration(seconds: 2));
      
      _isLoading = false;
      notifyListeners();
      
    } catch (e) {
      _error = 'Failed to connect to notification service: $e';
      _isConnected = false;
      _isLoading = false;
      notifyListeners();
      print('[NotificationProvider] Error: $e');
    }
  }

  // Refresh notifications (reconnect to get latest)
  Future<void> refreshNotifications() async {
    if (!_isConnected) {
      _error = 'Not connected to notification service';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Since backend doesn't support manual refresh, 
    // we just wait and let the automatic system work
    await Future.delayed(const Duration(seconds: 1));
    
    _isLoading = false;
    notifyListeners();
  }

  // Load next page of notifications
  Future<void> loadNextPage() async {
    if (!_isConnected || _isLoadingMore || !hasMorePages) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      // Since backend doesn't support pagination requests,
      // we simulate loading more by waiting
      await Future.delayed(const Duration(seconds: 1));
    
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      print('[NotificationProvider] Error loading next page: $e');
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    if (!_isConnected) return;

    try {
      // Optimistically update UI
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _updateUnreadCount();
        notifyListeners();
      }
      
      // Try to send to server (may not be implemented)
      await _notificationHubService.markAsRead(notificationId);
      
    } catch (e) {
      print('[NotificationProvider] Error marking notification as read: $e');
      // Don't revert UI change since this might not be implemented on server
    }
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    if (!_isConnected) return;

    try {
      // Optimistically update UI
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }
      _updateUnreadCount();
      notifyListeners();
      
      // Try to send to server (may not be implemented)
      await _notificationHubService.markAllAsRead();
      
    } catch (e) {
      print('[NotificationProvider] Error marking all notifications as read: $e');
      // Don't revert UI change since this might not be implemented on server
    }
  }

  // Update unread count
  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  // Disconnect
  void disconnect() {
    _notificationHubService.stopConnection();
    _isConnected = false;
    _clearData();
    notifyListeners();
  }

  void _clearData() {
    _notifications.clear();
    _currentPage = 1;
    _totalPages = 1;
    _totalCount = 0;
    _unreadCount = 0;
    _error = null;
    _isLoading = false;
    _isLoadingMore = false;
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
