import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class IntroManagerService {
  Future<List<Facility>> fetchFacilitiesByUserId({
    required BuildContext context,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    List<Facility> facilities = [];
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/facilities?userId=${userProvider.user.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${userProvider.user.token}',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        facilities =
            data.map((facility) => Facility.fromMap(facility)).toList();
      } else {
        throw Exception('Failed to load facilities');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load facilities: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }

    return facilities;
  }
}
