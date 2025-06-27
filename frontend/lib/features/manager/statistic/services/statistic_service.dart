import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/constants/error_handling.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/order.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:frontend/models/court.dart';

class StatisticService {
  // API 1: Get manager dashboard summary
  Future<Map<String, dynamic>?> getDashboardSummary(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final response = await http.get(
        Uri.parse('$uri/gateway/manager-dashboard/summary'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${userProvider.user.token}',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load dashboard summary');
      }
    } catch (error) {
      print('Error getting dashboard summary: $error');
      return null;
    }
  }

  // API 2: Get monthly revenue by year
  Future<List<Map<String, dynamic>>?> getMonthlyRevenue(
    BuildContext context, 
    int year
  ) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final response = await http.get(
        Uri.parse('$uri/gateway/manager-dashboard/monthly-revenue?year=$year'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${userProvider.user.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load monthly revenue');
      }
    } catch (error) {
      print('Error getting monthly revenue: $error');
      return null;
    }
  }

  // API 3: Get orders with filters
  Future<List<Order>?> getOrders(
    BuildContext context, {
    String? facilityId,
    String? courtId,
    String? state,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Build query parameters
    Map<String, String> queryParams = {};
    if (facilityId != null && facilityId.isNotEmpty) {
      queryParams['facilityId'] = facilityId;
    }
    if (courtId != null && courtId.isNotEmpty) {
      queryParams['courtId'] = courtId;
    }
    if (state != null && state.isNotEmpty) {
      queryParams['state'] = state;
    }

    final ordersUri = Uri.parse('$uri/gateway/manager-dashboard/orders')
        .replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        ordersUri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${userProvider.user.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (error) {
      print('Error getting orders: $error');
      return null;
    }
  }

  // Add method to fetch courts
  Future<List<Court>> fetchCourtByFacilityId(
    BuildContext context,
    String facilityId,
  ) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Court> courtList = [];
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/gateway/courts?facilityId=$facilityId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${userProvider.user.token}',
        },
      );

      if (res.statusCode == 200) {
        for (var object in jsonDecode(res.body)) {
          courtList.add(Court.fromJson(jsonEncode(object)));
        }
      }
    } catch (error) {
      print('Error fetching courts: $error');
    }
    return courtList;
  }
}
