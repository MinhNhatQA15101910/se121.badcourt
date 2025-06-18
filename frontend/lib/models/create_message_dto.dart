class CreateMessageDto {
  final String recipientId;
  final String content;
  final List<Map<String, dynamic>> resources;

  CreateMessageDto({
    required this.recipientId,
    required this.content,
    this.resources = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'recipientId': recipientId,
      'content': content,
      'resources': resources,
    };
  }

  factory CreateMessageDto.fromJson(Map<String, dynamic> json) {
    return CreateMessageDto(
      recipientId: json['recipientId'] ?? '',
      content: json['content'] ?? '',
      resources: (json['resources'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [],
    );
  }
}
