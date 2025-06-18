import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/error_handling.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/paginated_groups_dto.dart';
import 'package:frontend/models/paginated_messages_dto.dart'; // Changed import
import 'package:frontend/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class MessageService {
  Future<PaginatedMessagesDto> fetchMessagesByGroup({ // Changed return type
    required BuildContext context,
    required String groupId,
    int pageNumber = 1,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    PaginatedMessagesDto? paginatedResponse; // Changed type

    try {
      final response = await http.get(
        Uri.parse('$uri/gateway/messages?groupId=$groupId&pageNumber=$pageNumber'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${userProvider.user.token}',
        },
      );

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          // Assuming the API returns a JSON object with 'items', 'currentPage', 'totalPages', 'pageSize'
          final Map<String, dynamic> responseBody = jsonDecode(response.body);
          paginatedResponse = PaginatedMessagesDto.fromJson(responseBody);
        },
      );
    } catch (error) {
      IconSnackBar.show(
        context,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );
    }

    // Return an empty response if something went wrong, or the actual response
    return paginatedResponse ?? PaginatedMessagesDto(items: [], currentPage: pageNumber, totalPages: pageNumber, pageSize: 20, totalCount: 0);
  }

  Future<PaginatedGroupsDto> fetchGroup({
    // Changed return type
    required BuildContext context,
    int pageNumber = 1,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    PaginatedGroupsDto? paginatedResponse; // Changed type

    try {
      final response = await http.get(
        Uri.parse('$uri/gateway/groups?pageNumber=$pageNumber'),
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
          paginatedResponse = PaginatedGroupsDto.fromJson(responseBody);
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
        PaginatedGroupsDto(
            items: [],
            currentPage: pageNumber,
            totalPages: pageNumber,
            pageSize: 20,
            totalCount: 0);
  }
}
