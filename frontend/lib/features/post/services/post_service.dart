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
  // Maximum file size: 100MB in bytes
  static const int maxFileSize = 100 * 1024 * 1024; // 100MB
  
  // Supported video formats
  static const List<String> supportedVideoFormats = [
    '.mp4', '.mov', '.avi', '.mkv', '.wmv', '.flv', '.webm', '.m4v'
  ];
  
  // Supported image formats
  static const List<String> supportedImageFormats = [
    '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'
  ];

  // Validate file size and format
  bool _validateFile(File file) {
    final fileSize = file.lengthSync();
    final fileName = file.path.toLowerCase();
    
    // Check file size
    if (fileSize > maxFileSize) {
      return false;
    }
    
    // Check if it's a supported format
    bool isValidFormat = false;
    for (String format in [...supportedImageFormats, ...supportedVideoFormats]) {
      if (fileName.endsWith(format)) {
        isValidFormat = true;
        break;
      }
    }
    
    return isValidFormat;
  }

  // Check if file is a video

  Future<void> createPost(
    BuildContext context,
    List<File> postFiles,
    String description,
    String title,
  ) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      // Validate all files before uploading
      for (File file in postFiles) {
        if (!_validateFile(file)) {
          final fileSize = file.lengthSync();
          final fileName = file.path.split('/').last;
          
          if (fileSize > maxFileSize) {
            IconSnackBar.show(
              context,
              label: 'File "$fileName" exceeds 100MB limit',
              snackBarType: SnackBarType.fail,
            );
            return;
          } else {
            IconSnackBar.show(
              context,
              label: 'File "$fileName" has unsupported format',
              snackBarType: SnackBarType.fail,
            );
            return;
          }
        }
      }

      var request =
          http.MultipartRequest('POST', Uri.parse('$uri/gateway/posts'));
      request.headers['Authorization'] = 'Bearer ${userProvider.user.token}';

      request.fields['title'] = title;
      request.fields['content'] = description;

      for (File file in postFiles) {
        var multipartFile = await http.MultipartFile.fromPath(
          'resources',
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
    int pageNumber = 1,
    int pageSize = 10,
    String searchQuery = '',
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    List<Post> posts = [];
    int totalPages = 1;

    try {
      // Build the URL with search query if provided
      String url = '$uri/gateway/posts?pageSize=$pageSize&pageNumber=$pageNumber';
      if (searchQuery.isNotEmpty) {
        url += '&search=${Uri.encodeComponent(searchQuery)}';
      }

      http.Response response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${userProvider.user.token}',
        },
      );

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          try {
            final jsonResponse = jsonDecode(response.body);
            
            // Handle direct array response (not wrapped in object)
            List<dynamic> postsData;
            if (jsonResponse is List) {
              // Direct array response
              postsData = jsonResponse;
              totalPages = 1; // Default since no pagination info in direct array
            } else if (jsonResponse is Map) {
              // Object response with posts key
              postsData = jsonResponse['posts'] ?? [];
              totalPages = _parseToInt(jsonResponse['totalPages']) ?? 1;
            } else {
              postsData = [];
            }
            
            // Parse each post
            for (var object in postsData) {
              try {
                posts.add(Post.fromMap(object));
              } catch (e) {
                print('Error parsing individual post: $e');
                print('Post data: $object');
                // Continue with other posts even if one fails
              }
            }
          } catch (e) {
            print('Error parsing response: $e');
            print('Response body: ${response.body}');
            IconSnackBar.show(
              context,
              label: 'Error parsing posts data: ${e.toString()}',
              snackBarType: SnackBarType.fail,
            );
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
      'posts': posts,
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
          try {
            final data = jsonDecode(res.body);
            post = Post.fromMap(data);
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
    List<File> mediaFiles, // Changed from 'images' to 'mediaFiles'
  ) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    try {
      // Validate all media files before uploading
      for (File file in mediaFiles) {
        if (!_validateFile(file)) {
          final fileSize = file.lengthSync();
          final fileName = file.path.split('/').last;
          
          if (fileSize > maxFileSize) {
            IconSnackBar.show(
              context,
              label: 'File "$fileName" exceeds 100MB limit',
              snackBarType: SnackBarType.fail,
            );
            return;
          } else {
            IconSnackBar.show(
              context,
              label: 'File "$fileName" has unsupported format',
              snackBarType: SnackBarType.fail,
            );
            return;
          }
        }
      }

      final uriObj = Uri.parse('$uri/gateway/comments');
      final request = http.MultipartRequest('POST', uriObj);

      request.headers['Authorization'] = 'Bearer ${userProvider.user.token}';

      request.fields['postId'] = postId;
      request.fields['content'] = content;

      // Add media files to the request
      for (File mediaFile in mediaFiles) {
        var multipartFile = await http.MultipartFile.fromPath(
          'resources',
          mediaFile.path,
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
            label: 'Comment with media added successfully',
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
          try {
            final responseData = jsonDecode(res.body);
            
            // Handle both array and object response formats
            List<dynamic> commentsData;
            if (responseData is List) {
              commentsData = responseData;
            } else if (responseData is Map && responseData['comments'] != null) {
              commentsData = responseData['comments'];
            } else {
              commentsData = [];
            }

            for (var object in commentsData) {
              try {
                commentList.add(Comment.fromMap(object));
              } catch (e) {
                print('Error parsing comment: $e');
                print('Comment data: $object');
              }
            }

            final paginationHeader = res.headers['pagination'];
            if (paginationHeader != null) {
              final paginationData = jsonDecode(paginationHeader);
              totalPages = _parseToInt(paginationData['totalPages']) ?? 0;
            }
          } catch (e) {
            print('Error parsing comments response: $e');
            IconSnackBar.show(
              context,
              label: 'Error parsing comments data',
              snackBarType: SnackBarType.fail,
            );
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

  // Helper method to safely parse int from dynamic value
  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    if (value is double) return value.toInt();
    return null;
  }

  // Helper method to get file size in a readable format
  String getFileSizeString(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Helper method to check if a URL is a video
  static bool isVideoUrl(String url) {
    final lowerUrl = url.toLowerCase();
    for (String format in supportedVideoFormats) {
      if (lowerUrl.contains(format.replaceAll('.', ''))) {
        return true;
      }
    }
    return false;
  }
}
