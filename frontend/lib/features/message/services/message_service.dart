import 'dart:convert';
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

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["_id"];
    } else {
      throw Exception('Failed to create personal message room');
    }
  }

  Future<dynamic> getMessages({
    required String roomId,
    required BuildContext context,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    final response = await http.get(
      Uri.parse('$uri/api/messages?roomId=$roomId'),
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
    required BuildContext context,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    final response = await http.post(
      Uri.parse('$uri/api/messages/send-to-room'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${userProvider.user.token}",
      },
      body: jsonEncode({
        "roomId": roomId,
        "content": content,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to send message');
    }
  }
}
