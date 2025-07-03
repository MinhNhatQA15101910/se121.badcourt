import 'package:frontend/constants/global_variables.dart';
import 'package:signalr_netcore/signalr_client.dart';

class PresenceService {
  static final PresenceService _instance = PresenceService._internal();
  factory PresenceService() => _instance;
  PresenceService._internal();

  HubConnection? _hubConnection;
  bool _isConnected = false;

  // Callbacks for online/offline events
  Function(String userId)? onUserOnline;
  Function(String userId)? onUserOffline;
  Function(List<String> users)? onOnlineUsersReceived;

  // Method để set callbacks một cách an toàn
  void setCallbacks({
    Function(String userId)? onUserOnline,
    Function(String userId)? onUserOffline,
    Function(List<String> users)? onOnlineUsersReceived,
  }) {
    print('[PresenceService] Setting callbacks');
    this.onUserOnline = onUserOnline;
    this.onUserOffline = onUserOffline;
    this.onOnlineUsersReceived = onOnlineUsersReceived;
    
    // Verify callbacks
    print('[PresenceService] Callbacks set:');
    print('  onUserOnline: ${this.onUserOnline != null}');
    print('  onUserOffline: ${this.onUserOffline != null}');
    print('  onOnlineUsersReceived: ${this.onOnlineUsersReceived != null}');
  }

  Future<void> startConnection(String accessToken) async {
    if (_isConnected) {
      print('SignalR already connected');
      return;
    }

    try {
      final hubUrl = '$signalrUri/hubs/presence';
      print('Connecting to SignalR: $hubUrl');
      
      _hubConnection = HubConnectionBuilder()
          .withUrl(
            hubUrl,
            options: HttpConnectionOptions(
              accessTokenFactory: () async => accessToken,
              skipNegotiation: false,
              transport: HttpTransportType.WebSockets,
            ),
          )
          .withAutomaticReconnect()
          .build();

      // Setup SignalR event handlers AFTER callbacks are set
      _setupSignalRHandlers();

      // Bắt đầu kết nối
      await _hubConnection!.start();
      _isConnected = true;
      print('✅ [SignalR] Connected to PresenceHub successfully');
      
    } catch (e) {
      print('❌ [SignalR] Connection failed: $e');
      _isConnected = false;
      rethrow;
    }
  }

  void _setupSignalRHandlers() {
    print('[PresenceService] Setting up SignalR handlers');
    
    _hubConnection!.on('UserIsOnline', (arguments) {
      print('[SignalR] UserIsOnline event received: $arguments');
      if (arguments != null && arguments.isNotEmpty) {
        final userId = arguments[0].toString();
        print('[SignalR] Processing UserIsOnline for user: $userId');
        
        // Kiểm tra callback trước khi gọi
        if (onUserOnline != null) {
          print('[SignalR] Calling onUserOnline callback for user: $userId');
          try {
            onUserOnline!(userId);
            print('[SignalR] onUserOnline callback executed successfully');
          } catch (e) {
            print('[SignalR] Error calling onUserOnline: $e');
          }
        } else {
          print('[SignalR] ⚠️ onUserOnline callback is null!');
        }
      }
    });

    _hubConnection!.on('UserIsOffline', (arguments) {
      print('[SignalR] UserIsOffline event received: $arguments');
      if (arguments != null && arguments.isNotEmpty) {
        final userId = arguments[0].toString();
        print('[SignalR] Processing UserIsOffline for user: $userId');
        
        if (onUserOffline != null) {
          print('[SignalR] Calling onUserOffline callback for user: $userId');
          try {
            onUserOffline!(userId);
            print('[SignalR] onUserOffline callback executed successfully');
          } catch (e) {
            print('[SignalR] Error calling onUserOffline: $e');
          }
        } else {
          print('[SignalR] ⚠️ onUserOffline callback is null!');
        }
      }
    });

    _hubConnection!.on('GetOnlineUsers', (arguments) {
      print('[SignalR] GetOnlineUsers event received: $arguments');
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final usersData = arguments[0];
          List<String> users = [];
          
          if (usersData is List) {
            users = usersData.map((user) => user.toString()).toList();
          } else {
            users = [usersData.toString()];
          }
          
          if (onOnlineUsersReceived != null) {
            print('[SignalR] Calling onOnlineUsersReceived callback with users: $users');
            try {
              onOnlineUsersReceived!(users);
              print('[SignalR] onOnlineUsersReceived callback executed successfully');
            } catch (e) {
              print('[SignalR] Error calling onOnlineUsersReceived: $e');
            }
          } else {
            print('[SignalR] ⚠️ onOnlineUsersReceived callback is null!');
          }
        } catch (e) {
          print('Error parsing users: $e');
        }
      }
    });
  }

  Future<void> stopConnection() async {
    if (_hubConnection != null && _isConnected) {
      try {
        await _hubConnection!.stop();
        _isConnected = false;
        print('[SignalR] Disconnected from PresenceHub');
      } catch (e) {
        print('Error stopping SignalR: $e');
      }
    }
  }

  bool get isConnected => _isConnected;
  
  String get connectionState {
    if (_hubConnection == null) return 'Not initialized';
    return _hubConnection!.state.toString();
  }

  // Method để test callbacks
  void testCallbacks() {
    print('[PresenceService] Testing callbacks:');
    print('  onUserOnline: ${onUserOnline != null}');
    print('  onUserOffline: ${onUserOffline != null}');
    print('  onOnlineUsersReceived: ${onOnlineUsersReceived != null}');
  }

  // Method để manually trigger events (for debugging)
  void debugTriggerUserOnline(String userId) {
    print('[PresenceService] Debug: Manually triggering UserIsOnline for $userId');
    if (onUserOnline != null) {
      onUserOnline!(userId);
    } else {
      print('[PresenceService] Debug: onUserOnline callback is null');
    }
  }
}
