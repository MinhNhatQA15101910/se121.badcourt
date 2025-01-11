// socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? socket;

  // Connect to the socket server
  void connect(String token) {
    socket = IO.io('ws://192.168.137.1:3000', <String, dynamic>{
      'transports': ['websocket'],
      'extraHeaders': {'Authorization': 'Bearer $token'},
    });

    socket?.onConnect((_) {
      print('Connected to socket server');
    });

    socket?.onDisconnect((_) {
      print('Disconnected from socket server');
    });

    socket?.onError((error) {
      print('Socket error: $error');
    });

    socket?.onReconnect((_) {
      print('Reconnected to socket server');
    });

    socket?.onReconnectAttempt((_) {
      print('Attempting to reconnect to socket server');
    });
  }

  void disconnect() {
    socket?.disconnect();
    print('Socket disconnected manually');
  }

  void enterRoom(String roomId) {
    if (socket != null) {
      socket?.emit('enterRoom', roomId);
      print('Entered room: $roomId');
    } else {
      print('Socket not initialized');
    }
  }

  void leaveRoom(String roomId) {
    if (socket != null) {
      socket?.emit('leaveRoom', roomId);
      print('Left room: $roomId');
    } else {
      print('Socket not initialized');
    }
  }

  void sendMessage(String roomId, String content) {
    if (socket != null) {
      socket?.emit('sendMessage', {'roomId': roomId, 'content': content});
      print('Message sent to room: $roomId');
    } else {
      print('Socket not initialized');
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

  void removeListener(String event) {
    socket?.off(event);
    print('Listener removed for event: $event');
  }
}
