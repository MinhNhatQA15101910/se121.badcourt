import 'package:frontend/models/group_dto.dart';

class PaginatedGroupsDto {
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final int totalCount;
  final List<GroupDto> items;

  PaginatedGroupsDto({
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.totalCount,
    required this.items,
  });

  factory PaginatedGroupsDto.fromJson(Map<String, dynamic> json) {
    try {
      final itemsList = json['items'] as List<dynamic>? ?? [];
      final groups = itemsList.map((item) {
        if (item is Map<String, dynamic>) {
          return GroupDto.fromJson(item);
        } else {
          throw Exception('Invalid group item format');
        }
      }).toList();

      return PaginatedGroupsDto(
        currentPage: json['currentPage'] as int? ?? 1,
        totalPages: json['totalPages'] as int? ?? 1,
        pageSize: json['pageSize'] as int? ?? 20,
        totalCount: json['totalCount'] as int? ?? 0,
        items: groups,
      );
    } catch (e) {
      print('[PaginatedGroupsDto] Error parsing JSON: $e');
      print('[PaginatedGroupsDto] JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'pageSize': pageSize,
      'totalCount': totalCount,
      'items': items.map((group) => group.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'PaginatedGroupsDto(currentPage: $currentPage, totalPages: $totalPages, pageSize: $pageSize, totalCount: $totalCount, items: ${items.length} groups)';
  }
}
