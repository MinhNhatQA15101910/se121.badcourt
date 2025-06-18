class FileDto {
  final String? id;
  final String url;
  final bool isMain;
  final String fileType;

  FileDto({
    this.id,
    required this.url,
    required this.isMain,
    required this.fileType,
  });

  factory FileDto.fromJson(Map<String, dynamic> json) {
    return FileDto(
      id: json['id']?.toString(),
      url: json['url']?.toString() ?? '',
      isMain: json['isMain'] ?? false,
      fileType: json['fileType']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'isMain': isMain,
      'fileType': fileType,
    };
  }
}
