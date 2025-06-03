class CreateMessageDto {
  final String recipientId;
  final String content;
  final String? attachmentUrl;

  CreateMessageDto({
    required this.recipientId,
    required this.content,
    this.attachmentUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'recipientId': recipientId,
      'content': content,
      if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
    };
  }

  factory CreateMessageDto.fromJson(Map<String, dynamic> json) {
    return CreateMessageDto(
      recipientId: json['recipientId'] ?? '',
      content: json['content'] ?? '',
      attachmentUrl: json['attachmentUrl'],
    );
  }
}
