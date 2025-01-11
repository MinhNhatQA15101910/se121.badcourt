import 'package:frontend/constants/global_variables.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? socket;

  /// Kết nối tới socket server với token
  void connect(String token) {
    if (socket != null && socket!.connected) {
      print('Socket already connected');
      return;
    }

    socket = IO.io(
      'ws://localhost:3000',
      <String, dynamic>{
        'transports': ['websocket'],
        'extraHeaders': {'Authorization': 'Bearer $token'},
        'autoConnect': true,
      },
    );

    // Các sự kiện mặc định
    socket?.onConnect((_) => print('Connected to socket server'));
    socket?.onDisconnect((_) => print('Disconnected from socket server'));
    socket?.onError((error) => print('Socket error: $error'));
    socket?.onReconnect((_) => print('Reconnected to socket server'));
    socket?.onReconnectAttempt(
        (_) => print('Attempting to reconnect to socket server'));
  }

  /// Ngắt kết nối socket
  void disconnect() {
    socket?.disconnect();
    print('Socket disconnected manually');
  }

  /// Tham gia vào một phòng
  void enterRoom(String roomId) {
    if (socket != null && socket!.connected) {
      socket?.emit('enterRoom', {'roomId': roomId});
      print('Entered room: $roomId');
    } else {
      print('Socket not connected');
    }
  }

  /// Rời khỏi một phòng
  void leaveRoom(String roomId) {
    if (socket != null && socket!.connected) {
      socket?.emit('leaveRoom', {'roomId': roomId});
      print('Left room: $roomId');
    } else {
      print('Socket not connected');
    }
  }

  /// Gửi tin nhắn tới phòng
  void sendMessage(String roomId, String content) {
    if (socket != null && socket!.connected) {
      socket?.emit('sendMessage', {'roomId': roomId, 'content': content});
      print('Message sent to room: $roomId');
    } else {
      print('Socket not connected');
    }
  }

  /// Gửi tin nhắn với hình ảnh tới phòng (hỗ trợ không có hình ảnh)
  void sendMessageWithImages(String roomId, String content,
      [List<String>? imagePaths]) {
    if (socket != null && socket!.connected) {
      final payload = {
        'roomId': roomId,
        'content': content,
        'resources': imagePaths, // Không cần mã hóa JSON tại đây
      };

      socket?.emit('sendMessage', payload);
      print('Message with or without images sent to room: $roomId');
    } else {
      print('Socket not connected');
    }
  }

  /// Lắng nghe sự kiện nhận tin nhắn mới
  void onNewMessage(Function(dynamic) callback) {
    if (socket != null) {
      socket?.on('newMessage', (data) {
        print('New message received: $data');
        callback(data);
      });
      print('Listener added for newMessage event');
    } else {
      print('Socket is null');
    }
  }

  /// Lắng nghe sự kiện lỗi
  void onError(Function(dynamic) callback) {
    if (socket != null) {
      socket?.on('error', callback);
      print('Listener added for error event');
    } else {
      print('Socket is null');
    }
  }

  /// Xóa listener cho sự kiện cụ thể
  void removeListener(String event) {
    socket?.off(event);
    print('Listener removed for event: $event');
  }
}
