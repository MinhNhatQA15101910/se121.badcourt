import 'package:frontend/constants/global_variables.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:frontend/models/group_dto.dart';
import 'package:frontend/models/message_dto.dart';
import 'package:frontend/models/create_message_dto.dart';
import 'dart:async';
import 'dart:convert';

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
          .withAutomaticReconnect(retryDelays: [0, 2000, 10000, 30000])
          .build();

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
              print('[MessageHub] UpdatedGroup data is not Map<String, dynamic>: ${groupData.runtimeType}');
            }
          } catch (e) {
            print('[MessageHub] Error parsing UpdatedGroup: $e');
          }
        }
      });

      connection.on('ReceiveMessageThread', (arguments) {
        print('[MessageHub] Received ReceiveMessageThread event for user $otherUserId');
        print('[MessageHub] ReceiveMessageThread arguments: $arguments');
        
        if (arguments != null && arguments.isNotEmpty) {
          try {
            final messagesData = arguments[0];
            print('[MessageHub] Raw messages data type: ${messagesData.runtimeType}');
            print('[MessageHub] Raw messages data: $messagesData');
            
            List<MessageDto> messages = [];
            
            if (messagesData is List) {
              print('[MessageHub] Processing ${messagesData.length} messages');
              
              for (int i = 0; i < messagesData.length; i++) {
                try {
                  final msgData = messagesData[i];
                  print('[MessageHub] Processing message $i: $msgData');
                  
                  Map<String, dynamic> msgJson;
                  
                  // Handle different data types
                  if (msgData is Map<String, dynamic>) {
                    msgJson = msgData;
                  } else if (msgData is String) {
                    // If it's a JSON string, parse it
                    msgJson = jsonDecode(msgData);
                  } else {
                    print('[MessageHub] Unexpected message data type: ${msgData.runtimeType}');
                    continue;
                  }
                  
                  // Ensure required fields exist and have correct types
                  final processedJson = {
                    'id': msgJson['id']?.toString() ?? '',
                    'senderId': msgJson['senderId']?.toString() ?? '',
                    'groupId': msgJson['groupId']?.toString() ?? '',
                    'content': msgJson['content']?.toString() ?? '',
                    'messageSent': msgJson['messageSent']?.toString() ?? DateTime.now().toIso8601String(),
                    'senderUsername': msgJson['senderUsername']?.toString(),
                    'senderMessageUrl': msgJson['senderMessageUrl']?.toString(),
                    'dateRead': msgJson['dateRead']?.toString(),
                  };
                  
                  print('[MessageHub] Processed JSON for message $i: $processedJson');
                  
                  final message = MessageDto.fromJson(processedJson);
                  messages.add(message);
                  print('[MessageHub] Successfully parsed message $i: ${message.content}');
                  
                } catch (e, stackTrace) {
                  print('[MessageHub] Error parsing message $i: $e');
                  print('[MessageHub] Stack trace: $stackTrace');
                  // Continue processing other messages even if one fails
                }
              }
              
              print('[MessageHub] Successfully processed ${messages.length} out of ${messagesData.length} messages');
              
              // Call the callback with parsed messages
              if (messages.isNotEmpty) {
                onReceiveMessageThread?.call(messages);
                print('[MessageHub] Called onReceiveMessageThread callback with ${messages.length} messages');
              } else {
                print('[MessageHub] No valid messages to display');
                // Still call callback with empty list to stop loading indicator
                onReceiveMessageThread?.call([]);
              }
              
            } else {
              print('[MessageHub] ReceiveMessageThread data is not List: ${messagesData.runtimeType}');
              // Call callback with empty list to stop loading
              onReceiveMessageThread?.call([]);
            }
            
          } catch (e, stackTrace) {
            print('[MessageHub] Error parsing message thread: $e');
            print('[MessageHub] Stack trace: $stackTrace');
            // Call callback with empty list to stop loading
            onReceiveMessageThread?.call([]);
          }
        } else {
          print('[MessageHub] ReceiveMessageThread called with null or empty arguments');
          // Call callback with empty list to stop loading
          onReceiveMessageThread?.call([]);
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
              print('[MessageHub] NewMessage data is unexpected type: ${messageData.runtimeType}');
              return;
            }
            
            // Process the message data
            final processedJson = {
              'id': msgJson['id']?.toString() ?? '',
              'senderId': msgJson['senderId']?.toString() ?? '',
              'groupId': msgJson['groupId']?.toString() ?? '',
              'content': msgJson['content']?.toString() ?? '',
              'messageSent': msgJson['messageSent']?.toString() ?? DateTime.now().toIso8601String(),
              'senderUsername': msgJson['senderUsername']?.toString(),
              'senderMessageUrl': msgJson['senderMessageUrl']?.toString(),
              'dateRead': msgJson['dateRead']?.toString(),
            };
            
            final message = MessageDto.fromJson(processedJson);
            onNewMessage?.call(message);
            print('[MessageHub] NewMessage processed: ${message.content}');
            
          } catch (e, stackTrace) {
            print('[MessageHub] Error parsing new message: $e');
            print('[MessageHub] Stack trace: $stackTrace');
          }
        }
      });

      connection.on('NewMessageReceived', (arguments) {
        print('[MessageHub] Received NewMessageReceived event for user $otherUserId');
        print('[MessageHub] NewMessageReceived arguments: $arguments');
        if (arguments != null && arguments.isNotEmpty) {
          try {
            final groupData = arguments[0];
            if (groupData is Map<String, dynamic>) {
              final group = GroupDto.fromJson(groupData);
              onNewMessageReceived?.call(group);
              print('[MessageHub] NewMessageReceived processed successfully');
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

  Future<bool> sendMessage(String otherUserId, String content, {String? attachmentUrl, int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      final connection = _connections[otherUserId];
    
      if (connection == null) {
        print('[MessageHub] No connection found for user: $otherUserId');
        return false;
      }
    
      // Kiểm tra connection state
      if (connection.state != HubConnectionState.Connected) {
        print('[MessageHub] Connection to user $otherUserId is not active (state: ${connection.state}). Attempting to reconnect...');
      
        try {
          if (connection.state == HubConnectionState.Disconnected) {
            await connection.start();
            _connectionStates[otherUserId] = true;
            print('[MessageHub] Reconnected to user: $otherUserId');
            
            // Đợi một chút để connection ổn định
            await Future.delayed(Duration(milliseconds: 1000));
          } else {
            // Đợi connection reconnect tự động
            await Future.delayed(Duration(milliseconds: 2000 * attempt));
          }
        } catch (reconnectError) {
          print('[MessageHub] Failed to reconnect to user $otherUserId (attempt $attempt): $reconnectError');
          if (attempt == maxRetries) {
            return false;
          }
          continue;
        }
      }

      // Thử gửi tin nhắn
      try {
        final createMessageDto = CreateMessageDto(
          recipientId: otherUserId,
          content: content,
          attachmentUrl: attachmentUrl,
        );
        
        // Hiển thị JSON trước khi gửi
        final messageJson = createMessageDto.toJson();
        print('[MessageHub] Sending message JSON: ${messageJson.toString()}');
        
        // Hiển thị chi tiết connection
        print('[MessageHub] Connection state: ${connection.state}');
        print('[MessageHub] Connection ID: ${connection.connectionId}');
        
        await connection.invoke('SendMessage', args: [messageJson]);
        print('[MessageHub] Message sent to user: $otherUserId (attempt $attempt)');
        return true;
        
      } catch (e) {
        print('[MessageHub] Error sending message to user $otherUserId (attempt $attempt): $e');
        
        // Nếu lỗi do connection, đánh dấu là disconnected
        if (e.toString().contains('connection is not in the \'Connected\' State') ||
            e.toString().contains('Connection closed with an error')) {
          _connectionStates[otherUserId] = false;
          
          if (attempt < maxRetries) {
            print('[MessageHub] Will retry sending message (attempt ${attempt + 1}/$maxRetries)');
            await Future.delayed(Duration(milliseconds: 1000 * attempt));
            continue;
          }
        }
        
        if (attempt == maxRetries) {
          return false;
        }
      }
    }
    
    return false;
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

  bool get hasActiveConnections => _connectionStates.values.any((state) => state);

  int get activeConnectionsCount => _connectionStates.values.where((state) => state).length;

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
      if (existingConnection != null && existingConnection.state != HubConnectionState.Connected) {
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
      print('[MessageHub] Failed to ensure connection to user $otherUserId: $e');
      return false;
    }
  }
}
