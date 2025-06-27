import 'package:signalr_netcore/signalr_client.dart';
import 'package:frontend/models/notification_dto.dart';
import 'package:frontend/models/paginated_notifications_dto.dart';
import 'package:frontend/constants/global_variables.dart';

class NotificationHubService {
  static final NotificationHubService _instance = NotificationHubService._internal();
  factory NotificationHubService() => _instance;
  NotificationHubService._internal();

  HubConnection? _hubConnection;
  bool _isConnected = false;

  // Callbacks
  Function(PaginatedNotificationsDto)? onNotificationsReceived;
  Function(NotificationDto)? onNewNotification;
  Function(int)? onUnreadCountReceived;

  // Getters
  bool get isConnected => _isConnected;
  HubConnection? get connection => _hubConnection;

  Future<void> startConnection(String token) async {
    if (_isConnected) {
      print('[NotificationHub] Already connected');
      return;
    }

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

      // Connection state handlers
      _hubConnection?.onclose(({Exception? error}) {
        print('[NotificationHub] Connection closed: $error');
        _isConnected = false;
      });

      _hubConnection?.onreconnecting(({Exception? error}) {
        print('[NotificationHub] Reconnecting: $error');
        _isConnected = false;
      });

      _hubConnection?.onreconnected(({String? connectionId}) {
        print('[NotificationHub] Reconnected with ID: $connectionId');
        _isConnected = true;
      });

      // Listen for initial notifications (sent automatically on connect)
      _hubConnection?.on('ReceiveNotifications', (arguments) {
        print('[NotificationHub] Received ReceiveNotifications event');
        print('[NotificationHub] Arguments: $arguments');
        
        if (arguments != null && arguments.isNotEmpty) {
          try {
            final data = arguments[0];
            print('[NotificationHub] Raw data type: ${data.runtimeType}');
            print('[NotificationHub] Raw data: $data');

            if (data is Map<String, dynamic>) {
              final paginatedNotifications = PaginatedNotificationsDto.fromJson(data);
              onNotificationsReceived?.call(paginatedNotifications);
              print('[NotificationHub] Parsed ${paginatedNotifications.items.length} notifications');
              print('[NotificationHub] Total count: ${paginatedNotifications.totalCount}');
            } else {
              print('[NotificationHub] Data is not Map<String, dynamic>: ${data.runtimeType}');
            }
          } catch (e, stackTrace) {
            print('[NotificationHub] Error parsing ReceiveNotifications: $e');
            print('[NotificationHub] Stack trace: $stackTrace');
          }
        } else {
          print('[NotificationHub] No data received in ReceiveNotifications');
        }
      });

      // Listen for new notifications - Enhanced logging
      _hubConnection?.on('ReceiveNotification', (arguments) {
        print('[NotificationHub] Received ReceiveNotification event');
        print('[NotificationHub] Arguments: $arguments');
        
        if (arguments != null && arguments.isNotEmpty) {
          try {
            final data = arguments[0];
            print('[NotificationHub] New notification data type: ${data.runtimeType}');
            print('[NotificationHub] New notification data: $data');
            
            if (data is Map<String, dynamic>) {
              final notification = NotificationDto.fromJson(data);
              onNewNotification?.call(notification);
              print('[NotificationHub] New notification processed: ${notification.title}');
              print('[NotificationHub] Notification ID: ${notification.id}');
              print('[NotificationHub] Is read: ${notification.isRead}');
            } else {
              print('[NotificationHub] Notification data is not Map<String, dynamic>: ${data.runtimeType}');
            }
          } catch (e, stackTrace) {
            print('[NotificationHub] Error parsing ReceiveNotification: $e');
            print('[NotificationHub] Stack trace: $stackTrace');
          }
        } else {
          print('[NotificationHub] No data received in ReceiveNotification');
        }
      });

      // Listen for unread count updates - Enhanced parsing
      _hubConnection?.on('ReceiveNumberOfUnreadNotifications', (arguments) {
        print('[NotificationHub] Received ReceiveNumberOfUnreadNotifications event');
        print('[NotificationHub] Arguments: $arguments');
        
        if (arguments != null && arguments.isNotEmpty) {
          final raw = arguments[0];
          print('[NotificationHub] Unread count raw data: $raw (${raw.runtimeType})');
          
          if (raw is int) {
            onUnreadCountReceived?.call(raw);
            print('[NotificationHub] Unread count (int): $raw');
          } else if (raw is String) {
            final count = int.tryParse(raw);
            if (count != null) {
              onUnreadCountReceived?.call(count);
              print('[NotificationHub] Unread count (parsed from String): $count');
            } else {
              print('[NotificationHub] Failed to parse unread count from String: $raw');
            }
          } else if (raw is double) {
            final count = raw.toInt();
            onUnreadCountReceived?.call(count);
            print('[NotificationHub] Unread count (converted from double): $count');
          } else {
            print('[NotificationHub] Unexpected unread count type: ${raw.runtimeType}, value: $raw');
          }
        } else {
          print('[NotificationHub] No data received in ReceiveNumberOfUnreadNotifications');
        }
      });

      // Start connection
      await _hubConnection?.start();
      _isConnected = true;
      print('✅ [NotificationHub] Connected successfully');
      print('[NotificationHub] Connection ID: ${_hubConnection?.connectionId}');

      // Notifications will be sent automatically by the server on connect
      print('[NotificationHub] Waiting for automatic notifications from server...');

    } catch (e, stackTrace) {
      print('❌ [NotificationHub] Connection failed: $e');
      print('[NotificationHub] Stack trace: $stackTrace');
      _isConnected = false;
      rethrow;
    }
  }

  // Request notifications manually (if backend supports this)
  Future<bool> requestNotifications({int page = 1, int pageSize = 20}) async {
    if (!_isConnected || _hubConnection == null) {
      print('[NotificationHub] Not connected - cannot request notifications');
      return false;
    }

    try {
      print('[NotificationHub] Requesting notifications (page: $page, size: $pageSize)');
      await _hubConnection?.invoke('GetNotifications', args: [page, pageSize]);
      print('[NotificationHub] Notification request sent successfully');
      return true;
    } catch (e) {
      print('[NotificationHub] Error requesting notifications: $e');
      return false;
    }
  }

  // Request unread count manually (if backend supports this)
  Future<bool> requestUnreadCount() async {
    if (!_isConnected || _hubConnection == null) {
      print('[NotificationHub] Not connected - cannot request unread count');
      return false;
    }

    try {
      print('[NotificationHub] Requesting unread count');
      await _hubConnection?.invoke('GetUnreadCount');
      print('[NotificationHub] Unread count request sent successfully');
      return true;
    } catch (e) {
      print('[NotificationHub] Error requesting unread count: $e');
      return false;
    }
  }

  // Clear callbacks (useful for testing or cleanup)
  void clearCallbacks() {
    onNotificationsReceived = null;
    onNewNotification = null;
    onUnreadCountReceived = null;
    print('[NotificationHub] Callbacks cleared');
  }

  // Check connection status
  bool checkConnection() {
    final isActuallyConnected = _hubConnection?.state == HubConnectionState.Connected;
    if (_isConnected != isActuallyConnected) {
      print('[NotificationHub] Connection state mismatch - updating');
      _isConnected = isActuallyConnected;
    }
    return _isConnected;
  }

  // Get connection info
  Map<String, dynamic> getConnectionInfo() {
    return {
      'isConnected': _isConnected,
      'connectionId': _hubConnection?.connectionId,
      'state': _hubConnection?.state.toString(),
      'hasCallbacks': {
        'onNotificationsReceived': onNotificationsReceived != null,
        'onNewNotification': onNewNotification != null,
        'onUnreadCountReceived': onUnreadCountReceived != null,
      },
    };
  }

  Future<void> stopConnection() async {
    if (_hubConnection != null) {
      try {
        print('[NotificationHub] Stopping connection...');
        await _hubConnection?.stop();
        _isConnected = false;
        print('[NotificationHub] Connection stopped successfully');
      } catch (e) {
        print('[NotificationHub] Error stopping connection: $e');
      } finally {
        _hubConnection = null;
      }
    } else {
      print('[NotificationHub] No connection to stop');
    }
  }

  // Dispose method for cleanup
  void dispose() {
    clearCallbacks();
    stopConnection();
  }
}
