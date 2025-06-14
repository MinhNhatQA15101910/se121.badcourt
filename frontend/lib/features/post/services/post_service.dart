import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/error_handling.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/models/post.dart';
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$uri/gateway/posts'));
      request.headers['Authorization'] = 'Bearer ${userProvider.user.token}';

      request.fields['title'] = title;
      request.fields['content'] =
          description; // <-- sửa từ 'description' thành 'content'

      for (File file in postFiles) {
        var multipartFile = await http.MultipartFile.fromPath(
          'resources', // <-- đúng key
          file.path,
        );
        request.files.add(multipartFile);
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        IconSnackBar.show(
          context,
          label: 'Post created successfully',
          snackBarType: SnackBarType.success,
        );
      } else {
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

  Future<Map<String, dynamic>> fetchAllPosts({
    required BuildContext context,
    required int pageNumber,
    int pageSize = 10,
    required String searchQuery,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    List<Post> postList = [];
    int totalPages = 0;

    try {
      final Uri uriWithParams =
          Uri.parse('$uri/gateway/posts').replace(queryParameters: {
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
        'query': searchQuery,
      });

      http.Response res = await http.get(
        uriWithParams,
        headers: {
          'Authorization': 'Bearer ${userProvider.user.token}',
          'Content-Type': 'application/json',
        },
      );

      httpErrorHandler(
        response: res,
        context: context,
        onSuccess: () {
          for (var object in jsonDecode(res.body)) {
            postList.add(
              Post.fromMap(object),
            );
          }

          final paginationHeader = res.headers['pagination'];
          if (paginationHeader != null) {
            final paginationData = jsonDecode(paginationHeader);
            totalPages = paginationData['totalPages'];
          }
        },
      );
    } catch (error) {
      IconSnackBar.show(
        context,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );
    }

    return {
      'posts': postList,
      'totalPages': totalPages,
    };
  }

  Future<Post?> fetchPostById({
    required BuildContext context,
    required String postId,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final Uri currentUri = Uri.parse('$uri/gateway/posts/$postId');

      http.Response res = await http.get(
        currentUri,
        headers: {
          'Authorization': 'Bearer ${userProvider.user.token}',
          'Content-Type': 'application/json',
        },
      );

      Post? post;

      httpErrorHandler(
        response: res,
        context: context,
        onSuccess: () {
          final data = jsonDecode(res.body);
          post = Post.fromMap(data);
        },
      );

      return post;
    } catch (error) {
      IconSnackBar.show(
        context,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );
      return null;
    }
  }

  Future<void> createComment(
    BuildContext context,
    String postId,
    String content,
    List<File> images, // Add images parameter
  ) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    try {
      final uriObj = Uri.parse('$uri/gateway/comments');
      final request = http.MultipartRequest('POST', uriObj);

      request.headers['Authorization'] = 'Bearer ${userProvider.user.token}';

      request.fields['postId'] = postId;
      request.fields['content'] = content;

      // Add images to the request
      for (File image in images) {
        var multipartFile = await http.MultipartFile.fromPath(
          'resources', // Use the same field name as your API expects
          image.path,
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          IconSnackBar.show(
            context,
            label: 'Comment added successfully',
            snackBarType: SnackBarType.success,
          );
        },
      );
    } catch (e) {
      IconSnackBar.show(
        context,
        label: 'Error: ${e.toString()}',
        snackBarType: SnackBarType.fail,
      );
    }
  }

  Future<Map<String, dynamic>> fetchCommentsByPostId({
    required BuildContext context,
    required String postId,
    required int pageNumber,
    int pageSize = 10,
  }) async {
    List<Comment> commentList = [];
    int totalPages = 0;
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    try {
      final Uri uriWithParams =
          Uri.parse('$uri/gateway/comments').replace(queryParameters: {
        'postId': postId,
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      });

      http.Response res = await http.get(
        uriWithParams,
        headers: {
          'Authorization': 'Bearer ${userProvider.user.token}',
          'Content-Type': 'application/json',
        },
      );

      httpErrorHandler(
        response: res,
        context: context,
        onSuccess: () {
          for (var object in jsonDecode(res.body)) {
            commentList.add(
              Comment.fromMap(object),
            );
          }

          final paginationHeader = res.headers['pagination'];
          if (paginationHeader != null) {
            final paginationData = jsonDecode(paginationHeader);
            totalPages = paginationData['totalPages'];
          }
        },
      );
    } catch (error) {
      IconSnackBar.show(
        context,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );
    }

    return {
      'comments': commentList,
      'totalPages': totalPages,
    };
  }

  Future<bool> toggleLike({
    required BuildContext context,
    required String postId,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    try {
      http.Response response = await http.post(
        Uri.parse('$uri/gateway/posts/toggle-like/$postId'),
        headers: {
          'Authorization': 'Bearer ${userProvider.user.token}',
          'Content-Type': 'application/json',
        },
      );

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {},
      );
      return true;
    } catch (e) {
      IconSnackBar.show(
        context,
        label: 'Error: ${e.toString()}',
        snackBarType: SnackBarType.fail,
      );

      return false;
    }
  }

  Future<bool> toggleCommentLike({
    required BuildContext context,
    required String commentId,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    try {
      http.Response response = await http.post(
        Uri.parse('$uri/gateway/comments/toggle-like/$commentId'),
        headers: {
          'Authorization': 'Bearer ${userProvider.user.token}',
          'Content-Type': 'application/json',
        },
      );

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {},
      );
      return true;
    } catch (e) {
      IconSnackBar.show(
        context,
        label: 'Error: ${e.toString()}',
        snackBarType: SnackBarType.fail,
      );

      return false;
    }
  }
}
