import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/error_handling.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class UserService {
  Future<void> addPhoto(
    BuildContext context,
    File file,
  ) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final uriObj = Uri.parse('$uri/gateway/users/add-photo');
      final request = http.MultipartRequest('POST', uriObj);

      request.headers['Authorization'] = 'Bearer ${userProvider.user.token}';
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          IconSnackBar.show(
            context,
            label: 'Photo uploaded successfully',
            snackBarType: SnackBarType.success,
          );
        },
      );
    } catch (e) {
      IconSnackBar.show(
        context,
        label: 'Failed to upload photo: ${e.toString()}',
        snackBarType: SnackBarType.fail,
      );
    }
  }

  Future<void> setMainPhoto(
    BuildContext context,
    String photoId,
  ) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final res = await http.put(
        Uri.parse('$uri/gateway/users/set-main-photo/$photoId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${userProvider.user.token}',
        },
      );

      httpErrorHandler(
        response: res,
        context: context,
        onSuccess: () {
          IconSnackBar.show(
            context,
            label: 'Main photo updated successfully',
            snackBarType: SnackBarType.success,
          );
        },
      );
    } catch (e) {
      IconSnackBar.show(
        context,
        label: 'Failed to set main photo: ${e.toString()}',
        snackBarType: SnackBarType.fail,
      );
    }
  }

  Future<void> deletePhoto(
    BuildContext context,
    String photoId,
  ) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final res = await http.delete(
        Uri.parse('$uri/gateway/users/delete-photo/$photoId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${userProvider.user.token}',
        },
      );

      httpErrorHandler(
        response: res,
        context: context,
        onSuccess: () {
          IconSnackBar.show(
            context,
            label: 'Photo deleted successfully',
            snackBarType: SnackBarType.success,
          );
        },
      );
    } catch (e) {
      IconSnackBar.show(
        context,
        label: 'Failed to delete photo: ${e.toString()}',
        snackBarType: SnackBarType.fail,
      );
    }
  }
  Future<User?> fetchCurrentUser({
    required BuildContext context,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final Uri currentUri = Uri.parse('$uri/gateway/users/me');

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
