class MessageDto {
  final String id;
  final String senderId;
  final String groupId;
  final String content;
  final DateTime messageSent;
  final String? senderUsername;
  final String? senderPhotoUrl;
  final DateTime? dateRead; // Thay đổi từ String? thành DateTime?

  MessageDto({
    required this.id,
    required this.senderId,
    required this.groupId,
    required this.content,
    required this.messageSent,
    this.senderUsername,
    this.senderPhotoUrl,
    this.dateRead,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) {
    try {
      return MessageDto(
        id: json['id']?.toString() ?? '',
        senderId: json['senderId']?.toString() ?? '',
        groupId: json['groupId']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        messageSent: json['messageSent'] != null
            ? DateTime.parse(json['messageSent'].toString())
            : DateTime.now(),
        senderUsername: json['senderUsername']?.toString(),
        senderPhotoUrl: json['senderMessageUrl']?.toString(), // Note: server uses 'senderMessageUrl'
        dateRead: json['dateRead'] != null && json['dateRead'].toString().isNotEmpty
            ? DateTime.parse(json['dateRead'].toString())
            : null,
      );
    } catch (e, stackTrace) {
      print('Error parsing MessageDto from JSON: $e');
      print('JSON data: $json');
      print('Stack trace: $stackTrace');
      
      // Return a default MessageDto to prevent crashes
      return MessageDto(
        id: json['id']?.toString() ?? 'unknown',
        senderId: json['senderId']?.toString() ?? 'unknown',
        groupId: json['groupId']?.toString() ?? 'unknown',
        content: json['content']?.toString() ?? 'Error loading message',
        messageSent: DateTime.now(),
        senderUsername: json['senderUsername']?.toString() ?? 'Unknown',
        senderPhotoUrl: null,
        dateRead: null,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'groupId': groupId,
      'content': content,
      'messageSent': messageSent.toIso8601String(),
      'senderUsername': senderUsername,
      'senderMessageUrl': senderPhotoUrl, // Note: server expects 'senderMessageUrl'
      'dateRead': dateRead?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'MessageDto{id: $id, senderId: $senderId, groupId: $groupId, content: $content, messageSent: $messageSent, senderUsername: $senderUsername, dateRead: $dateRead}';
  }
}
