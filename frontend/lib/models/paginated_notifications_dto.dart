import 'package:frontend/models/notification_dto.dart';

class PaginatedNotificationsDto {
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final int totalCount;
  final List<NotificationDto> items;

  PaginatedNotificationsDto({
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.totalCount,
    required this.items,
  });

  factory PaginatedNotificationsDto.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJson = json['items'] ?? [];
    final List<NotificationDto> notificationItems = itemsJson
        .map((item) => NotificationDto.fromJson(item))
        .toList();

    return PaginatedNotificationsDto(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      totalCount: json['totalCount'] ?? 0,
      items: notificationItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'pageSize': pageSize,
      'totalCount': totalCount,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}
