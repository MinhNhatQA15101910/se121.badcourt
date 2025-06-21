import 'dart:io';
import 'dart:typed_data';

import 'package:frontend/constants/global_variables.dart';
import 'package:mime/mime.dart';
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
    List<File> attachments = const [],
    int maxRetries = 3,
  }) async {
    print('[MessageHub] sendMessage called with:');
    print('[MessageHub] - otherUserId: $otherUserId');
    print('[MessageHub] - content: $content');
    print('[MessageHub] - attachments count: ${attachments.length}');

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
        // Convert File objects to base64 strings
        List<String> base64Resources = [];

        print('[MessageHub] Processing ${attachments.length} attachments...');

        for (int i = 0; i < attachments.length; i++) {
          File file = attachments[i];
          try {
            print('[MessageHub] Processing file $i: ${file.path}');

            // Check if file exists
            if (!await file.exists()) {
              print('[MessageHub] File does not exist: ${file.path}');
              continue;
            }

            // Read file as bytes and convert to base64

            Uint8List fileBytes = await file.readAsBytes();
            final mimeType = lookupMimeType(file.path);
            String base64String = base64Encode(fileBytes);
            String fullBase64 = "data:$mimeType;base64,$base64String";

            // Get file info for logging
            String fileName = file.path.split('/').last;
            String fileExtension = fileName.split('.').last.toLowerCase();
            String contentType = _getContentType(fileExtension);

            // Add base64 string to resources
            base64Resources.add(fullBase64);

            print(
                '[MessageHub] Successfully processed attachment $i: $fileName (${fileBytes.length} bytes, $contentType)');
          } catch (fileError) {
            print(
                '[MessageHub] Error processing file ${file.path}: $fileError');
            // Continue with other files even if one fails
          }
        }

        print(
            '[MessageHub] Final base64Resources count: ${base64Resources.length}');

        // Create message DTO with base64 resources
        final createMessageDto = CreateMessageDto(
          recipientId: otherUserId,
          content: content,
          base64Resources: base64Resources,
        );

        final messageJson = createMessageDto.toJson();

        // Debug the final JSON (don't log full base64 strings as they're very long)
        print('[MessageHub] CreateMessageDto JSON:');
        print('[MessageHub] - recipientId: ${messageJson['recipientId']}');
        print('[MessageHub] - content: ${messageJson['content']}');
        print(
            '[MessageHub] - base64Resources count: ${(messageJson['base64Resources'] as List).length}');

        // Log first few characters of each base64 string for debugging
        for (int i = 0; i < base64Resources.length; i++) {
          final preview = base64Resources[i].length > 50
              ? '${base64Resources[i].substring(0, 50)}...'
              : base64Resources[i];
          print('[MessageHub] - base64Resources[$i]: $preview');
        }

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

  // Helper method to determine content type based on file extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  // Convenience methods
  Future<bool> sendMessageWithAttachment(
    String otherUserId,
    String content,
    File attachment,
  ) async {
    return sendMessage(otherUserId, content, attachments: [attachment]);
  }

  Future<bool> sendMessageWithAttachments(
    String otherUserId,
    String content,
    List<File> attachments,
  ) async {
    return sendMessage(otherUserId, content, attachments: attachments);
  }

  // Keep all your existing utility methods unchanged...
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
