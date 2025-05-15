class PostResource {
  final String? id;
  final String url;
  final bool isMain;
  final String fileType;

  const PostResource({
    this.id,
    required this.url,
    required this.isMain,
    required this.fileType,
  });

  factory PostResource.fromMap(Map<String, dynamic> map) {
    return PostResource(
      id: map['id'],
      url: map['url'] ?? '',
      isMain: map['isMain'] ?? false,
      fileType: map['fileType'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'isMain': isMain,
      'fileType': fileType,
    };
  }
}
