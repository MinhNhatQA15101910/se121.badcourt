class FileDto {
  final String? id;
  final String url;
  final bool isMain;
  final String fileType;

  const FileDto({
    this.id,
    required this.url,
    required this.isMain,
    required this.fileType,
  });

  factory FileDto.fromMap(Map<String, dynamic> map) {
    return FileDto(
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
