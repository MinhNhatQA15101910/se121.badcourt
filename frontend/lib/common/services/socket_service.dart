import 'package:frontend/models/message_room.dart';
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
    
  }

  void disconnect() {
    
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

  void onMessageRoomUpdate(Function(dynamic) callback) {
    if (socket != null) {
      socket?.on('messageRoom', (data) {
        try {
          final messageRoom = MessageRoom.fromMap(data);
          callback(messageRoom);
          print('Received and parsed MessageRoom data');
        } catch (e) {
          print('Error parsing MessageRoom data: $e');
        }
      });
      print('Listener added for messageRoomUpdate event');
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
