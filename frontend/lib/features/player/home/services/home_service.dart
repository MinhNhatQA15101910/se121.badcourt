import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/error_handling.dart';
import 'dart:convert';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeService {
  Future<List<Facility>> fetchAllFacilities({
    required BuildContext context,
    String? province,
    String? sort,
    String? order,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    final prefs = await SharedPreferences.getInstance();
    List<Facility> facilities = [];
    bool isQuery = false;

    String requestUri = '$uri/api/facilities';
    if (province != null) {
      requestUri += '?province=$province';
      isQuery = true;
    }
    if (sort != null && order != null) {
      if (isQuery)
        requestUri += '&sort=$sort&order=$order';
      else
        requestUri += '?sort=$sort&order=$order';

      if (sort == "location") {
        final latitude = prefs.getDouble('latitude');
        final longitude = prefs.getDouble('longitude');
        requestUri += '&lat=$latitude&lon=$longitude';
      }
    }

    try {
      http.Response response = await http.get(
        Uri.parse(requestUri),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${userProvider.user.token}',
        },
      );

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          for (var object in jsonDecode(response.body)) {
            facilities.add(
              Facility.fromJson(
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

    return facilities;
  }

  Future<List<String>> fetchAllProvinces({
    required BuildContext context,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    List<String> provinces = [];

    try {
      http.Response response = await http.get(
        Uri.parse('$uri/player/facilities/provinces'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${userProvider.user.token}',
        },
      );

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          for (var object in jsonDecode(response.body)) {
            provinces.add(object);
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

    return provinces;
  }
}
