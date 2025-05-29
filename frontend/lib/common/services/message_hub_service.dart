import 'package:frontend/constants/global_variables.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:frontend/models/group_dto.dart';

class MessageHubService {
  static final MessageHubService _instance = MessageHubService._internal();
  factory MessageHubService() => _instance;
  MessageHubService._internal();

  final Map<String, HubConnection> _connections = {};
  final Map<String, bool> _connectionStates = {};

  // Callbacks for message events
  Function(GroupDto group)? onUpdatedGroup;
  Function(List<MessageDto> messages)? onReceiveMessageThread;
  Function(MessageDto message)? onNewMessage;
  Function(GroupDto group)? onNewMessageReceived;

  Future<void> startConnection(String accessToken, String otherUserId) async {
    if (_connectionStates[otherUserId] == true) {
      print('[MessageHub] Already connected to user: $otherUserId');
      return;
    }

    try {
      final hubUrl = '$signalrUri/hubs/message?user=$otherUserId';
      print('[MessageHub] Connecting to: $hubUrl');
      
      final connection = HubConnectionBuilder()
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
      connection.on('UpdatedGroup', (arguments) {
        print('[MessageHub] Received UpdatedGroup event: $arguments');
        if (arguments != null && arguments.isNotEmpty) {
          try {
            final groupData = arguments[0];
            // Safe casting với kiểm tra kiểu
            if (groupData is Map<String, dynamic>) {
              final group = GroupDto.fromJson(groupData);
              onUpdatedGroup?.call(group);
            } else {
              print('[MessageHub] UpdatedGroup data is not Map<String, dynamic>: ${groupData.runtimeType}');
            }
          } catch (e) {
            print('[MessageHub] Error parsing UpdatedGroup: $e');
          }
        }
      });

      connection.on('ReceiveMessageThread', (arguments) {
        print('[MessageHub] Received ReceiveMessageThread event: $arguments');
        if (arguments != null && arguments.isNotEmpty) {
          try {
            final messagesData = arguments[0];
            if (messagesData is List) {
              final messages = messagesData.map((msgJson) {
                if (msgJson is Map<String, dynamic>) {
                  return MessageDto.fromJson(msgJson);
                } else {
                  throw Exception('Message data is not Map<String, dynamic>');
                }
              }).toList();
              onReceiveMessageThread?.call(messages);
              print('[MessageHub] Received ${messages.length} messages');
            } else {
              print('[MessageHub] ReceiveMessageThread data is not List: ${messagesData.runtimeType}');
            }
          } catch (e) {
            print('[MessageHub] Error parsing message thread: $e');
          }
        }
      });

      connection.on('NewMessage', (arguments) {
        print('[MessageHub] Received NewMessage event: $arguments');
        if (arguments != null && arguments.isNotEmpty) {
          try {
            final messageData = arguments[0];
            if (messageData is Map<String, dynamic>) {
              final message = MessageDto.fromJson(messageData);
              onNewMessage?.call(message);
            } else {
              print('[MessageHub] NewMessage data is not Map<String, dynamic>: ${messageData.runtimeType}');
            }
          } catch (e) {
            print('[MessageHub] Error parsing new message: $e');
          }
        }
      });

      connection.on('NewMessageReceived', (arguments) {
        print('[MessageHub] Received NewMessageReceived event: $arguments');
        if (arguments != null && arguments.isNotEmpty) {
          try {
            final groupData = arguments[0];
            if (groupData is Map<String, dynamic>) {
              final group = GroupDto.fromJson(groupData);
              onNewMessageReceived?.call(group);
            } else {
              print('[MessageHub] NewMessageReceived data is not Map<String, dynamic>: ${groupData.runtimeType}');
            }
          } catch (e) {
            print('[MessageHub] Error parsing NewMessageReceived: $e');
          }
        }
      });

      // Start connection
      await connection.start();
      _connections[otherUserId] = connection;
      _connectionStates[otherUserId] = true;
      print('✅ [MessageHub] Connected to user: $otherUserId');
      
    } catch (e) {
      print('❌ [MessageHub] Connection failed for user $otherUserId: $e');
      _connectionStates[otherUserId] = false;
      rethrow;
    }
  }

  Future<void> stopConnection(String otherUserId) async {
    final connection = _connections[otherUserId];
    if (connection != null) {
      try {
        await connection.stop();
        _connections.remove(otherUserId);
        _connectionStates[otherUserId] = false;
        print('[MessageHub] Disconnected from user: $otherUserId');
      } catch (e) {
        print('[MessageHub] Error stopping connection for user $otherUserId: $e');
      }
    }
  }

  Future<void> stopAllConnections() async {
    for (final userId in _connections.keys.toList()) {
      await stopConnection(userId);
    }
    print('[MessageHub] All connections stopped');
  }

  Future<bool> sendMessage(String otherUserId, String content) async {
    final connection = _connections[otherUserId];
    if (connection == null || !(_connectionStates[otherUserId] ?? false)) {
      print('[MessageHub] No connection to user: $otherUserId');
      return false;
    }

    try {
      final createMessageDto = CreateMessageDto(
        recipientId: otherUserId,
        content: content,
      );

      await connection.invoke('SendMessage', args: [createMessageDto.toJson()]);
      print('[MessageHub] Message sent to user: $otherUserId');
      return true;
    } catch (e) {
      print('[MessageHub] Error sending message to user $otherUserId: $e');
      return false;
    }
  }

  bool isConnectedToUser(String otherUserId) {
    return _connectionStates[otherUserId] ?? false;
  }

  List<String> get connectedUsers => _connectionStates.entries
      .where((entry) => entry.value)
      .map((entry) => entry.key)
      .toList();
}