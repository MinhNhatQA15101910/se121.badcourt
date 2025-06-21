import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/group_dto.dart';
import 'package:frontend/models/message_dto.dart';
import 'package:frontend/models/paginated_groups_dto.dart';
import 'package:signalr_netcore/signalr_client.dart';

class GroupHubService {
  static final GroupHubService _instance = GroupHubService._internal();
  factory GroupHubService() => _instance;
  GroupHubService._internal();

  HubConnection? _connection;
  bool _isConnected = false;

  // Callbacks - Updated to handle paginated data
  Function(PaginatedGroupsDto paginatedGroups)? onReceiveGroups;
  Function(MessageDto message)? onNewMessage; // Có thể null để tránh duplicate
  Function(GroupDto group)? onGroupUpdated;
  Function(GroupDto group)? onNewMessageReceived;
  Function(int count)? onReceiveNumberOfUnreadMessages;

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
            print(
                '[GroupHub] Paginated data type: ${paginatedData.runtimeType}');
            print('[GroupHub] Paginated data: $paginatedData');

            if (paginatedData is Map<String, dynamic>) {
              final paginatedGroups =
                  PaginatedGroupsDto.fromJson(paginatedData);
              onReceiveGroups?.call(paginatedGroups);
              print(
                  '[GroupHub] Received paginated groups: ${paginatedGroups.items.length} groups on page ${paginatedGroups.currentPage}/${paginatedGroups.totalPages}');

              // Log each group for debugging
              for (int i = 0; i < paginatedGroups.items.length; i++) {
                final group = paginatedGroups.items[i];
                print(
                    '[GroupHub] Group $i: ${group.name} with ${group.users.length} users, lastMessage: ${group.lastMessage?.content}');
              }
            } else {
              print(
                  '[GroupHub] Paginated data is not Map<String, dynamic>: ${paginatedData.runtimeType}');
            }
          } catch (e, stackTrace) {
            print('[GroupHub] Error parsing paginated groups: $e');
            print('[GroupHub] Stack trace: $stackTrace');
          }
        } else {
          print('[GroupHub] No paginated groups data received');
        }
      });

      // Chỉ listen NewMessage nếu callback được set (để tránh duplicate)
      _connection!.on('NewMessage', (arguments) {
        print('[GroupHub] Received NewMessage event');
        if (onNewMessage != null && arguments != null && arguments.isNotEmpty) {
          try {
            final messageData = arguments[0];
            if (messageData is Map<String, dynamic>) {
              final message = MessageDto.fromJson(messageData);
              onNewMessage!(message);
              print('[GroupHub] NewMessage processed: ${message.senderId}');
            }
          } catch (e) {
            print('[GroupHub] Error parsing NewMessage: $e');
          }
        } else {
          print('[GroupHub] NewMessage callback not set or no data, skipping');
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

      // Primary event listener cho NewMessageReceived
      _connection!.on('NewMessageReceived', (arguments) {
        print('[GroupHub] Received NewMessageReceived event');
        print('[GroupHub] Arguments: $arguments');

        if (arguments != null && arguments.isNotEmpty) {
          try {
            final groupData = arguments[0];
            if (groupData is Map<String, dynamic>) {
              final group = GroupDto.fromJson(groupData);
              
              // Log chi tiết để debug
              print('[GroupHub] NewMessageReceived - Group: ${group.id}');
              if (group.lastMessage != null) {
                print('[GroupHub] NewMessageReceived - Message ID: ${group.lastMessage!.id}');
                print('[GroupHub] NewMessageReceived - Message content: ${group.lastMessage!.content}');
                print('[GroupHub] NewMessageReceived - Sender: ${group.lastMessage!.senderUsername}');
                print('[GroupHub] NewMessageReceived - Sent at: ${group.lastMessage!.messageSent}');
              }
              
              onNewMessageReceived?.call(group);
              print('[GroupHub] NewMessageReceived processed successfully');
            }
          } catch (e) {
            print('[GroupHub] Error parsing NewMessageReceived: $e');
          }
        }
      });

      _connection!.on('ReceiveNumberOfUnreadMessages', (arguments) {
        print('[GroupHub] Received ReceiveNumberOfUnreadMessages event');
        print('[GroupHub] Arguments: $arguments');

        if (arguments != null && arguments.isNotEmpty) {
          final countRaw = arguments[0];
          if (countRaw is int) {
            onReceiveNumberOfUnreadMessages?.call(countRaw);
            print('[GroupHub] Unread message count: $countRaw');
          } else if (countRaw is String) {
            final count = int.tryParse(countRaw);
            if (count != null) {
              onReceiveNumberOfUnreadMessages?.call(count);
              print('[GroupHub] Unread message count (parsed): $count');
            } else {
              print(
                  '[GroupHub] Unable to parse unread message count: $countRaw');
            }
          } else {
            print('[GroupHub] Unexpected data type: ${countRaw.runtimeType}');
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
