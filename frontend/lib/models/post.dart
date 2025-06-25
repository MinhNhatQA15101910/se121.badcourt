import 'dart:convert';

import 'package:frontend/models/file_dto.dart';

class Post {
  final String id;
  final String publisherId;
  final String publisherUsername;
  final String publisherImageUrl;
  final String title;
  final String content;
  final List<FileDto> resources;
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
      id: map['id']?.toString() ?? '',
      publisherId: map['publisherId']?.toString() ?? '',
      publisherUsername: map['publisherUsername']?.toString() ?? '',
      publisherImageUrl: map['publisherImageUrl']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      resources: map['resources'] != null
          ? List<FileDto>.from(
              map['resources'].map((r) => FileDto.fromMap(r)))
          : [],
      // Fix: Handle both string and int types for likesCount
      likesCount: _parseToInt(map['likesCount']),
      // Fix: Handle both string and bool types for isLiked
      isLiked: map['isLiked'] is bool
          ? map['isLiked']
          : map['isLiked'].toString().toLowerCase() == 'true',
      // Fix: Handle both string and int types for commentsCount
      commentsCount: _parseToInt(map['commentsCount']),
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  // Helper method to safely parse int from dynamic value
  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is double) return value.toInt();
    return 0;
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

  // Helper method to create a copy with updated values
  Post copyWith({
    String? id,
    String? publisherId,
    String? publisherUsername,
    String? publisherImageUrl,
    String? title,
    String? content,
    List<FileDto>? resources,
    int? likesCount,
    bool? isLiked,
    int? commentsCount,
    DateTime? createdAt,
  }) {
    return Post(
      id: id ?? this.id,
      publisherId: publisherId ?? this.publisherId,
      publisherUsername: publisherUsername ?? this.publisherUsername,
      publisherImageUrl: publisherImageUrl ?? this.publisherImageUrl,
      title: title ?? this.title,
      content: content ?? this.content,
      resources: resources ?? this.resources,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
