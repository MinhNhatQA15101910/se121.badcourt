import 'dart:convert';

class Resource {
  final String url;
  final bool isMain;
  final String publicId;
  final String id;

  const Resource({
    required this.url,
    required this.isMain,
    required this.publicId,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'isMain': isMain,
      'publicId': publicId,
      '_id': id,
    };
  }

  factory Resource.fromMap(Map<String, dynamic> map) {
    return Resource(
      url: map['url'] ?? '',
      isMain: map['isMain'] ?? false,
      publicId: map['publicId'] ?? '',
      id: map['_id'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Resource.fromJson(String source) =>
      Resource.fromMap(json.decode(source));
}
