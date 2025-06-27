import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/error_handling.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/court.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class FacilityDetailService {
  Future<List<Court>> fetchCourtByFacilityId(
    BuildContext context,
    String facilityId,
  ) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    List<Court> courtList = [];
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/gateway/courts?facilityId=$facilityId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${userProvider.user.token}',
        },
      );

      httpErrorHandler(
        response: res,
        context: context,
        onSuccess: () {
          for (var object in jsonDecode(res.body)) {
            courtList.add(
              Court.fromJson(
                jsonEncode(object),
              ),
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

    return courtList;
  }

  Future<void> deleteCourt(
    BuildContext context,
    String courtId,
  ) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    try {
      final response = await http.delete(
        Uri.parse('$uri/manager/delete-court/$courtId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${userProvider.user.token}',
        },
      );

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          IconSnackBar.show(
            context,
            label: 'Delete court successfully',
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

  Future<bool> checkIntersect(
    BuildContext context,
    String courtId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    try {
      final requestBody = {
        "courtId": courtId,
        "dateTimePeriod": {
          "hourFrom": startTime.toIso8601String(),
          "hourTo": endTime.toIso8601String(),
        },
      };

      print(
          '🔍 [FacilityDetailService] Request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('$uri/gateway/orders/check-conflict'),
        body: jsonEncode(requestBody),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${userProvider.user.token}',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      IconSnackBar.show(
        context,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );
      return false;
    }
  }

  Future<Map<String, dynamic>> getFacilityRatingsPaginated({
    required BuildContext context,
    required String facilityId,
    int pageNumber = 1,
    int pageSize = 8,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    List<dynamic> ratings = [];
    Map<String, dynamic> paginationInfo = {
      'currentPage': pageNumber,
      'itemsPerPage': pageSize,
      'totalItems': 0,
      'totalPages': 1,
    };

    try {
      http.Response response = await http.get(
        Uri.parse(
            '$uri/gateway/ratings?facilityId=$facilityId&pageSize=$pageSize&pageNumber=$pageNumber'),
        headers: {
          'Authorization': 'Bearer ${userProvider.user.token}',
          'Content-Type': 'application/json',
        },
      );

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          final responseData = json.decode(response.body);

          // Handle both array response and object response with data field
          if (responseData is List) {
            ratings = responseData;
          } else if (responseData is Map && responseData.containsKey('data')) {
            ratings = responseData['data'] ?? [];
          } else {
            ratings = [];
          }

          // Parse pagination info from headers
          final paginationHeader = response.headers['pagination'];
          if (paginationHeader != null && paginationHeader.isNotEmpty) {
            try {
              final headerData = jsonDecode(paginationHeader);
              paginationInfo = {
                'currentPage': headerData['currentPage'] ?? pageNumber,
                'itemsPerPage': headerData['itemsPerPage'] ?? pageSize,
                'totalItems': headerData['totalItems'] ?? 0,
                'totalPages': headerData['totalPages'] ?? 1,
              };
              print('[RatingService] Pagination from header: $paginationInfo');
            } catch (e) {
              print('[RatingService] Error parsing pagination header: $e');
            }
          } else {
            paginationInfo = {
              'currentPage': pageNumber,
              'itemsPerPage': pageSize,
              'totalItems': ratings.length,
              'totalPages':
                  ratings.length < pageSize ? pageNumber : pageNumber + 1,
            };
            print('[RatingService] No pagination header found, using fallback');
          }
        },
      );
    } catch (e) {
      print('[RatingService] Error fetching facility ratings: $e');
      IconSnackBar.show(
        context,
        label: 'Error loading ratings: ${e.toString()}',
        snackBarType: SnackBarType.fail,
      );
    }

    return {
      'ratings': ratings,
      'pagination': paginationInfo,
    };
  }

  Future<List<dynamic>> getRecentFacilityRatings({
    required BuildContext context,
    required String facilityId,
    int limit = 3,
  }) async {
    final result = await getFacilityRatingsPaginated(
      context: context,
      facilityId: facilityId,
      pageNumber: 1,
      pageSize: limit,
    );
    return result['ratings'] as List<dynamic>;
  }
}
