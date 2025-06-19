class CreateMessageDto {
  final String recipientId;
  final String content;
  final List<String> base64Resources;

  CreateMessageDto({
    required this.recipientId,
    required this.content,
    this.base64Resources = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'recipientId': recipientId,
      'content': content,
      'base64Resources': base64Resources, // Updated field name
    };
  }

  factory CreateMessageDto.fromJson(Map<String, dynamic> json) {
    return CreateMessageDto(
      recipientId: json['recipientId'] ?? '',
      content: json['content'] ?? '',
      base64Resources: (json['base64Resources'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}