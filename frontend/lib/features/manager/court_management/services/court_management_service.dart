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
        Uri.parse('$uri/api/courts'),
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
      http.Response response = await http.patch(
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
          court = Court.fromJson(
            jsonEncode(jsonDecode(response.body)),
          );
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
        Uri.parse('$uri/manager/courts?facility_id=$facilityId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
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
        Uri.parse('$uri/manager/facilities/$facilityId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
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
          'x-auth-token': userProvider.user.token,
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

  Future<void> updateActiveSchedule(BuildContext context, String facilityId,
      Map<String, dynamic> activeSchedule) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    try {
      Map<String, dynamic> requestBody = {"active": {}};

      if (activeSchedule['monday'] != null) {
        requestBody['active']['monday'] = {
          "hour_from": activeSchedule['monday']['hour_from'],
          "hour_to": activeSchedule['monday']['hour_to'],
        };
      }
      if (activeSchedule['tuesday'] != null) {
        requestBody['active']['tuesday'] = {
          "hour_from": activeSchedule['tuesday']['hour_from'],
          "hour_to": activeSchedule['tuesday']['hour_to'],
        };
      }
      if (activeSchedule['wednesday'] != null) {
        requestBody['active']['wednesday'] = {
          "hour_from": activeSchedule['wednesday']['hour_from'],
          "hour_to": activeSchedule['wednesday']['hour_to'],
        };
      }
      if (activeSchedule['thursday'] != null) {
        requestBody['active']['thursday'] = {
          "hour_from": activeSchedule['thursday']['hour_from'],
          "hour_to": activeSchedule['thursday']['hour_to'],
        };
      }
      if (activeSchedule['friday'] != null) {
        requestBody['active']['friday'] = {
          "hour_from": activeSchedule['friday']['hour_from'],
          "hour_to": activeSchedule['friday']['hour_to'],
        };
      }
      if (activeSchedule['saturday'] != null) {
        requestBody['active']['saturday'] = {
          "hour_from": activeSchedule['saturday']['hour_from'],
          "hour_to": activeSchedule['saturday']['hour_to'],
        };
      }
      if (activeSchedule['sunday'] != null) {
        requestBody['active']['sunday'] = {
          "hour_from": activeSchedule['sunday']['hour_from'],
          "hour_to": activeSchedule['sunday']['hour_to'],
        };
      }

      final response = await http.patch(
        Uri.parse('$uri/manager/update-active/$facilityId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
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
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );
    }
  }
}
