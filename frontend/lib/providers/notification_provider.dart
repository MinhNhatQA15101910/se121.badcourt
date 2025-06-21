import 'package:flutter/foundation.dart';
import 'package:frontend/common/services/notification_hub_service.dart';
import 'package:frontend/features/notification/Services/notification_service.dart';
import 'package:frontend/models/notification_dto.dart';
import 'package:frontend/models/paginated_notifications_dto.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationHubService _notificationHubService =
      NotificationHubService();
  final NotificationService _notificationService = NotificationService();

  List<NotificationDto> _notifications = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  bool _isConnected = false;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  int _unreadCount = 0;
  
  // Thêm flag để biết unread count có đến từ server không
  bool _unreadCountFromServer = false;

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
    _notificationHubService.onNotificationsReceived =
        (PaginatedNotificationsDto paginatedNotifications) {
      print(
          '[NotificationProvider] Received ${paginatedNotifications.items.length} notifications');

      _notifications = paginatedNotifications.items;
      _currentPage = paginatedNotifications.currentPage;
      _totalPages = paginatedNotifications.totalPages;
      _totalCount = paginatedNotifications.totalCount;
      
      // Chỉ tính toán local unread count nếu chưa có từ server
      if (!_unreadCountFromServer) {
        _updateLocalUnreadCount();
      }
      
      _isLoading = false;
      notifyListeners();

      print(
          '[NotificationProvider] Updated: ${_notifications.length} notifications, unread: $_unreadCount');
    };

    // Setup callback for new notifications
    _notificationHubService.onNewNotification = (NotificationDto notification) {
      print('[NotificationProvider] New notification received: ${notification.title}');

      // Add to beginning of list
      _notifications.insert(0, notification);
      
      // Tăng totalCount lên 1 khi nhận được notification mới
      _totalCount++;
      
      // Nếu notification mới chưa đọc và chưa có unread count từ server, tăng lên 1
      if (!notification.isRead && !_unreadCountFromServer) {
        _unreadCount++;
      }
      
      // Notify listeners để update UI
      notifyListeners();

      print(
          '[NotificationProvider] Added new notification - Total: $_totalCount, Unread: $_unreadCount');
    };

    // Setup callback for unread count from server - ƯU TIÊN SỬ DỤNG GIÁ TRỊ NÀY
    _notificationHubService.onUnreadCountReceived = (count) {
      print('[NotificationProvider] Received unread count from SignalR: $count');
      
      // Luôn sử dụng unread count từ server vì nó chính xác nhất
      _unreadCount = count;
      _unreadCountFromServer = true; // Đánh dấu là đã có từ server
      notifyListeners();
      
      print('[NotificationProvider] Updated unread count from server to: $_unreadCount');
    };
  }

  // Initialize notification hub
  Future<void> initializeNotificationHub(String token) async {
    try {
      _isLoading = true;
      _error = null;
      _isConnected = false;
      _unreadCountFromServer = false; // Reset flag
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

    try {
      // Request fresh notifications from server
      print('[NotificationProvider] Refreshing notifications...');
      
      // Reset server flag để có thể nhận unread count mới
      _unreadCountFromServer = false;
      
      // Since backend doesn't support manual refresh,
      // we just wait and let the automatic system work
      await Future.delayed(const Duration(seconds: 1));

      _isLoading = false;
      notifyListeners();
      
      print('[NotificationProvider] Refresh completed');
    } catch (e) {
      _error = 'Failed to refresh notifications: $e';
      _isLoading = false;
      notifyListeners();
      print('[NotificationProvider] Refresh error: $e');
    }
  }

  // Load next page of notifications
  Future<void> loadNextPage() async {
    if (!_isConnected || _isLoadingMore || !hasMorePages) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      print('[NotificationProvider] Loading next page...');
      
      // Since backend doesn't support pagination requests,
      // we simulate loading more by waiting
      await Future.delayed(const Duration(seconds: 1));

      _isLoadingMore = false;
      notifyListeners();
      
      print('[NotificationProvider] Next page loaded');
    } catch (e) {
      print('[NotificationProvider] Error loading next page: $e');
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Mark notification as read - SỬ DỤNG REST API THAY VÌ SIGNALR
  Future<bool> markNotificationAsRead(String notificationId, context) async {
    try {
      print('[NotificationProvider] Marking notification as read: $notificationId');
      
      // Tìm notification trong danh sách local
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      bool wasUnread = false;
      
      if (index != -1 && !_notifications[index].isRead) {
        wasUnread = true;
      }

      // Gọi REST API để đánh dấu đã đọc
      await _notificationService.markNotificationAsRead(
        context: context,
        notificationId: notificationId,
      );
      
      // Nếu API thành công, cập nhật UI
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        
        // Giảm unread count xuống 1 nếu notification này chưa đọc
        if (_unreadCount > 0) {
          _unreadCount--;
        }
        
        notifyListeners();
        print('[NotificationProvider] Notification marked as read successfully. Unread count: $_unreadCount');
      }
      
      return true;
      
    } catch (e) {
      print('[NotificationProvider] Error marking notification as read: $e');
      return false;
    }
  }

  // Mark all notifications as read - SỬ DỤNG REST API (nếu có endpoint)
  Future<bool> markAllNotificationsAsRead(context) async {
    try {
      print('[NotificationProvider] Marking all notifications as read...');
      
      // Đếm số notifications chưa đọc
      final unreadNotifications = _notifications.where((n) => !n.isRead).toList();
      
      // Gọi API cho từng notification chưa đọc
      // (Hoặc tạo endpoint markAllAsRead nếu backend hỗ trợ)
      for (final notification in unreadNotifications) {
        await _notificationService.markNotificationAsRead(
          context: context,
          notificationId: notification.id,
        );
      }
      
      // Cập nhật UI - đánh dấu tất cả là đã đọc
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }
      
      // Set unread count về 0
      _unreadCount = 0;
      
      notifyListeners();
      print('[NotificationProvider] All notifications marked as read successfully');
      
      return true;
      
    } catch (e) {
      print('[NotificationProvider] Error marking all notifications as read: $e');
      return false;
    }
  }

  // Tính toán unread count dựa trên notifications đã tải (chỉ dùng khi chưa có từ server)
  void _updateLocalUnreadCount() {
    if (_unreadCountFromServer) {
      // Nếu đã có từ server thì không tính toán local
      return;
    }
    
    final newUnreadCount = _notifications.where((n) => !n.isRead).length;
    
    if (_unreadCount != newUnreadCount) {
      _unreadCount = newUnreadCount;
      print('[NotificationProvider] Updated LOCAL unread count to: $_unreadCount');
    }
  }

  // Force update unread count - CHỈ CẬP NHẬT LOCAL KHI CẦN
  void forceUpdateUnreadCount() {
    if (!_unreadCountFromServer) {
      _updateLocalUnreadCount();
      notifyListeners();
    }
  }

  // Phương thức để reset server flag (dùng khi cần tính lại local)
  void resetServerUnreadCountFlag() {
    _unreadCountFromServer = false;
    _updateLocalUnreadCount();
    notifyListeners();
  }

  // Get notification by ID
  NotificationDto? getNotificationById(String id) {
    try {
      return _notifications.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get unread notifications
  List<NotificationDto> get unreadNotifications {
    return _notifications.where((n) => !n.isRead).toList();
  }

  // Get read notifications
  List<NotificationDto> get readNotifications {
    return _notifications.where((n) => n.isRead).toList();
  }

  // Disconnect
  void disconnect() {
    print('[NotificationProvider] Disconnecting from NotificationHub...');
    _notificationHubService.stopConnection();
    _isConnected = false;
    _clearData();
    notifyListeners();
    print('[NotificationProvider] Disconnected and cleared data');
  }

  void _clearData() {
    _notifications.clear();
    _currentPage = 1;
    _totalPages = 1;
    _totalCount = 0;
    _unreadCount = 0;
    _unreadCountFromServer = false; // Reset flag
    _error = null;
    _isLoading = false;
    _isLoadingMore = false;
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset provider state
  void reset() {
    disconnect();
    _clearData();
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
