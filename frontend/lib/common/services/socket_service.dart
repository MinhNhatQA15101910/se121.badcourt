import 'package:frontend/constants/global_variables.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();

  IO.Socket? _socket;

  SocketService._internal();

  factory SocketService() {
    return _instance;
  }

  IO.Socket? get socket => _socket;

  void connect(String token, String userId) {
    if (_socket == null || !_socket!.connected) {
      _socket = IO.io('ws://${ipconfig}:3000', <String, dynamic>{
        'transports': ['websocket'],
        'extraHeaders': {'Authorization': 'Bearer $token'},
      });

      _socket?.onConnect((_) {
        print('Connected to socket server');
        _socket?.emit('login', userId);
        print('Socket sent login');
      });

      _socket?.onDisconnect((_) {
        print('Disconnected from socket server');
      });

      _socket?.onError((error) {
        print('Socket error: $error');
      });

      _socket?.onReconnect((_) {
        print('Reconnected to socket server');
      });

      _socket?.onReconnectAttempt((_) {
        print('Attempting to reconnect to socket server');
      });

      _socket?.on('invokeEnterRoom', (roomId) {
        print('Socket Received invokeEnterRoom event with roomId: $roomId');
        enterRoom(roomId);
      });
    } else {
      print('Socket already connected');
    }
  }

  void disconnect() {
    _socket?.disconnect();
    print('Socket disconnected manually');
  }

  void enterRoom(String roomId) {
    if (socket != null && socket!.connected) {
      _socket?.emit('enterRoom', roomId);
      print('Request sent to enter room: $roomId');
    } else {
      print('Socket not connected');
    }
  }

  void onNewMessage(Function(dynamic) callback) {
    if (socket != null) {
      socket?.on('newMessage', callback);
      print('Listener added for newMessage event');
    } else {
      print('Socket is null');
    }
  }

  void sendMessageWithImages(String roomId, String content,
      [List<String>? imagePaths]) {
    if (socket != null && socket!.connected) {
      final payload = {
        'roomId': roomId,
        'content': content,
        'resources': imagePaths,
      };

      socket?.emit('sendMessage', payload);
      print('Message with or without images sent to room: $roomId');
    } else {
      print('Socket not connected');
    }
  }
}
