class GroupDto {
  final String id;
  final String name;
  final List<String> userIds;
  final List<UserDto> users;
  final List<ConnectionDto> connections;
  final MessageDto? lastMessage;
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
    required this.hasMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupDto.fromJson(Map<String, dynamic> json) {
    return GroupDto(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      userIds: List<String>.from(json['userIds'] ?? []),
      users: (json['users'] as List?)?.map((user) => UserDto.fromJson(user)).toList() ?? [],
      connections: (json['connections'] as List?)?.map((conn) => ConnectionDto.fromJson(conn)).toList() ?? [],
      lastMessage: json['lastMessage'] != null ? MessageDto.fromJson(json['lastMessage']) : null,
      hasMessage: json['hasMessage'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class MessageDto {
  final String id;
  final String groupId;
  final String senderId;
  final String senderUsername;
  final String senderImageUrl;
  final String content;
  final DateTime? dateRead;
  final DateTime messageSent;

  MessageDto({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderUsername,
    required this.senderImageUrl,
    required this.content,
    this.dateRead,
    required this.messageSent,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) {
    return MessageDto(
      id: json['id'] ?? '',
      groupId: json['groupId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderUsername: json['senderUsername'] ?? '',
      senderImageUrl: json['senderImageUrl'] ?? '',
      content: json['content'] ?? '',
      dateRead: json['dateRead'] != null ? DateTime.parse(json['dateRead']) : null,
      messageSent: DateTime.parse(json['messageSent']),
    );
  }
}

class ConnectionDto {
  final String connectionId;
  final String groupId;
  final String userId;

  ConnectionDto({
    required this.connectionId,
    required this.groupId,
    required this.userId,
  });

  factory ConnectionDto.fromJson(Map<String, dynamic> json) {
    return ConnectionDto(
      connectionId: json['connectionId'] ?? '',
      groupId: json['groupId'] ?? '',
      userId: json['userId'] ?? '',
    );
  }
}

class UserDto {
  final String id;
  final String username;
  final String email;
  final String? photoUrl;

  UserDto({
    required this.id,
    required this.username,
    required this.email,
    this.photoUrl,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
    );
  }
}

class CreateMessageDto {
  final String recipientId;
  final String content;

  CreateMessageDto({
    required this.recipientId,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'recipientId': recipientId,
      'content': content,
    };
  }
}