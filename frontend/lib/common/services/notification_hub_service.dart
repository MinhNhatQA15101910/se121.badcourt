import 'package:signalr_netcore/signalr_client.dart';
import 'package:frontend/models/notification_dto.dart';
import 'package:frontend/models/paginated_notifications_dto.dart';
import 'package:frontend/constants/global_variables.dart';

class NotificationHubService {
  HubConnection? _hubConnection;
  bool _isConnected = false;

  // Callbacks
  Function(PaginatedNotificationsDto)? onNotificationsReceived;
  Function(NotificationDto)? onNewNotification;

  bool get isConnected => _isConnected;

  Future<void> startConnection(String token) async {
    if (_isConnected) return;

    try {
      final hubUrl = '$signalrUri/hubs/notification';
      print('[NotificationHub] Connecting to: $hubUrl');
      
      _hubConnection = HubConnectionBuilder()
          .withUrl(hubUrl,
              options: HttpConnectionOptions(
                accessTokenFactory: () async => token,
                skipNegotiation: false,
                transport: HttpTransportType.WebSockets,
                requestTimeout: 30000,
              ))
          .withAutomaticReconnect(retryDelays: [0, 2000, 10000, 30000])
          .build();

      // Fix: Sửa signature của onclose callback
      _hubConnection?.onclose(({Exception? error}) {
        print('[NotificationHub] Connection closed: $error');
        _isConnected = false;
      });

      // Listen for initial notifications (sent automatically on connect)
      _hubConnection?.on('ReceiveNotifications', (arguments) {
        print('[NotificationHub] Received ReceiveNotifications event');
        if (arguments != null && arguments.isNotEmpty) {
          try {
            final data = arguments[0];
            print('[NotificationHub] Raw data: $data');
            
            if (data is Map<String, dynamic>) {
              final paginatedNotifications = PaginatedNotificationsDto.fromJson(data);
              onNotificationsReceived?.call(paginatedNotifications);
              print('[NotificationHub] Parsed ${paginatedNotifications.items.length} notifications');
            }
          } catch (e) {
            print('[NotificationHub] Error parsing ReceiveNotifications: $e');
          }
        }
      });

      // Listen for new notifications
      _hubConnection?.on('ReceiveNotification', (arguments) {
        print('[NotificationHub] Received ReceiveNotification event');
        if (arguments != null && arguments.isNotEmpty) {
          try {
            final data = arguments[0];
            if (data is Map<String, dynamic>) {
              final notification = NotificationDto.fromJson(data);
              onNewNotification?.call(notification);
              print('[NotificationHub] New notification: ${notification.title}');
            }
          } catch (e) {
            print('[NotificationHub] Error parsing NewNotification: $e');
          }
        }
      });

      await _hubConnection?.start();
      _isConnected = true;
      print('✅ [NotificationHub] Connected successfully');
      
      // Notifications will be sent automatically by the server on connect
      
    } catch (e) {
      print('❌ [NotificationHub] Connection failed: $e');
      _isConnected = false;
      rethrow;
    }
  }

  // Mark notification as read (if backend supports this)
  Future<void> markAsRead(String notificationId) async {
    if (!_isConnected || _hubConnection == null) return;

    try {
      await _hubConnection?.invoke('MarkAsRead', args: [notificationId]);
      print('[NotificationHub] Marked notification as read: $notificationId');
    } catch (e) {
      print('[NotificationHub] Error marking notification as read: $e');
      // Don't rethrow - this is optional functionality
    }
  }

  // Mark all notifications as read (if backend supports this)
  Future<void> markAllAsRead() async {
    if (!_isConnected || _hubConnection == null) return;

    try {
      await _hubConnection?.invoke('MarkAllAsRead');
      print('[NotificationHub] Marked all notifications as read');
    } catch (e) {
      print('[NotificationHub] Error marking all notifications as read: $e');
      // Don't rethrow - this is optional functionality
    }
  }

  Future<void> stopConnection() async {
    if (_hubConnection != null) {
      try {
        await _hubConnection?.stop();
        _isConnected = false;
        print('[NotificationHub] Disconnected');
      } catch (e) {
        print('[NotificationHub] Error stopping connection: $e');
      }
    }
  }
}
