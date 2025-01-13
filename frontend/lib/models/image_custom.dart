class ImageCustom {
  final String id;
  final String url;
  final bool isMain;
  final String type;

  ImageCustom({
    required this.id,
    required this.url,
    required this.isMain,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'url': url,
      'isMain': isMain,
      'type': type,
    };
  }

  factory ImageCustom.fromMap(Map<String, dynamic> map) {
    return ImageCustom(
      id: map['_id'] ?? '',
      url: map['url'] ?? '',
      isMain: map['isMain'] ?? false,
      type: map['type'] ?? '',
    );
  }
}
