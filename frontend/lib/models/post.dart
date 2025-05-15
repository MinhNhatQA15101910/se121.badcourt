import 'dart:convert';
import 'package:frontend/models/post_resource.dart';

class Post {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String category;
  final List<PostResource> resources;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.category,
    required this.resources,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.createdAt,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? '',
      resources: map['resources'] != null
          ? List<PostResource>.from(
              map['resources'].map((r) => PostResource.fromMap(r)))
          : [],
      likesCount: map['likesCount'] ?? 0,
      commentsCount: map['commentsCount'] ?? 0,
      isLiked: map['isLiked'] ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'category': category,
      'resources': resources.map((r) => r.toMap()).toList(),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'isLiked': isLiked,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());

  factory Post.fromJson(String source) => Post.fromMap(json.decode(source));
}
