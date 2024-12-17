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
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
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
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['_id'] ?? '',
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
    );
  }

  String toJson() => json.encode(toMap());

  factory Post.fromJson(String source) => Post.fromMap(json.decode(source));
}
