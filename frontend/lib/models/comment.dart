import 'dart:convert';

class Comment {
  final String id;
  final String postId;
  final String publisherId;
  final String publisherUsername;
  final String publisherImageUrl;
  final String content;
  final List<dynamic> resources;
  final int likesCount;
  final bool isLiked;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.postId,
    required this.publisherId,
    required this.publisherUsername,
    required this.publisherImageUrl,
    required this.content,
    required this.resources,
    required this.likesCount,
    required this.isLiked,
    required this.createdAt,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      postId: map['postId'] ?? '',
      publisherId: map['publisherId'] ?? '',
      publisherUsername: map['publisherUsername'] ?? '',
      publisherImageUrl: map['publisherImageUrl'] ?? '',
      content: map['content'] ?? '',
      resources: map['resources'] ?? [],
      likesCount: map['likesCount'] ?? 0,
      isLiked: map['isLiked'] ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'publisherId': publisherId,
      'publisherUsername': publisherUsername,
      'publisherImageUrl': publisherImageUrl,
      'content': content,
      'resources': resources,
      'likesCount': likesCount,
      'isLiked': isLiked,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());

  factory Comment.fromJson(String source) =>
      Comment.fromMap(json.decode(source));
}
