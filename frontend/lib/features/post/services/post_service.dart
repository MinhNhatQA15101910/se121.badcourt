import 'dart:convert';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/error_handling.dart';
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
    String username,
  ) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    try {
      final cloudinary = CloudinaryPublic('dauyd6npv', 'nkklif97');
      List<String> uploadedPostImageUrls = [];

      // Upload post images
      for (File file in postFiles) {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            file.path,
            folder: 'posts/${username}/{sth}',
          ),
        );
        uploadedPostImageUrls.add(response.secureUrl);
      }

      // Prepare and send the POST request
      http.Response response = await http.post(
        Uri.parse('$uri/api/posts'),
        body: jsonEncode(
          {
            "description": description,
            "resources": uploadedPostImageUrls,
            "title": title,
          },
        ),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${userProvider.user.token}',
        },
      );

      // Handle response
      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          IconSnackBar.show(
            context,
            label: 'Facility registered successfully',
            snackBarType: SnackBarType.success,
          );
        },
      );
    } catch (error) {
      IconSnackBar.show(
        context,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );
    }
  }
}
