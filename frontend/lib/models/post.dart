import 'dart:convert';

import 'package:frontend/models/resource.dart';

class Post {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final List<Resource> resources;
  final int createdAt;
  final int updatedAt;

  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.resources,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'resources': resources.map((resource) => resource.toMap()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['_id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      resources: List<Resource>.from(
          map['resources']?.map((x) => Resource.fromMap(x)) ?? []),
      createdAt: map['createdAt'] ?? 0,
      updatedAt: map['updatedAt'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Post.fromJson(String source) => Post.fromMap(json.decode(source));
}
