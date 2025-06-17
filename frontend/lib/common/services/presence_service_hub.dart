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
      // Sử dụng đúng URL như web: /hubs/presence thay vì /presenceHub
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

      // Thiết lập event listeners giống như web
      _hubConnection!.on('UserIsOnline', (arguments) {
        if (arguments != null && arguments.isNotEmpty) {
          final userId = arguments[0].toString();
          onUserOnline?.call(userId);
          print('[SignalR] User $userId is online');
        }
      });

      _hubConnection!.on('UserIsOffline', (arguments) {
        if (arguments != null && arguments.isNotEmpty) {
          final userId = arguments[0].toString();
          onUserOffline?.call(userId);
          print('[SignalR] User $userId is offline');
        }
      });

      _hubConnection!.on('GetOnlineUsers', (arguments) {
        if (arguments != null && arguments.isNotEmpty) {
          try {
            final usersData = arguments[0];
            List<String> users = [];
            
            if (usersData is List) {
              users = usersData.map((user) => user.toString()).toList();
            } else {
              users = [usersData.toString()];
            }
            
            onOnlineUsersReceived?.call(users);
            print('[SignalR] Online users: $users');
          } catch (e) {
            print('Error parsing users: $e');
          }
        }
      });

      _hubConnection!.on('NewMessageReceived', (arguments) {
        print('[SignalR] Received NewMessageReceived event');
      });

      _hubConnection?.on('ReceiveNotification', (arguments) {
        print('[SignalR] Received ReceiveNotification event');
      });

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
}