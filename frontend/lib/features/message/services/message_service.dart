import 'dart:convert';
import 'dart:io';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class MessageService {
  Future<String> getOrCreatePersonalMessageRoom({
    required BuildContext context,
    required String userId,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    final response = await http.get(
      Uri.parse('$uri/api/messages/room/$userId'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${userProvider.user.token}",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["_id"];
    } else if (response.statusCode == 404) {
      return await _createMessageRoom(context: context, userId: userId);
    } else {
      throw Exception('Failed to fetch personal message room');
    }
  }

  Future<String> _createMessageRoom({
    required BuildContext context,
    required String userId,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    final response = await http.post(
      Uri.parse('$uri/api/messages/create-room'),
      headers: {
        "Authorization": "Bearer ${userProvider.user.token}",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "users": [userId],
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data["_id"];
    } else {
      throw Exception('Failed to create personal message room');
    }
  }

  Future<dynamic> getMessages({
    required String roomId,
    required BuildContext context,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    final response = await http.get(
      Uri.parse(
          '$uri/api/messages?roomId=$roomId&pageNumber=$pageNumber&pageSize=$pageSize'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${userProvider.user.token}",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch messages');
    }
  }

  Future<dynamic> sendMessageToRoom({
    required String roomId,
    required String content,
    List<File>? imageFiles,
    required BuildContext context,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$uri/api/messages/send-to-room'),
      );
      request.headers['Authorization'] = 'Bearer ${userProvider.user.token}';

      request.fields['roomId'] = roomId;
      request.fields['content'] = content;

      if (imageFiles != null && imageFiles.isNotEmpty) {
        for (File file in imageFiles) {
          var multipartFile = await http.MultipartFile.fromPath(
            'resources',
            file.path,
          );
          request.files.add(multipartFile);
        }
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        var responseBody = await response.stream.bytesToString();
        return jsonDecode(responseBody);
      } else {
        var responseBody = await response.stream.bytesToString();
        throw Exception('Failed to send message: $responseBody');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }
}
