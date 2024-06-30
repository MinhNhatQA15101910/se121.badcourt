import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/error_handling.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/providers/sort_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchService {
  Future<List<Facility>> fetchAllFacilities({
    required BuildContext context,
    String? province,
    double? minPrice,
    double? maxPrice,
    Sort? sort,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    final prefs = await SharedPreferences.getInstance();

    List<Facility> facilities = [];
    bool isQuery = false;

    String requestUri = '$uri/player/facilities';
    if (province != null) {
      requestUri += '?province=$province';
      isQuery = true;
    }

    if (minPrice != null) {
      if (isQuery)
        requestUri += '&min_price=$minPrice';
      else
        requestUri += '?min_price=$minPrice';
      isQuery = true;
    }

    if (maxPrice != null) {
      if (isQuery)
        requestUri += '&max_price=$maxPrice';
      else
        requestUri += '?max_price=$maxPrice';
      isQuery = true;
    }

    if (sort != null) {
      if (isQuery)
        requestUri += '&sort=${sort.sort}&order=${sort.order}';
      else
        requestUri += '?sort=${sort.sort}&order=${sort.order}';
      isQuery = true;

      if (sort.sort == "location") {
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
          'x-auth-token': userProvider.user.token,
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
          'x-auth-token': userProvider.user.token,
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
