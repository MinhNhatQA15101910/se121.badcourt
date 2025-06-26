import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/error_handling.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/add_facility/models/detail_address.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/providers/sort_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchService {
  Future<String?> fetchAddressRefId({
    required BuildContext context,
    String? searchText,
    double? lat,
    double? lng,
  }) async {
    String apiUrl = 'https://maps.vietmap.vn/api/';
    if (searchText != null) {
      apiUrl +=
          'search/v3?apikey=${dotenv.env['VIETMAP_API_KEY']!}&text=$searchText';
    } else if (lat != null && lng != null) {
      apiUrl +=
          'reverse/v3?apikey=${dotenv.env['VIETMAP_API_KEY']!}&lat=$lat&lng=$lng';
    }

    String? result = null;

    try {
      http.Response response = await http.get(Uri.parse(apiUrl));

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          List<dynamic> data = jsonDecode(response.body);

          if (data.isNotEmpty) {
            result = data[0]['ref_id'] as String?;
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

    return result;
  }

  Future<DetailAddress?> fetchDetailAddress({required String refId}) async {
    String apiUrl = 'https://maps.vietmap.vn/api/place/v3';
    String fullUrl =
        '$apiUrl?apikey=${dotenv.env['VIETMAP_API_KEY']!}&refid=$refId';

    try {
      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return DetailAddress.fromJson(data);
      } else {
        print('HTTP Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }

    return null;
  }

  Future<Map<String, dynamic>> fetchAllFacilities({
    required BuildContext context,
    String? province,
    int? minPrice,
    int? maxPrice,
    String? search,
    Sort? sort,
    int page = 1,
    int limit = 10,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();

    List<Facility> facilities = [];
    int currentPage = 1;
    int totalPages = 1;

    final Map<String, String> queryParams = {};

    // Add pagination parameters
    queryParams['state'] = 'approved';
    queryParams['pageNumber'] = page.toString();
    queryParams['pageSize'] = limit.toString();

    if (province != null) {
      queryParams['province'] = province;
    }

    if (minPrice != null && minPrice > 0) {
      queryParams['minPrice'] = minPrice.toString();
    }

    if (maxPrice != null && maxPrice != double.infinity) {
      queryParams['maxPrice'] = maxPrice.toString();
    }

    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    if (sort != null) {
      queryParams['sortBy'] = sort.order;
      queryParams['orderBy'] = sort.sort;

      if (sort.sort == 'location') {
        final latitude = prefs.getDouble('latitude');
        final longitude = prefs.getDouble('longitude');
        if (latitude != null && longitude != null) {
          queryParams['lat'] = latitude.toString();
          queryParams['lon'] = longitude.toString();
        }
      }
    }

    final uriWithParams = Uri.parse('$uri/gateway/facilities')
        .replace(queryParameters: queryParams);

    try {
      http.Response response = await http.get(
        uriWithParams,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${userProvider.user.token}',
        },
      );

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          final responseData = jsonDecode(response.body);

          // Handle both array response and paginated response
          if (responseData is List) {
            // Old format - just array of facilities
            for (var object in responseData) {
              facilities.add(Facility.fromJson(jsonEncode(object)));
            }
          } else if (responseData is Map<String, dynamic>) {
            // New format - paginated response
            if (responseData['data'] != null) {
              for (var object in responseData['data']) {
                facilities.add(Facility.fromJson(jsonEncode(object)));
              }
            }
            currentPage = responseData['currentPage'] ?? 1;
            totalPages = responseData['totalPages'] ?? 1;
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
      'facilities': facilities,
      'currentPage': currentPage,
      'totalPages': totalPages,
    };
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
