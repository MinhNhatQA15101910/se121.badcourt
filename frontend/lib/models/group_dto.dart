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
  
  @override
  String toString() {
    return 'UserDto{id: $id, username: $username, email: $email, role: $role}';
  }
}


class MessageDto {
  final String id;
  final String senderId;
  final String groupId;
  final String content;
  final DateTime messageSent;
  final String? senderUsername;
  final String? senderPhotoUrl;
  final DateTime? dateRead;

  MessageDto({
    required this.id,
    required this.senderId,
    required this.groupId,
    required this.content,
    required this.messageSent,
    this.senderUsername,
    this.senderPhotoUrl,
    this.dateRead,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) {
    try {
      return MessageDto(
        id: json['id']?.toString() ?? '',
        senderId: json['senderId']?.toString() ?? '',
        groupId: json['groupId']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        messageSent: json['messageSent'] != null
            ? DateTime.parse(json['messageSent'].toString())
            : DateTime.now(),
        senderUsername: json['senderUsername']?.toString(),
        senderPhotoUrl: json['senderMessageUrl']?.toString(), // Note: server uses 'senderMessageUrl'
        dateRead: json['dateRead'] != null && json['dateRead'].toString().isNotEmpty
            ? DateTime.parse(json['dateRead'].toString())
            : null,
      );
    } catch (e, stackTrace) {
      print('Error parsing MessageDto from JSON: $e');
      print('JSON data: $json');
      print('Stack trace: $stackTrace');
      
      // Return a default MessageDto to prevent crashes
      return MessageDto(
        id: json['id']?.toString() ?? 'unknown',
        senderId: json['senderId']?.toString() ?? 'unknown',
        groupId: json['groupId']?.toString() ?? 'unknown',
        content: json['content']?.toString() ?? 'Error loading message',
        messageSent: DateTime.now(),
        senderUsername: json['senderUsername']?.toString() ?? 'Unknown',
        senderPhotoUrl: null,
        dateRead: null,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'groupId': groupId,
      'content': content,
      'messageSent': messageSent.toIso8601String(),
      'senderUsername': senderUsername,
      'senderMessageUrl': senderPhotoUrl, // Note: server expects 'senderMessageUrl'
      'dateRead': dateRead?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'MessageDto{id: $id, senderId: $senderId, groupId: $groupId, content: $content, messageSent: $messageSent, senderUsername: $senderUsername}';
  }
}


