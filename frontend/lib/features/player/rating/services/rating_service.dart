import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/error_handling.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

class RatingService {
  // Submit rating for an order
  Future<bool> rateOrder({
    required BuildContext context,
    required String orderId,
    required int stars,
    required String feedback,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    try {
      final requestBody = {
        'stars': stars,
        'feedback': feedback,
      };

      http.Response response = await http.post(
        Uri.parse('$uri/gateway/orders/rate/$orderId'),
        headers: {
          'Authorization': 'Bearer ${userProvider.user.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      bool success = false;
      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          success = true;
          IconSnackBar.show(
            context,
            label: 'Rating submitted successfully',
            snackBarType: SnackBarType.success,
          );
        },
      );

      return success;
    } catch (e) {
      IconSnackBar.show(
        context,
        label: 'Error: ${e.toString()}',
        snackBarType: SnackBarType.fail,
      );

      return false;
    }
  }

  // Get ratings for a facility (if needed in the future)
  Future<List<dynamic>?> getFacilityRatings({
    required BuildContext context,
    required String facilityId,
    int page = 1,
    int limit = 10,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    try {
      http.Response response = await http.get(
        Uri.parse('$uri/gateway/facilities/$facilityId/ratings?page=$page&limit=$limit'),
        headers: {
          'Authorization': 'Bearer ${userProvider.user.token}',
          'Content-Type': 'application/json',
        },
      );

      List<dynamic>? ratings;
      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          final responseData = json.decode(response.body);
          ratings = responseData['data'] ?? [];
        },
      );

      return ratings;
    } catch (e) {
      IconSnackBar.show(
        context,
        label: 'Error loading ratings: ${e.toString()}',
        snackBarType: SnackBarType.fail,
      );
      return null;
    }
  }

  // Update an existing rating (if needed in the future)
  Future<bool> updateRating({
    required BuildContext context,
    required String ratingId,
    required int stars,
    required String feedback,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    try {
      final requestBody = {
        'stars': stars,
        'feedback': feedback,
      };

      http.Response response = await http.put(
        Uri.parse('$uri/gateway/ratings/$ratingId'),
        headers: {
          'Authorization': 'Bearer ${userProvider.user.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      bool success = false;
      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          success = true;
          IconSnackBar.show(
            context,
            label: 'Rating updated successfully',
            snackBarType: SnackBarType.success,
          );
        },
      );

      return success;
    } catch (e) {
      IconSnackBar.show(
        context,
        label: 'Error updating rating: ${e.toString()}',
        snackBarType: SnackBarType.fail,
      );

      return false;
    }
  }

  // Delete a rating (if needed in the future)
  Future<bool> deleteRating({
    required BuildContext context,
    required String ratingId,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    try {
      http.Response response = await http.delete(
        Uri.parse('$uri/gateway/ratings/$ratingId'),
        headers: {
          'Authorization': 'Bearer ${userProvider.user.token}',
          'Content-Type': 'application/json',
        },
      );

      bool success = false;
      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          success = true;
          IconSnackBar.show(
            context,
            label: 'Rating deleted successfully',
            snackBarType: SnackBarType.success,
          );
        },
      );

      return success;
    } catch (e) {
      IconSnackBar.show(
        context,
        label: 'Error deleting rating: ${e.toString()}',
        snackBarType: SnackBarType.fail,
      );

      return false;
    }
  }

  Future<Map<String, dynamic>?> getRatingById({
    required BuildContext context,
    required String ratingId,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    try {
      http.Response response = await http.get(
        Uri.parse('$uri/gateway/ratings/$ratingId'),
        headers: {
          'Authorization': 'Bearer ${userProvider.user.token}',
          'Content-Type': 'application/json',
        },
      );

      Map<String, dynamic>? ratingData;
      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          ratingData = json.decode(response.body);
        },
      );

      return ratingData;
    } catch (e) {
      IconSnackBar.show(
        context,
        label: 'Error loading rating: ${e.toString()}',
        snackBarType: SnackBarType.fail,
      );
      return null;
    }
  }
}
