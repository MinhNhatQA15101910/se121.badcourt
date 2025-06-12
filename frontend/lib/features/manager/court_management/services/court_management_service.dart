import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/error_handling.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/court.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/providers/manager/current_facility_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class CourtManagementService {
  Future<Court?> addCourt({
    required BuildContext context,
    required String name,
    required String description,
    required int pricePerHour,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    final currentFacilityProvider = Provider.of<CurrentFacilityProvider>(
      context,
      listen: false,
    );

    Court? court = null;
    try {
      http.Response response = await http.post(
        Uri.parse('$uri/gateway/courts'),
        body: jsonEncode({
          'facilityId': currentFacilityProvider.currentFacility.id,
          'courtName': name,
          'description': description,
          'pricePerHour': pricePerHour,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${userProvider.user.token}',
        },
      );

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          court = Court.fromJson(
            jsonEncode(jsonDecode(response.body)),
          );
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

    return court;
  }

  Future<Court?> updateCourt({
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

    Court? court = null;
    try {
      http.Response response = await http.put(
        Uri.parse('$uri/gateway/courts/$courtId'),
        body: jsonEncode({
          'courtName': name,
          'description': description,
          'pricePerHour': pricePerHour,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${userProvider.user.token}',
        },
      );

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          court = Court(
            id: courtId,
            courtName: name,
            description: description,
            pricePerHour: pricePerHour,
            state: 'Active',
            createdAt: DateTime.now().toUtc().toIso8601String(),
            orderPeriods: [], inactivePeriods: [],
          );

          IconSnackBar.show(
            context,
            label: 'Court updated successfully.',
            snackBarType: SnackBarType.success,
          );
        },
      );
    } catch (error) {}

    return court;
  }

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

  Future<Facility?> fetchFacilityById({
    required BuildContext context,
    required String facilityId,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    Facility? facility = null;

    try {
      http.Response res = await http.get(
        Uri.parse('$uri/gateway/facilities/$facilityId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${userProvider.user.token}',
        },
      );

      httpErrorHandler(
        response: res,
        context: context,
        onSuccess: () {
          facility = Facility.fromJson(
            jsonEncode(
              jsonDecode(res.body),
            ),
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

    return facility;
  }

  Future<Court?> fetchCourtById({
    required BuildContext context,
    required String courtId,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    Court? court = null;

    try {
      http.Response res = await http.get(
        Uri.parse('$uri/gateway/courts/$courtId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${userProvider.user.token}',
        },
      );

      httpErrorHandler(
        response: res,
        context: context,
        onSuccess: () {
          court = Court.fromJson(
            jsonEncode(
              jsonDecode(res.body),
            ),
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

    return court;
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

  Future<void> updateActiveSchedule(
    BuildContext context,
    String facilityId,
    Map<String, dynamic> activeSchedule,
  ) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      // Khởi tạo requestBody rỗng
      Map<String, dynamic> requestBody = {};

      // Lặp qua từng ngày trong activeSchedule
      activeSchedule.forEach((day, schedule) {
        if (schedule != null) {
          final from = schedule['hourFrom'];
          final to = schedule['hourTo'];

          print('[$day] hourFrom: $from, hourTo: $to');

          requestBody[day] = {
            "hourFrom": from,
            "hourTo": to,
          };
        }
      });

      print("Request Body JSON: ${jsonEncode(requestBody)}");

      final response = await http.put(
        Uri.parse('$uri/gateway/facilities/update-active/$facilityId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${userProvider.user.token}',
        },
        body: jsonEncode(requestBody),
      );

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {},
      );
    } catch (error) {
      IconSnackBar.show(
        context,
        label: 'Failed to update active schedule',
        snackBarType: SnackBarType.fail,
      );
    }
  }
}
