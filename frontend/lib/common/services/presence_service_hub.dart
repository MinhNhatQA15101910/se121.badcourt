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

      // Setup SignalR event handlers
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
        print('[SignalR] Calling onUserOnline callback for user: $userId');
        onUserOnline?.call(userId);
      }
    });

    _hubConnection!.on('UserIsOffline', (arguments) {
      print('[SignalR] UserIsOffline event received: $arguments');
      if (arguments != null && arguments.isNotEmpty) {
        final userId = arguments[0].toString();
        print('[SignalR] Calling onUserOffline callback for user: $userId');
        onUserOffline?.call(userId);
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
          
          print('[SignalR] Calling onOnlineUsersReceived callback with users: $users');
          onOnlineUsersReceived?.call(users);
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
    print('onUserOnline: ${onUserOnline != null}');
    print('onUserOffline: ${onUserOffline != null}');
    print('onOnlineUsersReceived: ${onOnlineUsersReceived != null}');
  }
}
