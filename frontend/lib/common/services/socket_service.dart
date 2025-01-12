import 'package:frontend/constants/global_variables.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  // Singleton instance
  static final SocketService _instance = SocketService._internal();

  // Socket instance
  IO.Socket? _socket;

  // Private constructor
  SocketService._internal();

  // Factory constructor
  factory SocketService() {
    return _instance;
  }

  // Getter for socket
  IO.Socket? get socket => _socket;

  // Kết nối socket với token và userId
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
    } else {
      print('Socket already connected');
    }
  }

  // Ngắt kết nối socket
  void disconnect() {
    _socket?.disconnect();
    print('Socket disconnected manually');
  }

  /// Lắng nghe sự kiện nhận tin nhắn mới
  void onNewMessage(Function(dynamic) callback) {
    if (socket != null) {
      socket?.on('newMessage', callback);
      print('Listener added for newMessage event');
    } else {
      print('Socket is null');
    }
  }

  /// Gửi tin nhắn với hình ảnh tới phòng (hỗ trợ không có hình ảnh)
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
