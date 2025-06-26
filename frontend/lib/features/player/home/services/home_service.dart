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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final facilities = <Facility>[];

    try {
      final prefs = await SharedPreferences.getInstance();
      final queryParams = {
        'state': 'approved',
        if (province != null) 'province': province,
        if (sort != null && order != null) ...{
          'sort': sort,
          'order': order,
          if (sort == 'location') ...{
            'lat': prefs.getDouble('latitude')?.toString() ?? '',
            'lon': prefs.getDouble('longitude')?.toString() ?? '',
          }
        },
      };

      final requestUri = Uri.parse('$uri/gateway/facilities')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        requestUri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${userProvider.user.token}',
        },
      );

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          final data = jsonDecode(response.body) as List;
          facilities
              .addAll(data.map((item) => Facility.fromJson(jsonEncode(item))));
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
        Uri.parse('$uri/gateway/facilities/provinces'),
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
