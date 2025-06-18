import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/error_handling.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/paginated_notifications_dto.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class NotificationService {
  Future<PaginatedNotificationsDto> fetchNotification({
    // Changed return type
    required BuildContext context,
    int pageNumber = 1,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    PaginatedNotificationsDto? paginatedResponse; // Changed type

    try {
      final response = await http.get(
        Uri.parse('$uri/gateway/notifications?pageNumber=$pageNumber'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${userProvider.user.token}',
        },
      );

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          final Map<String, dynamic> responseBody = jsonDecode(response.body);
          paginatedResponse = PaginatedNotificationsDto.fromJson(responseBody);
        },
      );
    } catch (error) {
      IconSnackBar.show(
        context,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );
    }

    return paginatedResponse ??
        PaginatedNotificationsDto(
            items: [],
            currentPage: pageNumber,
            totalPages: pageNumber,
            pageSize: 20,
            totalCount: 0);
  }
}
