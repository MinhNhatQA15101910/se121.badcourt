import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/error_handling.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ManagerHomeService {
  Future<bool> deleteFacility({
    required BuildContext context,
    required String facilityId,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    try {
      http.Response response = await http.delete(
        Uri.parse('$uri/gateway/facilities/$facilityId'),
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
            label: 'Delete facility successfully',
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

  Future<String?> getAdminUserId(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final response = await http.get(
        Uri.parse('$uri/gateway/users/admin'),
        headers: {
          'Authorization': 'Bearer ${userProvider.user.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['id'];
      } else {
        IconSnackBar.show(
          context,
          label: 'Failed to get admin ID: ${response.statusCode}',
          snackBarType: SnackBarType.fail,
        );
        return null;
      }
    } catch (e) {
      IconSnackBar.show(
        context,
        label: 'Error: ${e.toString()}',
        snackBarType: SnackBarType.fail,
      );
      return null;
    }
  }
}
