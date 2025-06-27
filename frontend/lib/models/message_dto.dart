import 'package:frontend/models/file_dto.dart';

class MessageDto {
  final String id;
  final String senderId;
  final String groupId;
  final String content;
  final DateTime messageSent;
  final String? senderUsername;
  final String? senderPhotoUrl;
  final DateTime? dateRead;
  final List<FileDto> resources;

  MessageDto({
    required this.id,
    required this.senderId,
    required this.groupId,
    required this.content,
    required this.messageSent,
    this.senderUsername,
    this.senderPhotoUrl,
    this.dateRead,
    this.resources = const [],
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) {
    DateTime _parse(dynamic v) {
      if (v == null || v.toString().isEmpty) return DateTime.now();
      try {
        return DateTime.parse(v.toString()).toLocal();
      } catch (_) {
        return DateTime.now();
      }
    }

    return MessageDto(
      id: json['id']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      groupId: json['groupId']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      messageSent: _parse(json['messageSent']),
      senderUsername: json['senderUsername']?.toString(),
      senderPhotoUrl: json['senderMessageUrl']?.toString(),
      dateRead: json['dateRead'] != null ? _parse(json['dateRead']) : null,
      resources: (json['resources'] is List)
          ? (json['resources'] as List).map((e) => FileDto.fromMap(e)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'groupId': groupId,
        'content': content,
        'messageSent': messageSent.toUtc().toIso8601String(),
        'senderUsername': senderUsername,
        'senderMessageUrl': senderPhotoUrl,
        'dateRead': dateRead?.toUtc().toIso8601String(),
        'resources': resources.map((f) => f.toMap()).toList(),
      };

  @override
  String toString() =>
      'MessageDto{id: $id, senderId: $senderId, groupId: $groupId, content: $content, messageSent: $messageSent, senderUsername: $senderUsername, dateRead: $dateRead, resources: $resources}';
}
