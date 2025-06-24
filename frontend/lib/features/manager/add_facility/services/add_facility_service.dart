import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/error_handling.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/add_facility/models/detail_address.dart';
import 'package:frontend/features/manager/add_facility/providers/new_facility_provider.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AddFacilityService {
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

  Future<void> submitFacility({
    required BuildContext context,
    Facility? existingFacility, // Optional parameter for update mode
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    final newFacilityProvider = Provider.of<NewFacilityProvider>(
      context,
      listen: false,
    );

    try {
      // Determine if this is an update or create operation
      final bool isUpdate = existingFacility != null;
      final String method = isUpdate ? 'PUT' : 'POST';
      final String endpoint = isUpdate 
          ? '$uri/gateway/facilities/${existingFacility.id}'
          : '$uri/gateway/facilities';

      final request = http.MultipartRequest(method, Uri.parse(endpoint));

      // Add form fields
      request.fields.addAll({
        "facilityName": newFacilityProvider.newFacility.facilityName,
        "lon": newFacilityProvider.newFacility.lat.toString(),
        "lat": newFacilityProvider.newFacility.lon.toString(),
        "detailAddress": newFacilityProvider.newFacility.detailAddress,
        "province": newFacilityProvider.newFacility.province,
        "fullName": newFacilityProvider.newFacility.managerInfo.fullName,
        "email": newFacilityProvider.newFacility.managerInfo.email,
        "facebookUrl": newFacilityProvider.newFacility.facebookUrl,
        "phoneNumber": newFacilityProvider.newFacility.managerInfo.phoneNumber,
        "citizenId": newFacilityProvider.newFacility.managerInfo.citizenId,
        "description": newFacilityProvider.newFacility.description,
        "policy": newFacilityProvider.newFacility.policy,
      });

      // Add facility images (only if new images are selected)
      if (newFacilityProvider.facilityImages.isNotEmpty) {
        for (File file in newFacilityProvider.facilityImages) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'facilityImages',
              file.path,
            ),
          );
        }
      }

      // Add business license images (only if new images are selected)
      if (newFacilityProvider.licenseImages.isNotEmpty) {
        for (File file in newFacilityProvider.licenseImages) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'businessLicenseImages',
              file.path,
            ),
          );
        }
      }

      // Add individual document images (only if new images are selected)
      if (newFacilityProvider.frontCitizenIdImage.path.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'citizenImageFront',
            newFacilityProvider.frontCitizenIdImage.path,
          ),
        );
      }

      if (newFacilityProvider.backCitizenIdImage.path.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'citizenImageBack',
            newFacilityProvider.backCitizenIdImage.path,
          ),
        );
      }

      if (newFacilityProvider.frontBankCardImage.path.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'bankCardFront',
            newFacilityProvider.frontBankCardImage.path,
          ),
        );
      }

      if (newFacilityProvider.backBankCardImage.path.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'bankCardBack',
            newFacilityProvider.backBankCardImage.path,
          ),
        );
      }

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer ${userProvider.user.token}',
      });

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          IconSnackBar.show(
            context,
            label: isUpdate 
                ? 'Facility updated successfully'
                : 'Facility registered successfully',
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

  // Keep the old method for backward compatibility
  Future<void> registerFacility({required BuildContext context}) async {
    return submitFacility(context: context);
  }

  // New method specifically for updating
  Future<void> updateFacility({
    required BuildContext context,
    required Facility facility,
  }) async {
    return submitFacility(context: context, existingFacility: facility);
  }
}
