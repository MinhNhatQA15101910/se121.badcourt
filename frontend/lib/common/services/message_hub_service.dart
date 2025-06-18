import 'package:frontend/constants/global_variables.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:frontend/models/group_dto.dart';
import 'package:frontend/models/message_dto.dart';
import 'package:frontend/models/paginated_messages_dto.dart';
import 'package:frontend/models/create_message_dto.dart';
import 'dart:async';
import 'dart:convert';

class MessageHubService {
  static final MessageHubService _instance = MessageHubService._internal();
  factory MessageHubService() => _instance;
  MessageHubService._internal();

  final Map<String, HubConnection> _connections = {};
  final Map<String, bool> _connectionStates = {};

  // Updated callbacks for paginated message events
  Function(GroupDto group)? onUpdatedGroup;
  Function(PaginatedMessagesDto paginatedMessages)? onReceiveMessageThread;
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
      print('[MessageHub] Using token: ${accessToken.substring(0, 20)}...');

      final connection = HubConnectionBuilder()
          .withUrl(
        hubUrl,
        options: HttpConnectionOptions(
          accessTokenFactory: () async => accessToken,
          skipNegotiation: false,
          transport: HttpTransportType.WebSockets,
          requestTimeout: 30000, // 30 seconds
        ),
      )
          .withAutomaticReconnect(retryDelays: [0, 2000, 10000, 30000]).build();

      // Set up event listeners
      connection.on('UpdatedGroup', (arguments) {
        print('[MessageHub] Received UpdatedGroup event for user $otherUserId');
        print('[MessageHub] UpdatedGroup arguments: $arguments');
        if (arguments != null && arguments.isNotEmpty) {
          try {
            final groupData = arguments[0];
            if (groupData is Map<String, dynamic>) {
              final group = GroupDto.fromJson(groupData);
              onUpdatedGroup?.call(group);
              print('[MessageHub] UpdatedGroup processed successfully');
            } else {
              print(
                  '[MessageHub] UpdatedGroup data is not Map<String, dynamic>: ${groupData.runtimeType}');
            }
          } catch (e) {
            print('[MessageHub] Error parsing UpdatedGroup: $e');
          }
        }
      });

      connection.on('ReceiveMessageThread', (arguments) {
        print(
            '[MessageHub] Received ReceiveMessageThread event for user $otherUserId');
        print('[MessageHub] ReceiveMessageThread arguments: $arguments');

        if (arguments != null && arguments.isNotEmpty) {
          try {
            final paginatedData = arguments[0];
            print(
                '[MessageHub] Raw paginated data type: ${paginatedData.runtimeType}');
            print('[MessageHub] Raw paginated data: $paginatedData');

            if (paginatedData is Map<String, dynamic>) {
              print('[MessageHub] Processing paginated message data...');

              // Parse the paginated messages
              final paginatedMessages =
                  PaginatedMessagesDto.fromJson(paginatedData);
              print(
                  '[MessageHub] Successfully parsed ${paginatedMessages.items.length} messages on page ${paginatedMessages.currentPage}/${paginatedMessages.totalPages}');

              // Log each message for debugging
              for (int i = 0; i < paginatedMessages.items.length; i++) {
                final message = paginatedMessages.items[i];
                print(
                    '[MessageHub] Message $i: ${message.content} from ${message.senderUsername}');
              }

              // Call the callback with paginated messages
              onReceiveMessageThread?.call(paginatedMessages);
              print(
                  '[MessageHub] Called onReceiveMessageThread callback with paginated data');
            } else {
              print(
                  '[MessageHub] ReceiveMessageThread data is not Map<String, dynamic>: ${paginatedData.runtimeType}');
              // Call callback with empty paginated data to stop loading
              final emptyPaginated = PaginatedMessagesDto(
                currentPage: 1,
                totalPages: 1,
                pageSize: 20,
                totalCount: 0,
                items: [],
              );
              onReceiveMessageThread?.call(emptyPaginated);
            }
          } catch (e, stackTrace) {
            print('[MessageHub] Error parsing paginated message thread: $e');
            print('[MessageHub] Stack trace: $stackTrace');
            // Call callback with empty paginated data to stop loading
            final emptyPaginated = PaginatedMessagesDto(
              currentPage: 1,
              totalPages: 1,
              pageSize: 20,
              totalCount: 0,
              items: [],
            );
            onReceiveMessageThread?.call(emptyPaginated);
          }
        } else {
          print(
              '[MessageHub] ReceiveMessageThread called with null or empty arguments');
          // Call callback with empty paginated data to stop loading
          final emptyPaginated = PaginatedMessagesDto(
            currentPage: 1,
            totalPages: 1,
            pageSize: 20,
            totalCount: 0,
            items: [],
          );
          onReceiveMessageThread?.call(emptyPaginated);
        }
      });

      connection.on('NewMessage', (arguments) {
        print('[MessageHub] Received NewMessage event for user $otherUserId');
        print('[MessageHub] NewMessage arguments: $arguments');
        if (arguments != null && arguments.isNotEmpty) {
          try {
            final messageData = arguments[0];
            print('[MessageHub] NewMessage data: $messageData');

            Map<String, dynamic> msgJson;

            if (messageData is Map<String, dynamic>) {
              msgJson = messageData;
            } else if (messageData is String) {
              msgJson = jsonDecode(messageData);
            } else {
              print(
                  '[MessageHub] NewMessage data is unexpected type: ${messageData.runtimeType}');
              return;
            }

            // Process the message data
            final message = MessageDto.fromJson(msgJson);
            onNewMessage?.call(message);
            print('[MessageHub] NewMessage processed: ${message.content}');
          } catch (e, stackTrace) {
            print('[MessageHub] Error parsing new message: $e');
            print('[MessageHub] Stack trace: $stackTrace');
          }
        }
      });

      connection.on('NewMessageReceived', (arguments) {
        print(
            '[MessageHub] Received NewMessageReceived event for user $otherUserId');
        print('[MessageHub] NewMessageReceived arguments: $arguments');
        if (arguments != null && arguments.isNotEmpty) {
          try {
            final groupData = arguments[0];
            if (groupData is Map<String, dynamic>) {
              final group = GroupDto.fromJson(groupData);
              onNewMessageReceived?.call(group);
              print('[MessageHub] NewMessageReceived processed successfully');
            } else {
              print(
                  '[MessageHub] NewMessageReceived data is not Map<String, dynamic>: ${groupData.runtimeType}');
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

      // Sau khi kết nối thành công, server có thể tự động gửi message thread
      print('[MessageHub] Waiting for automatic message thread from server...');
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
        print(
            '[MessageHub] Error stopping connection for user $otherUserId: $e');
      }
    }
  }

  Future<void> stopAllConnections() async {
    for (final userId in _connections.keys.toList()) {
      await stopConnection(userId);
    }
    print('[MessageHub] All connections stopped');
  }

  Future<bool> sendMessage(
    String otherUserId,
    String content, {
    List<Map<String, dynamic>> resources =
        const [], // <-- Thay vì attachmentUrl
    int maxRetries = 3,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      final connection = _connections[otherUserId];

      if (connection == null) {
        print('[MessageHub] No connection found for user: $otherUserId');
        return false;
      }

      if (connection.state != HubConnectionState.Connected) {
        print(
            '[MessageHub] Connection to user $otherUserId is not active (state: ${connection.state}). Attempting to reconnect...');

        try {
          if (connection.state == HubConnectionState.Disconnected) {
            await connection.start();
            _connectionStates[otherUserId] = true;
            print('[MessageHub] Reconnected to user: $otherUserId');
            await Future.delayed(Duration(milliseconds: 1000));
          } else {
            await Future.delayed(Duration(milliseconds: 2000 * attempt));
          }
        } catch (reconnectError) {
          print(
              '[MessageHub] Failed to reconnect to user $otherUserId (attempt $attempt): $reconnectError');
          if (attempt == maxRetries) return false;
          continue;
        }
      }

      try {
        final createMessageDto = CreateMessageDto(
          recipientId: otherUserId,
          content: content,
          resources: resources, 
        );

        final messageJson = createMessageDto.toJson();
        print('[MessageHub] Sending message JSON: ${messageJson.toString()}');
        print('[MessageHub] Connection state: ${connection.state}');
        print('[MessageHub] Connection ID: ${connection.connectionId}');

        await connection.invoke('SendMessage', args: [messageJson]);
        print(
            '[MessageHub] Message sent to user: $otherUserId (attempt $attempt)');
        return true;
      } catch (e) {
        print(
            '[MessageHub] Error sending message to user $otherUserId (attempt $attempt): $e');

        if (e
                .toString()
                .contains('connection is not in the \'Connected\' State') ||
            e.toString().contains('Connection closed with an error')) {
          _connectionStates[otherUserId] = false;

          if (attempt < maxRetries) {
            print(
                '[MessageHub] Will retry sending message (attempt ${attempt + 1}/$maxRetries)');
            await Future.delayed(Duration(milliseconds: 1000 * attempt));
            continue;
          }
        }

        if (attempt == maxRetries) return false;
      }
    }

    return false;
  }

  // Request specific page of messages
  Future<bool> requestMessagePage(
      String otherUserId, int pageNumber, int pageSize) async {
    final connection = _connections[otherUserId];

    if (connection == null ||
        connection.state != HubConnectionState.Connected) {
      print('[MessageHub] Not connected to user $otherUserId');
      return false;
    }

    try {
      print(
          '[MessageHub] Requesting message page $pageNumber with size $pageSize for user $otherUserId');

      await connection.invoke('GetMessages', args: [pageNumber, pageSize]);

      print('[MessageHub] Message page request sent successfully');
      return true;
    } catch (e) {
      print('[MessageHub] Error requesting message page: $e');
      return false;
    }
  }

  bool isConnectedToUser(String otherUserId) {
    return _connectionStates[otherUserId] ?? false;
  }

  HubConnectionState? getConnectionState(String otherUserId) {
    final connection = _connections[otherUserId];
    return connection?.state;
  }

  bool isConnectionReady(String otherUserId) {
    final connection = _connections[otherUserId];
    return connection != null &&
        connection.state == HubConnectionState.Connected &&
        (_connectionStates[otherUserId] ?? false);
  }

  List<String> get connectedUsers => _connectionStates.entries
      .where((entry) => entry.value)
      .map((entry) => entry.key)
      .toList();

  bool get hasActiveConnections =>
      _connectionStates.values.any((state) => state);

  int get activeConnectionsCount =>
      _connectionStates.values.where((state) => state).length;

  String getConnectionStateString(String otherUserId) {
    final connection = _connections[otherUserId];
    if (connection == null) return 'Not initialized';
    return connection.state.toString();
  }

  Future<bool> ensureConnection(String accessToken, String otherUserId) async {
    if (isConnectionReady(otherUserId)) {
      return true;
    }

    print('[MessageHub] Ensuring connection to user: $otherUserId');

    try {
      final existingConnection = _connections[otherUserId];
      if (existingConnection != null &&
          existingConnection.state != HubConnectionState.Connected) {
        await existingConnection.start();
        _connectionStates[otherUserId] = true;
        return true;
      }

      if (existingConnection == null) {
        await startConnection(accessToken, otherUserId);
        return isConnectionReady(otherUserId);
      }

      return false;
    } catch (e) {
      print(
          '[MessageHub] Failed to ensure connection to user $otherUserId: $e');
      return false;
    }
  }
}
