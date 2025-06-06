import 'package:frontend/models/user_dto.dart';
import 'package:frontend/models/message_dto.dart';

class GroupDto {
  final String id;
  final String name;
  final List<UserDto> users;
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

  // Computed properties for backward compatibility
  List<String> get userIds => users.map((user) => user.id).toList();
  
  bool get hasMessage {
    if (lastMessage == null) return false;
    return lastMessage!.dateRead == null;
  }
  
  DateTime get createdAt => updatedAt; // Use updatedAt as fallback
  
  String? get lastMessageAttachment => null; // Backend doesn't have this field

  factory GroupDto.fromJson(Map<String, dynamic> json) {
    try {
      // Parse users list
      final usersList = json['users'] as List<dynamic>? ?? [];
      final users = usersList.map((userJson) {
        if (userJson is Map<String, dynamic>) {
          return UserDto.fromJson(userJson);
        } else {
          print('[GroupDto] Invalid user format: $userJson');
          return null;
        }
      }).where((user) => user != null).cast<UserDto>().toList();

      // Parse connections list - now as simple strings
      final connectionsList = json['connections'] as List<dynamic>? ?? [];
      final connections = connectionsList.map((conn) => conn.toString()).toList();

      // Parse last message
      MessageDto? lastMessage;
      final lastMessageJson = json['lastMessage'];
      if (lastMessageJson != null && lastMessageJson is Map<String, dynamic>) {
        try {
          lastMessage = MessageDto.fromJson(lastMessageJson);
        } catch (e) {
          print('[GroupDto] Error parsing lastMessage: $e');
          lastMessage = null;
        }
      }

      // Parse updatedAt
      DateTime updatedAt;
      try {
        final updatedAtStr = json['updatedAt'] as String?;
        if (updatedAtStr != null) {
          updatedAt = DateTime.parse(updatedAtStr);
        } else {
          updatedAt = DateTime.now();
        }
      } catch (e) {
        print('[GroupDto] Error parsing updatedAt: $e');
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
    } catch (e, stackTrace) {
      print('[GroupDto] Error parsing JSON: $e');
      print('[GroupDto] Stack trace: $stackTrace');
      print('[GroupDto] JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'users': users.map((user) => user.toJson()).toList(),
      'lastMessage': lastMessage?.toJson(),
      'connections': connections,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  GroupDto copyWith({
    String? id,
    String? name,
    List<UserDto>? users,
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
    return 'GroupDto(id: $id, name: $name, users: ${users.length}, hasLastMessage: ${lastMessage != null}, connections: ${connections.length}, updatedAt: $updatedAt)';
  }
}

class PaginatedGroupsDto {
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final int totalCount;
  final List<GroupDto> items;

  PaginatedGroupsDto({
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.totalCount,
    required this.items,
  });

  factory PaginatedGroupsDto.fromJson(Map<String, dynamic> json) {
    try {
      return PaginatedGroupsDto(
        currentPage: json['currentPage'] ?? 1,
        totalPages: json['totalPages'] ?? 1,
        pageSize: json['pageSize'] ?? 20,
        totalCount: json['totalCount'] ?? 0,
        items: (json['items'] as List<dynamic>?)
                ?.map((item) {
                  if (item is Map<String, dynamic>) {
                    return GroupDto.fromJson(item);
                  } else {
                    print('[PaginatedGroupsDto] Invalid item data: $item');
                    return null;
                  }
                })
                .where((item) => item != null)
                .cast<GroupDto>()
                .toList() ??
            [],
      );
    } catch (e, stackTrace) {
      print('[PaginatedGroupsDto] Error parsing from JSON: $e');
      print('[PaginatedGroupsDto] JSON data: $json');
      print('[PaginatedGroupsDto] Stack trace: $stackTrace');
      
      return PaginatedGroupsDto(
        currentPage: 1,
        totalPages: 1,
        pageSize: 20,
        totalCount: 0,
        items: [],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'pageSize': pageSize,
      'totalCount': totalCount,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'PaginatedGroupsDto{currentPage: $currentPage, totalPages: $totalPages, pageSize: $pageSize, totalCount: $totalCount, items: ${items.length}}';
  }
}
