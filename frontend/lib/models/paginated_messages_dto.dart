import 'package:frontend/models/message_dto.dart';

class PaginatedMessagesDto {
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final int totalCount;
  final List<MessageDto> items;

  PaginatedMessagesDto({
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.totalCount,
    required this.items,
  });

  factory PaginatedMessagesDto.fromJson(Map<String, dynamic> json) {
    try {
      final itemsList = json['items'] as List<dynamic>? ?? [];
      final messages = itemsList.map((item) {
        if (item is Map<String, dynamic>) {
          return MessageDto.fromJson(item);
        } else {
          throw Exception('Invalid message item format');
        }
      }).toList();

      return PaginatedMessagesDto(
        currentPage: json['currentPage'] as int? ?? 1,
        totalPages: json['totalPages'] as int? ?? 1,
        pageSize: json['pageSize'] as int? ?? 20,
        totalCount: json['totalCount'] as int? ?? 0,
        items: messages,
      );
    } catch (e) {
      print('[PaginatedMessagesDto] Error parsing JSON: $e');
      print('[PaginatedMessagesDto] JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'pageSize': pageSize,
      'totalCount': totalCount,
      'items': items.map((message) => message.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'PaginatedMessagesDto(currentPage: $currentPage, totalPages: $totalPages, pageSize: $pageSize, totalCount: $totalCount, items: ${items.length} messages)';
  }
}
