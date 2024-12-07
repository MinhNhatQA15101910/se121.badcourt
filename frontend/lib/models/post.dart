import 'dart:convert';

class Post {
  final String id;
  final String publisherId;
  final String publisherImageUrl;
  final String title;
  final String description;
  final String category;
  final List<String> resources;

  const Post({
    required this.id,
    required this.publisherId,
    required this.publisherImageUrl,
    required this.title,
    required this.description,
    required this.category,
    required this.resources,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'publisherId': publisherId,
      'publisherImageUrl': publisherImageUrl,
      'title': title,
      'description': description,
      'category': category,
      'resources': resources,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['_id'] ?? '',
      publisherId: map['publisherId'] ?? '',
      publisherImageUrl: map['publisherImageUrl'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      resources: List<String>.from(map['resources'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory Post.fromJson(String source) => Post.fromMap(json.decode(source));
}
