class Photo {
  final String id;
  final String url;
  final bool isMain;

  Photo({
    required this.id,
    required this.url,
    required this.isMain,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      isMain: json['isMain'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'isMain': isMain,
    };
  }

  @override
  String toString() {
    return 'Photo(id: $id, url: $url, isMain: $isMain)';
  }
}
