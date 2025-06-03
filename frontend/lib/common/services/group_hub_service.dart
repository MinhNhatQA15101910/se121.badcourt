import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/group_dto.dart';
import 'package:signalr_netcore/signalr_client.dart';

class GroupHubService {
  static final GroupHubService _instance = GroupHubService._internal();
  factory GroupHubService() => _instance;
  GroupHubService._internal();

  HubConnection? _connection;
  bool _isConnected = false;

  // Callbacks
  Function(List<GroupDto> groups)? onReceiveGroups;
  Function(MessageDto message)? onNewMessage;
  Function(GroupDto group)? onGroupUpdated;

  // Getters
  bool get isConnected => _isConnected;
  HubConnection? get connection => _connection;

  // Start connection to GroupHub
  Future<void> startConnection(String accessToken) async {
    if (_isConnected) {
      print('[GroupHub] Already connected');
      return;
    }

    try {
      final hubUrl = '$signalrUri/hubs/group';
      print('[GroupHub] Connecting to: $hubUrl');
      
      _connection = HubConnectionBuilder()
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
      _connection!.on('ReceiveGroups', (arguments) {
        print('[GroupHub] Received groups event');
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
              print('[GroupHub] Received ${groups.length} groups');
            }
          } catch (e) {
            print('[GroupHub] Error parsing groups: $e');
          }
        }
      });

      _connection!.on('NewMessage', (arguments) {
        print('[GroupHub] Received new message event');
        if (arguments != null && arguments.isNotEmpty) {
          try {
            final messageData = arguments[0];
            if (messageData is Map<String, dynamic>) {
              final message = MessageDto.fromJson(messageData);
              onNewMessage?.call(message);
              print('[GroupHub] New message from: ${message.senderId}');
            }
          } catch (e) {
            print('[GroupHub] Error parsing new message: $e');
          }
        }
      });

      _connection!.on('GroupUpdated', (arguments) {
        print('[GroupHub] Received group updated event');
        if (arguments != null && arguments.isNotEmpty) {
          try {
            final groupData = arguments[0];
            if (groupData is Map<String, dynamic>) {
              final group = GroupDto.fromJson(groupData);
              onGroupUpdated?.call(group);
              print('[GroupHub] Group updated: ${group.id}');
            }
          } catch (e) {
            print('[GroupHub] Error parsing updated group: $e');
          }
        }
      });

      // Start connection
      await _connection!.start();
      _isConnected = true;
      print('✅ [GroupHub] Connected successfully');
      
      // Note: Groups should be automatically sent by the server upon connection
      // No need to explicitly request them
      
    } catch (e) {
      _isConnected = false;
      print('❌ [GroupHub] Connection failed: $e');
      rethrow;
    }
  }

  // Stop connection
  Future<void> stopConnection() async {
    if (_connection != null) {
      try {
        await _connection!.stop();
        _isConnected = false;
        print('[GroupHub] Disconnected');
      } catch (e) {
        print('[GroupHub] Error stopping connection: $e');
      }
    }
  }

  // Send message to group
  Future<bool> sendMessage(String groupId, String content, {String? attachmentUrl}) async {
    if (!_isConnected || _connection == null) {
      print('[GroupHub] Not connected');
      return false;
    }

    try {
      final messageData = {
        'groupId': groupId,
        'content': content,
        if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
      };

      await _connection!.invoke('SendMessage', args: [messageData]);
      print('[GroupHub] Message sent to group: $groupId');
      return true;
    } catch (e) {
      print('[GroupHub] Error sending message: $e');
      return false;
    }
  }

  // Mark group as read
  Future<bool> markGroupAsRead(String groupId) async {
    if (!_isConnected || _connection == null) {
      print('[GroupHub] Not connected');
      return false;
    }

    try {
      await _connection!.invoke('MarkGroupAsRead', args: [groupId]);
      print('[GroupHub] Group marked as read: $groupId');
      return true;
    } catch (e) {
      print('[GroupHub] Error marking group as read: $e');
      return false;
    }
  }

  // Simplified method - just wait for automatic groups from server
  Future<bool> requestGroups() async {
    if (!_isConnected || _connection == null) {
      print('[GroupHub] Not connected - cannot request groups');
      return false;
    }

    // Since the server methods don't exist, we'll just indicate that we're waiting
    // for automatic group updates from the server
    print('[GroupHub] Waiting for automatic group updates from server...');
    return true;
  }
}
