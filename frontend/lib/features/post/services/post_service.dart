import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class PostService {
  Future<void> createPost(
    BuildContext context,
    List<File> postFiles,
    String description,
    String title,
  ) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$uri/api/posts'));
      request.headers['Authorization'] = 'Bearer ${userProvider.user.token}';

      request.fields['description'] = description;
      request.fields['title'] = title;

      for (File file in postFiles) {
        var multipartFile = await http.MultipartFile.fromPath(
          'resources', // Match the key expected by your backend
          file.path,
        );
        request.files.add(multipartFile);
      }

      // Send the request
      var response = await request.send();

      // Handle the response
      if (response.statusCode == 201) {
        IconSnackBar.show(
          context,
          label: 'Post created successfully',
          snackBarType: SnackBarType.success,
        );
      } else {
        // Handle failure
        response.stream.transform(utf8.decoder).listen((value) {
          IconSnackBar.show(
            context,
            label: 'Error: $value',
            snackBarType: SnackBarType.fail,
          );
        });
      }
    } catch (e) {
      IconSnackBar.show(
        context,
        label: 'Error: ${e.toString()}',
        snackBarType: SnackBarType.fail,
      );
    }
  }
}
