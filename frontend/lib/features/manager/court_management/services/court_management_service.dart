import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/error_handling.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class CourtManagementService {
  Future<void> addCourt({
    required BuildContext context,
    required String facilityId,
    required String name,
    required String description,
    required int pricePerHour,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    try {
      http.Response response = await http.post(
        Uri.parse('$uri/manager/add-court'),
        body: jsonEncode({
          'facility_id': facilityId,
          'name': name,
          'description': description,
          'price_per_hour': pricePerHour,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          Navigator.pop(context);
          IconSnackBar.show(
            context,
            label: 'Court added successfully.',
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

  Future<void> updateCourt({
    required BuildContext context,
    required String courtId,
    required String name,
    required String description,
    required int pricePerHour,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    try {
      http.Response response = await http.put(
        Uri.parse('$uri/manager/update-court/$courtId'),
        body: jsonEncode({
          'name': name,
          'description': description,
          'price_per_hour': pricePerHour,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          Navigator.pop(context);
          IconSnackBar.show(
            context,
            label: 'Court updated successfully.',
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
