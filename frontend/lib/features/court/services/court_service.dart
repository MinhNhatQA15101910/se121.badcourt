import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/error_handling.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/court.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class CourtService{
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

  Future<void> updateCourtInactive(
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
        "dateTimePeriod": {
          "hourFrom": startTime.toIso8601String(),
          "hourTo": endTime.toIso8601String(),
        },
        "timeZoneId": "SE Asia Standard Time"
      };

      print('🔍 [CourtService] Update inactive request body: ${jsonEncode(requestBody)}');

      final response = await http.put(
        Uri.parse('$uri/gateway/courts/update-inactive/$courtId'),
        body: jsonEncode(requestBody),
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
            label: 'Court inactive period updated successfully',
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