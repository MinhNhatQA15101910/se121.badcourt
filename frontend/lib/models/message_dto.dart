class MessageDto {
  final String id;
  final String groupId;
  final String senderId;
  final String senderUsername;
  final String? senderImageUrl;
  final String content;
  final String? dateRead;
  final DateTime messageSent;

  MessageDto({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderUsername,
    this.senderImageUrl,
    required this.content,
    this.dateRead,
    required this.messageSent,
  });

  // Computed properties for compatibility
  String? get senderPhotoUrl => senderImageUrl;

  factory MessageDto.fromJson(Map<String, dynamic> json) {
    try {
      return MessageDto(
        id: json['id']?.toString() ?? '',
        groupId: json['groupId']?.toString() ?? '',
        senderId: json['senderId']?.toString() ?? '',
        senderUsername: json['senderUsername']?.toString() ?? '',
        senderImageUrl: json['senderImageUrl']?.toString(),
        content: json['content']?.toString() ?? '',
        dateRead: json['dateRead']?.toString(),
        messageSent: json['messageSent'] != null
            ? DateTime.parse(json['messageSent'].toString())
            : DateTime.now(),
      );
    } catch (e, stackTrace) {
      print('Error parsing MessageDto from JSON: $e');
      print('JSON data: $json');
      print('Stack trace: $stackTrace');
      
      return MessageDto(
        id: json['id']?.toString() ?? 'unknown',
        groupId: json['groupId']?.toString() ?? 'unknown',
        senderId: json['senderId']?.toString() ?? 'unknown',
        senderUsername: json['senderUsername']?.toString() ?? 'Unknown',
        senderImageUrl: null,
        content: json['content']?.toString() ?? 'Error loading message',
        dateRead: null,
        messageSent: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'senderId': senderId,
      'senderUsername': senderUsername,
      'senderImageUrl': senderImageUrl,
      'content': content,
      'dateRead': dateRead,
      'messageSent': messageSent.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'MessageDto{id: $id, groupId: $groupId, senderId: $senderId, senderUsername: $senderUsername, content: $content, messageSent: $messageSent, dateRead: $dateRead}';
  }
}