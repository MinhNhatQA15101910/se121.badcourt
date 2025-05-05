import 'dart:convert';
import 'package:frontend/models/comment.dart';

class Post {
  final String id;
  final String publisherId;
  final String publisherUsername;
  final String publisherImageUrl;
  final String title;
  final String description;
  final String category;
  final List<String> resources;
  final int createdAt;
  final List<Comment> comments; // New field
  final int commentsCount; // New field for comment count
  final int likesCount; // New field for likes count

  const Post({
    required this.id,
    required this.publisherId,
    required this.publisherUsername,
    required this.publisherImageUrl,
    required this.title,
    required this.description,
    required this.category,
    required this.resources,
    required this.createdAt,
    required this.comments,
    required this.commentsCount,
    required this.likesCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'publisherId': publisherId,
      'publisherUsername': publisherUsername,
      'publisherImageUrl': publisherImageUrl,
      'title': title,
      'description': description,
      'category': category,
      'resources': resources,
      'createdAt': createdAt,
      'comments': comments
          .map((comment) => comment.toMap())
          .toList(), // Convert each comment to a map
      'commentsCount': commentsCount, // Add comments count to map
      'likesCount': likesCount, // Add likes count to map
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] ?? '',
      publisherId: map['publisherId'] ?? '',
      publisherUsername: map['publisherUsername'] ?? '',
      publisherImageUrl: map['publisherImageUrl'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      resources: List<String>.from(map['resources'] ?? []),
      createdAt: map['createdAt'] ?? 0,
      comments: map['comments'] != null
          ? List<Comment>.from(
              (map['comments'] as List)
                  .map((comment) => Comment.fromMap(comment)),
            )
          : [],
      commentsCount: map['commentsCount'] != null ? map['commentsCount'] : 0,
      likesCount: map['likesCount'] != null ? map['likesCount'] : 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Post.fromJson(String source) => Post.fromMap(json.decode(source));
}
