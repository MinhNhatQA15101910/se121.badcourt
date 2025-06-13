
class NotificationDto {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String content;
  final NotificationDataDto data;
  bool isRead;
  final DateTime createdAt;

  NotificationDto({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.content,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      data: NotificationDataDto.fromJson(json['data'] ?? {}),
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'content': content,
      'data': data.toJson(),
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Add copyWith method to create a copy with modified fields
  NotificationDto copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? content,
    NotificationDataDto? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationDto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'NotificationDto(id: $id, userId: $userId, type: $type, title: $title, content: $content, isRead: $isRead, createdAt: $createdAt)';
  }
}

class NotificationDataDto {
  final String? orderId;
  final String? roomId;
  final String? postId;
  final String? commentId;

  NotificationDataDto({
    this.orderId,
    this.roomId,
    this.postId,
    this.commentId,
  });

  factory NotificationDataDto.fromJson(Map<String, dynamic> json) {
    return NotificationDataDto(
      orderId: json['orderId'],
      roomId: json['roomId'],
      postId: json['postId'],
      commentId: json['commentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'roomId': roomId,
      'postId': postId,
      'commentId': commentId,
    };
  }
}
