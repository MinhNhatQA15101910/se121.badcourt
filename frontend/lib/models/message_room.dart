class MessageRoom {
  final String id;
  final List<User> users;
  final DateTime updatedAt;
  final LastMessage? lastMessage;
  MessageRoom({
    required this.id,
    required this.users,
    required this.updatedAt,
    this.lastMessage,
  });

  factory MessageRoom.fromMap(Map<String, dynamic> map) {
    return MessageRoom(
      id: map['_id'] ?? '',
      users: List<User>.from(map['users']?.map((x) => User.fromMap(x)) ?? []),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      lastMessage: map['lastMessage'] != null
          ? LastMessage.fromMap(map['lastMessage'])
          : null,
    );
  }

  // Thêm phương thức fromJsonList
  static List<MessageRoom> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => MessageRoom.fromMap(json)).toList();
  }
}

class User {
  final String id;
  final String username;
  final String email;
  final String imageUrl;
  final String role;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.imageUrl,
    required this.role,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] ?? '',
      username: map['username'] ?? 'Unknown', // Giá trị mặc định
      email: map['email'] ?? 'No Email', // Giá trị mặc định
      imageUrl: map['imageUrl'] ?? '', // Giá trị mặc định
      role: map['role'] ?? 'Unknown', // Giá trị mặc định
    );
  }
}

class LastMessage {
  final String id;
  final String content;
  final String senderId;
  final String roomId;
  final DateTime createdAt;
  final DateTime updatedAt;

  LastMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.roomId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LastMessage.fromMap(Map<String, dynamic> map) {
    return LastMessage(
      id: map['_id'] ?? '',
      content: map['content'] ?? '',
      senderId: map['senderId'] ?? '',
      roomId: map['roomId'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : DateTime.now(),
    );
  }
}
