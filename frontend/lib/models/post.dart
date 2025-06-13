import 'dart:convert';
import 'package:frontend/models/post_resource.dart';

class Post {
  final String id;
  final String publisherId;
  final String publisherUsername;
  final String publisherImageUrl;
  final String title;
  final String content;
  final List<PostResource> resources;
  final int likesCount;
  final bool isLiked;
  final int commentsCount;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.publisherId,
    required this.publisherUsername,
    required this.publisherImageUrl,
    required this.title,
    required this.content,
    required this.resources,
    required this.likesCount,
    required this.isLiked,
    required this.commentsCount,
    required this.createdAt,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] ?? '',
      publisherId: map['publisherId'] ?? '',
      publisherUsername: map['publisherUsername'] ?? '',
      publisherImageUrl: map['publisherImageUrl'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      resources: map['resources'] != null
          ? List<PostResource>.from(
              map['resources'].map((r) => PostResource.fromMap(r)))
          : [],
      likesCount: map['likesCount'] ?? 0,
      isLiked: map['isLiked'] is bool
          ? map['isLiked']
          : map['isLiked'].toString().toLowerCase() == 'true',
      commentsCount: map['commentsCount'] ?? 0,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'publisherId': publisherId,
      'publisherUsername': publisherUsername,
      'publisherImageUrl': publisherImageUrl,
      'title': title,
      'content': content,
      'resources': resources.map((r) => r.toMap()).toList(),
      'likesCount': likesCount,
      'isLiked': isLiked,
      'commentsCount': commentsCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());

  factory Post.fromJson(String source) => Post.fromMap(json.decode(source));
}
