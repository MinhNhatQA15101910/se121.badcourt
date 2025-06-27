import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/error_handling.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/paginated_groups_dto.dart';
import 'package:frontend/models/paginated_messages_dto.dart'; // Changed import
import 'package:frontend/models/user.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path/path.dart';

class MessageService {
  Future<PaginatedMessagesDto> fetchMessagesByOrderUserId({
    // Changed return type
    required BuildContext context,
    required String userId,
    int pageNumber = 1,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    PaginatedMessagesDto? paginatedResponse; // Changed type

    try {
      final response = await http.get(
        Uri.parse(
            '$uri/gateway/messages?OtherUserId=$userId&pageNumber=$pageNumber&pageSize=20'),
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
    return paginatedResponse ??
        PaginatedMessagesDto(
            items: [],
            currentPage: pageNumber,
            totalPages: pageNumber,
            pageSize: 20,
            totalCount: 0);
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

  Future<void> sendMessage({
    required BuildContext context,
    required String recipientId,
    required String content,
    required List<File> resources, // image or video files
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final uriRequest = Uri.parse('$uri/gateway/messages');
      final request = http.MultipartRequest('POST', uriRequest)
        ..headers['Authorization'] = 'Bearer ${userProvider.user.token}'
        ..fields['recipientId'] = recipientId
        ..fields['content'] = content;

      for (File file in resources) {
        final multipartFile = await http.MultipartFile.fromPath(
          'resources',
          file.path,
          filename: basename(file.path),
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
        },
      );
    } catch (e) {
      IconSnackBar.show(
        context,
        label: 'Failed to send message: ${e.toString()}',
        snackBarType: SnackBarType.fail,
      );
    }
  }
  
  Future<User?> fetchUserById({
    required BuildContext context,
    required String userId,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final Uri currentUri = Uri.parse('$uri/gateway/users/$userId');

      http.Response res = await http.get(
        currentUri,
        headers: {
          'Authorization': 'Bearer ${userProvider.user.token}',
          'Content-Type': 'application/json',
        },
      );

      User? user;

      httpErrorHandler(
        response: res,
        context: context,
        onSuccess: () {
          try {
            final data = jsonDecode(res.body);
            user = User.fromJson(data);
          } catch (e) {
            print('Error parsing post by ID: $e');
            print('Post data: ${res.body}');
            IconSnackBar.show(
              context,
              label: 'Error parsing post data',
              snackBarType: SnackBarType.fail,
            );
          }
        },
      );

      return user;
    } catch (error) {
      IconSnackBar.show(
        context,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );
      return null;
    }
  }
}
