import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket?
      socket; // Change to nullable type to avoid late initialization error

  // Make sure to initialize socket in the connect method
  void connect(String token) {
    socket = IO.io('ws://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'extraHeaders': {'Authorization': 'Bearer $token'},
    });

    socket?.onConnect((_) {
      print('Connected to socket server');
    });

    socket?.onDisconnect((_) {
      print('Disconnected from socket server');
    });
  }

  void enterRoom(String roomId) {
    if (socket != null) {
      socket?.emit('enterRoom', roomId);
    } else {
      print('Socket not initialized');
    }
  }

  void sendMessage(String roomId, String content) {
    if (socket != null) {
      socket?.emit('sendMessage', {'roomId': roomId, 'content': content});
    } else {
      print('Socket not initialized');
    }
  }

  void onNewMessage(Function(dynamic) callback) {
    if (socket != null) {
      socket?.on('newMessage', callback);
    } else {
      print('Socket not initialized');
    }
  }
}
