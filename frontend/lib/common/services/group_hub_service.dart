import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/group_dto.dart';
import 'package:frontend/models/message_dto.dart';
import 'package:signalr_netcore/signalr_client.dart';

class GroupHubService {
  static final GroupHubService _instance = GroupHubService._internal();
  factory GroupHubService() => _instance;
  GroupHubService._internal();

  HubConnection? _connection;
  bool _isConnected = false;

  // Callbacks - Updated to handle paginated data
  Function(PaginatedGroupsDto paginatedGroups)? onReceiveGroups;
  Function(MessageDto message)? onNewMessage;
  Function(GroupDto group)? onGroupUpdated;
  // Thêm callback cho NewMessageReceived
  Function(GroupDto group)? onNewMessageReceived;

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
        print('[GroupHub] Arguments: $arguments');
        
        if (arguments != null && arguments.isNotEmpty) {
          try {
            final paginatedData = arguments[0];
            print('[GroupHub] Paginated data type: ${paginatedData.runtimeType}');
            print('[GroupHub] Paginated data: $paginatedData');
            
            if (paginatedData is Map<String, dynamic>) {
              final paginatedGroups = PaginatedGroupsDto.fromJson(paginatedData);
              onReceiveGroups?.call(paginatedGroups);
              print('[GroupHub] Received paginated groups: ${paginatedGroups.items.length} groups on page ${paginatedGroups.currentPage}/${paginatedGroups.totalPages}');
              
              // Log each group for debugging
              for (int i = 0; i < paginatedGroups.items.length; i++) {
                final group = paginatedGroups.items[i];
                print('[GroupHub] Group $i: ${group.name} with ${group.users.length} users, lastMessage: ${group.lastMessage?.content}');
              }
            } else {
              print('[GroupHub] Paginated data is not Map<String, dynamic>: ${paginatedData.runtimeType}');
            }
          } catch (e, stackTrace) {
            print('[GroupHub] Error parsing paginated groups: $e');
            print('[GroupHub] Stack trace: $stackTrace');
          }
        } else {
          print('[GroupHub] No paginated groups data received');
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

      _connection!.on('NewMessageReceived', (arguments) {
        print('[GroupHub] Received NewMessageReceived event');
        print('[GroupHub] Arguments: $arguments');
        
        if (arguments != null && arguments.isNotEmpty) {
          try {
            final groupData = arguments[0];
            if (groupData is Map<String, dynamic>) {
              final group = GroupDto.fromJson(groupData);
              onNewMessageReceived?.call(group);
              print('[GroupHub] NewMessageReceived processed: Group ${group.id} with message from ${group.lastMessage?.senderUsername}');
            }
          } catch (e) {
            print('[GroupHub] Error parsing NewMessageReceived: $e');
          }
        }
      });

      // Start connection
      await _connection!.start();
      _isConnected = true;
      print('✅ [GroupHub] Connected successfully');
      
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

  // Request specific page of groups
  Future<bool> requestPage(int pageNumber, int pageSize) async {
    if (!_isConnected || _connection == null) {
      print('[GroupHub] Not connected - cannot request groups');
      return false;
    }

    try {
      print('[GroupHub] Requesting page $pageNumber with size $pageSize');
      
      // Check if the server supports the GetGroups method with pagination
      await _connection!.invoke('GetGroups', args: [pageNumber, pageSize]);
      
      print('[GroupHub] Page request sent successfully');
      return true;
    } catch (e) {
      print('[GroupHub] Error requesting page: $e');
      
      // Fallback to default method if pagination not supported
      print('[GroupHub] Falling back to default method');
      return await requestGroups();
    }
  }

  // Simplified method - just wait for automatic groups from server
  Future<bool> requestGroups() async {
    if (!_isConnected || _connection == null) {
      print('[GroupHub] Not connected - cannot request groups');
      return false;
    }

    try {
      // Try to call GetGroups without parameters
      await _connection!.invoke('GetGroups');
      print('[GroupHub] GetGroups request sent');
      return true;
    } catch (e) {
      print('[GroupHub] Error requesting groups: $e');
      print('[GroupHub] Waiting for automatic group updates from server...');
      return false;
    }
  }
}
