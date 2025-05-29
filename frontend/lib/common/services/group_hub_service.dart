import 'package:frontend/constants/global_variables.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:frontend/models/group_dto.dart';

class GroupHubService {
  static final GroupHubService _instance = GroupHubService._internal();
  factory GroupHubService() => _instance;
  GroupHubService._internal();

  HubConnection? _hubConnection;
  bool _isConnected = false;

  // Callbacks for group events
  Function(List<GroupDto> groups)? onReceiveGroups;

  Future<void> startConnection(String accessToken) async {
    if (_isConnected) {
      print('[GroupHub] Already connected');
      return;
    }

    try {
      final hubUrl = '$signalrUri/hubs/group';
      print('[GroupHub] Connecting to: $hubUrl');
      
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

      // Set up event listeners
      _hubConnection!.on('ReceiveGroups', (arguments) {
        print('[GroupHub] Received ReceiveGroups event: $arguments');
        if (arguments != null && arguments.isNotEmpty) {
          try {
            final groupsData = arguments[0];
            if (groupsData is List) {
              final groups = groupsData.map((groupJson) {
                if (groupJson is Map<String, dynamic>) {
                  return GroupDto.fromJson(groupJson);
                } else {
                  throw Exception('Group data is not Map<String, dynamic>');
                }
              }).toList();
              onReceiveGroups?.call(groups);
              print('[GroupHub] Processed ${groups.length} groups');
            } else {
              print('[GroupHub] ReceiveGroups data is not List: ${groupsData.runtimeType}');
            }
          } catch (e) {
            print('[GroupHub] Error parsing groups: $e');
          }
        }
      });

      // Start connection
      await _hubConnection!.start();
      _isConnected = true;
      print('✅ [GroupHub] Connected successfully');
      
    } catch (e) {
      print('❌ [GroupHub] Connection failed: $e');
      _isConnected = false;
      rethrow;
    }
  }

  Future<void> stopConnection() async {
    if (_hubConnection != null && _isConnected) {
      try {
        await _hubConnection!.stop();
        _isConnected = false;
        print('[GroupHub] Disconnected');
      } catch (e) {
        print('[GroupHub] Error stopping connection: $e');
      }
    }
  }

  bool get isConnected => _isConnected;
  
  String get connectionState {
    if (_hubConnection == null) return 'Not initialized';
    return _hubConnection!.state.toString();
  }
}