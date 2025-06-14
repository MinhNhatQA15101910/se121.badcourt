import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/error_handling.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/order.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class BookingManagementService {
  Future<List<Order>> fetchAllOrders({
    required BuildContext context,
    int pageNumber = 1,
    int pageSize = 4,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    List<Order> orders = [];

    try {
      http.Response response = await http.get(
        Uri.parse(
            '$uri/gateway/orders'),
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
            orders.add(
              Order.fromJson(
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

    return orders;
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
}
