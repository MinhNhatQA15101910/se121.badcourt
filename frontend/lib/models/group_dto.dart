import 'package:frontend/models/user.dart';
import 'package:frontend/models/message_dto.dart';

class GroupDto {
  final String id;
  final String name;
  final List<User> users;
  final MessageDto? lastMessage;
  final List<String> connections;
  final DateTime updatedAt;

  GroupDto({
    required this.id,
    required this.name,
    required this.users,
    this.lastMessage,
    required this.connections,
    required this.updatedAt,
  });

  List<String> get userIds => users.map((user) => user.id).toList();

  bool get hasMessage {
    if (lastMessage == null) return false;
    return lastMessage!.dateRead == null;
  }

  DateTime get createdAt => updatedAt;

  String? get lastMessageAttachment => null;

  factory GroupDto.fromJson(Map<String, dynamic> json) {
    final users = (json['users'] as List<dynamic>? ?? [])
        .map((userJson) =>
            userJson is Map<String, dynamic> ? User.fromJson(userJson) : null)
        .whereType<User>()
        .toList();

    final connections = (json['connections'] as List<dynamic>? ?? [])
        .map((conn) => conn.toString())
        .toList();

    final lastMessageJson = json['lastMessage'];
    MessageDto? lastMessage;
    if (lastMessageJson is Map<String, dynamic>) {
      try {
        lastMessage = MessageDto.fromJson(lastMessageJson);
      } catch (_) {
        lastMessage = null;
      }
    }

    DateTime updatedAt;
    try {
      final updatedAtStr = json['updatedAt'] as String?;
      updatedAt = updatedAtStr != null
          ? DateTime.parse(updatedAtStr).toLocal()
          : DateTime.now();
    } catch (_) {
      updatedAt = DateTime.now();
    }

    return GroupDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      users: users,
      lastMessage: lastMessage,
      connections: connections,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'users': users.map((user) => user.toJson()).toList(),
      'lastMessage': lastMessage?.toJson(),
      'connections': connections,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }

  GroupDto copyWith({
    String? id,
    String? name,
    List<User>? users,
    MessageDto? lastMessage,
    List<String>? connections,
    DateTime? updatedAt,
  }) {
    return GroupDto(
      id: id ?? this.id,
      name: name ?? this.name,
      users: users ?? this.users,
      lastMessage: lastMessage ?? this.lastMessage,
      connections: connections ?? this.connections,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'GroupDto(id: $id, name: $name, users: ${users.length}, hasLastMessage: ${lastMessage != null}, hasUnreadMessage: $hasMessage, connections: ${connections.length}, updatedAt: $updatedAt)';
  }
}
