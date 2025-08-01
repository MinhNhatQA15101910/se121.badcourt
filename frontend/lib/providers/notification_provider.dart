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
      print('[NotificationProvider] Notification isRead: ${notification.isRead}');

      // Add to beginning of list
      _notifications.insert(0, notification);
      
      // Tăng totalCount lên 1 khi nhận được notification mới
      _totalCount++;
      
      // LOGIC MỚI: Luôn cộng unread count lên 1 nếu notification chưa đọc
      if (!notification.isRead) {
        _unreadCount++;
        print('[NotificationProvider] Incremented unread count to: $_unreadCount');
      }
      
      // Notify listeners để update UI
      notifyListeners();

      print(
          '[NotificationProvider] Added new notification - Total: $_totalCount, Unread: $_unreadCount');
    };

    // Setup callback for unread count from server
    _notificationHubService.onUnreadCountReceived = (count) {
      print('[NotificationProvider] Received unread count from SignalR: $count');
      
      // Chỉ sử dụng unread count từ server khi lần đầu kết nối
      if (!_unreadCountFromServer) {
        _unreadCount = count;
        _unreadCountFromServer = true;
        notifyListeners();
        print('[NotificationProvider] Set initial unread count from server to: $_unreadCount');
      } else {
        print('[NotificationProvider] Ignored server unread count (using local management): $count vs $_unreadCount');
      }
    };
  }

  // Initialize notification hub
  Future<void> initializeNotificationHub(String token) async {
    try {
      _isLoading = true;
      _error = null;
      _isConnected = false;
      _unreadCountFromServer = false;
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

  // Refresh notifications
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
      print('[NotificationProvider] Refreshing notifications...');
      _unreadCountFromServer = false;
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

  // Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId, context) async {
    try {
      print('[NotificationProvider] Marking notification as read: $notificationId');
      
      // Tìm notification trong danh sách local
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      final wasUnread = index != -1 && !_notifications[index].isRead;

      // Gọi REST API để đánh dấu đã đọc
      final success = await _notificationService.markNotificationAsRead(
        context: context,
        notificationId: notificationId,
      );
      
      // Nếu API thành công, cập nhật UI
      if (success && index != -1 && wasUnread) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        
        // Giảm unread count xuống 1
        if (_unreadCount > 0) {
          _unreadCount--;
        }
        
        notifyListeners();
        print('[NotificationProvider] Notification marked as read successfully. Unread count: $_unreadCount');
      }
      
      return success;
      
    } catch (e) {
      print('[NotificationProvider] Error marking notification as read: $e');
      return false;
    }
  }

  // CẢI TIẾN: Mark all notifications as read với đồng bộ unread count
  Future<bool> markAllNotificationsAsRead(context) async {
    try {
      print('[NotificationProvider] Marking all notifications as read...');
      
      // Đếm số notifications chưa đọc trong danh sách hiện tại
      final currentUnreadNotifications = _notifications.where((n) => !n.isRead).toList();
      final currentUnreadCount = currentUnreadNotifications.length;
      
      print('[NotificationProvider] Current unread notifications in list: $currentUnreadCount');
      print('[NotificationProvider] Current unread count: $_unreadCount');
      
      // Gọi API để đánh dấu tất cả là đã đọc
      final result = await _notificationService.markAllNotificationsAsRead(
        context: context,
        showSuccessMessage: true,
      );
      
      if (result['success'] == true) {
        // Cập nhật UI - đánh dấu tất cả notifications trong danh sách là đã đọc
        for (int i = 0; i < _notifications.length; i++) {
          if (!_notifications[i].isRead) {
            _notifications[i] = _notifications[i].copyWith(isRead: true);
          }
        }
        
        // LOGIC ĐỒNG BỘ UNREAD COUNT:
        // Nếu API trả về số lượng đã đánh dấu, sử dụng nó
        final markedCount = result['markedCount'] as int;
        if (markedCount > 0) {
          // Trừ đi số lượng đã đánh dấu từ server
          _unreadCount = (_unreadCount - markedCount).clamp(0, _unreadCount);
          print('[NotificationProvider] Used server marked count: $markedCount, new unread count: $_unreadCount');
        } else {
          // Nếu không có thông tin từ server, reset về 0 (đánh dấu tất cả)
          _unreadCount = 0;
          print('[NotificationProvider] Reset unread count to 0 (mark all)');
        }
        
        // Đồng bộ với server để đảm bảo chính xác
        _syncUnreadCountWithServer(context);
        
        notifyListeners();
        print('[NotificationProvider] All notifications marked as read successfully. Final unread count: $_unreadCount');
        
        return true;
      }
      
      return false;
      
    } catch (e) {
      print('[NotificationProvider] Error marking all notifications as read: $e');
      return false;
    }
  }

  // THÊM: Đồng bộ unread count với server
  Future<void> _syncUnreadCountWithServer(context) async {
    try {
      final serverUnreadCount = await _notificationService.getUnreadCount(
        context: context,
      );
      
      if (serverUnreadCount != _unreadCount) {
        print('[NotificationProvider] Syncing unread count with server: local=$_unreadCount, server=$serverUnreadCount');
        _unreadCount = serverUnreadCount;
        notifyListeners();
      }
    } catch (e) {
      print('[NotificationProvider] Error syncing unread count with server: $e');
    }
  }

  // Tính toán unread count dựa trên notifications đã tải
  void _updateLocalUnreadCount() {
    final newUnreadCount = _notifications.where((n) => !n.isRead).length;
    
    if (_unreadCount != newUnreadCount) {
      _unreadCount = newUnreadCount;
      print('[NotificationProvider] Updated LOCAL unread count to: $_unreadCount');
    }
  }

  // Force update unread count
  void forceUpdateUnreadCount() {
    if (!_unreadCountFromServer) {
      _updateLocalUnreadCount();
      notifyListeners();
    }
  }

  // Reset server flag
  void resetServerUnreadCountFlag() {
    _unreadCountFromServer = false;
    _updateLocalUnreadCount();
    notifyListeners();
  }

  // Sync unread count with server manually
  void syncUnreadCountWithServer(int serverCount) {
    if (_unreadCount != serverCount) {
      print('[NotificationProvider] Syncing unread count: local=$_unreadCount, server=$serverCount');
      _unreadCount = serverCount;
      notifyListeners();
    }
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
    _unreadCountFromServer = false;
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