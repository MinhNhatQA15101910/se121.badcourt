class GroupDto {
  final String id;
  final String name;
  final List<String> userIds;
  final List<UserDto> users;
  final List<String> connections;
  final MessageDto? lastMessage;
  final String? lastMessageAttachment; // Thêm trường này
  final bool hasMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  GroupDto({
    required this.id,
    required this.name,
    required this.userIds,
    required this.users,
    required this.connections,
    this.lastMessage,
    this.lastMessageAttachment, // Thêm parameter này
    required this.hasMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupDto.fromJson(Map<String, dynamic> json) {
    return GroupDto(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      userIds: List<String>.from(json['userIds'] ?? []),
      users: (json['users'] as List<dynamic>?)
              ?.map((user) => UserDto.fromJson(user))
              .toList() ??
          [],
      connections: List<String>.from(json['connections'] ?? []),
      lastMessage: json['lastMessage'] != null
          ? MessageDto.fromJson(json['lastMessage'])
          : null,
      lastMessageAttachment: json['lastMessageAttachment'], // Parse từ JSON
      hasMessage: json['hasMessage'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userIds': userIds,
      'users': users.map((user) => user.toJson()).toList(),
      'connections': connections,
      'lastMessage': lastMessage?.toJson(),
      'lastMessageAttachment': lastMessageAttachment,
      'hasMessage': hasMessage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class UserDto {
  final String id;
  final String username;
  final String email;
  final String? photoUrl;
  final String role;

  UserDto({
    required this.id,
    required this.username,
    required this.email,
    this.photoUrl,
    required this.role,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'photoUrl': photoUrl,
      'role': role,
    };
  }
}

class MessageDto {
  final String id;
  final String senderId;
  final String groupId; // Thêm trường groupId
  final String content;
  final DateTime messageSent;
  final String? senderUsername;
  final String? senderPhotoUrl;

  MessageDto({
    required this.id,
    required this.senderId,
    required this.groupId, // Thêm vào constructor
    required this.content,
    required this.messageSent,
    this.senderUsername,
    this.senderPhotoUrl,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) {
    return MessageDto(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      groupId: json['groupId'] ?? '', // Parse từ JSON
      content: json['content'] ?? '',
      messageSent: json['messageSent'] != null
          ? DateTime.parse(json['messageSent'])
          : DateTime.now(),
      senderUsername: json['senderUsername'],
      senderPhotoUrl: json['senderPhotoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'groupId': groupId, // Thêm vào JSON
      'content': content,
      'messageSent': messageSent.toIso8601String(),
      'senderUsername': senderUsername,
      'senderPhotoUrl': senderPhotoUrl,
    };
  }
}

