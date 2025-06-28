import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/error_handling.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/order.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class OrderService {
  Future<Map<String, dynamic>> fetchAllOrdersPaginated({
    required BuildContext context,
    int pageNumber = 1,
    int pageSize = 10,
    String? state,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    List<Order> orders = [];
    Map<String, dynamic> paginationInfo = {
      'currentPage': pageNumber,
      'itemsPerPage': pageSize,
      'totalItems': 0,
      'totalPages': 1,
    };

    try {
      String baseUrl = userProvider.user.roles.contains('Manager')
          ? '$uri/gateway/manager-dashboard/orders'
          : '$uri/gateway/orders';

      String url = '$baseUrl?pageSize=$pageSize&pageNumber=$pageNumber';

      if (state != null && state.isNotEmpty) {
        url += '&state=$state';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${userProvider.user.token}',
        },
      );

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          final responseData = jsonDecode(response.body);

          final List<dynamic> ordersData = responseData is List
              ? responseData
              : (responseData is Map && responseData['data'] is List)
                  ? responseData['data']
                  : [];

          orders = ordersData.map((orderJson) {
            return Order.fromJson(jsonEncode(orderJson));
          }).toList();

          final paginationHeader = response.headers['pagination'];
          if (paginationHeader != null && paginationHeader.isNotEmpty) {
            try {
              final headerData = jsonDecode(paginationHeader);
              paginationInfo = {
                'currentPage': headerData['currentPage'] ?? pageNumber,
                'itemsPerPage': headerData['itemsPerPage'] ?? pageSize,
                'totalItems': headerData['totalItems'] ?? 0,
                'totalPages': headerData['totalPages'] ?? 1,
              };
              print('[BookingService] Pagination from header: $paginationInfo');
            } catch (e) {
              print('[BookingService] Error parsing pagination header: $e');
            }
          } else {
            paginationInfo = {
              'currentPage': pageNumber,
              'itemsPerPage': pageSize,
              'totalItems': orders.length,
              'totalPages':
                  orders.length < pageSize ? pageNumber : pageNumber + 1,
            };
            print(
                '[BookingService] No pagination header found, using fallback');
          }
        },
      );
    } catch (error) {
      print('[BookingService] Error fetching orders: $error');
      IconSnackBar.show(
        context,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );
    }

    return {
      'orders': orders,
      'pagination': paginationInfo,
    };
  }

  // Keep the old method for backward compatibility
  Future<List<Order>> fetchAllOrders({
    required BuildContext context,
    int pageNumber = 1,
    int pageSize = 4,
  }) async {
    final result = await fetchAllOrdersPaginated(
      context: context,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
    return result['orders'];
  }

  Future<Order?> fetchOrderById({
    required BuildContext context,
    required String orderId,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    try {
      final response = await http.get(
        Uri.parse('$uri/gateway/orders/$orderId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${userProvider.user.token}',
        },
      );

      Order? order;

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          order = Order.fromJson(response.body);
        },
      );

      return order;
    } catch (error) {
      IconSnackBar.show(
        context,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );
      return null;
    }
  }

  Future<bool> cancelOrder({
    required BuildContext context,
    required String orderId,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    try {
      http.Response response = await http.put(
        Uri.parse('$uri/gateway/orders/cancel/$orderId'),
        headers: {
          'Authorization': 'Bearer ${userProvider.user.token}',
          'Content-Type': 'application/json',
        },
      );

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          IconSnackBar.show(
            context,
            label: 'Cancel booking successfully',
            snackBarType: SnackBarType.success,
          );
        },
      );

      return true;
    } catch (e) {
      IconSnackBar.show(
        context,
        label: 'Error: ${e.toString()}',
        snackBarType: SnackBarType.fail,
      );

      return false;
    }
  }
}
