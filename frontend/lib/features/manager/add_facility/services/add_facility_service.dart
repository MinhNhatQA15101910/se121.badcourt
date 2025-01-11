import 'dart:convert';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/error_handling.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/add_facility/models/detail_address.dart';
import 'package:frontend/features/manager/add_facility/providers/new_facility_provider.dart';
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

  Future<void> registerFacility({required BuildContext context}) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    final newFacilityProvider = Provider.of<NewFacilityProvider>(
      context,
      listen: false,
    );

    try {
      final cloudinary = CloudinaryPublic('dauyd6npv', 'nkklif97');

      List<String> uploadedFacilityImageUrls = [];
      List<String> uploadedBusinessLicenseImageUrls = [];

      // Upload facility images
      for (File file in newFacilityProvider.facilityImages) {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            file.path,
            folder: 'facilities/${newFacilityProvider.newFacility.name}',
          ),
        );
        uploadedFacilityImageUrls.add(response.secureUrl);
      }

      // Upload business license images
      for (File file in newFacilityProvider.licenseImages) {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            file.path,
            folder: 'business_license/${newFacilityProvider.newFacility.name}',
          ),
        );
        uploadedBusinessLicenseImageUrls.add(response.secureUrl);
      }

      // Upload citizen image front
      CloudinaryResponse citizenFrontResponse = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          newFacilityProvider.frontCitizenIdImage.path,
          folder: 'citizen_images/${newFacilityProvider.newFacility.name}',
        ),
      );
      String? citizenImageUrlFront = citizenFrontResponse.secureUrl;

      // Upload citizen image back
      CloudinaryResponse citizenBackResponse = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          newFacilityProvider.backCitizenIdImage.path,
          folder: 'citizen_images/${newFacilityProvider.newFacility.name}',
        ),
      );
      String? citizenImageUrlBack = citizenBackResponse.secureUrl;

      // Upload bank card front
      CloudinaryResponse bankCardFrontResponse = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          newFacilityProvider.frontBankCardImage.path,
          folder: 'bank_cards/${newFacilityProvider.newFacility.name}',
        ),
      );
      String? bankCardUrlFront = bankCardFrontResponse.secureUrl;

      // Upload bank card back
      CloudinaryResponse bankCardBackResponse = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          newFacilityProvider.backBankCardImage.path,
          folder: 'bank_cards/${newFacilityProvider.newFacility.name}',
        ),
      );
      String? bankCardUrlBack = bankCardBackResponse.secureUrl;

      // Prepare and send the POST request
      http.Response response = await http.post(
        Uri.parse('$uri/manager/register-facility'),
        body: jsonEncode(
          {
            "facility_name": newFacilityProvider.newFacility.name,
            "lat":
                newFacilityProvider.newFacility.location.coordinates.latitude,
            "lon":
                newFacilityProvider.newFacility.location.coordinates.longitude,
            "detail_address": newFacilityProvider.newFacility.detailAddress,
            "province": newFacilityProvider.newFacility.province,
            "facility_image_urls": uploadedFacilityImageUrls,
            "full_name": newFacilityProvider.newFacility.managerInfo.fullName,
            "email": newFacilityProvider.newFacility.managerInfo.email,
            "facebook_url": newFacilityProvider.newFacility.facebookUrl,
            "phone_number":
                newFacilityProvider.newFacility.managerInfo.phoneNumber,
            "citizen_id": newFacilityProvider.newFacility.managerInfo.citizenId,
            "citizen_image_url_front": citizenImageUrlFront,
            "citizen_image_url_back": citizenImageUrlBack,
            "bank_card_url_front": bankCardUrlFront,
            "bank_card_url_back": bankCardUrlBack,
            "business_license_image_urls": uploadedBusinessLicenseImageUrls,
            "description": newFacilityProvider.newFacility.description,
            "policy": newFacilityProvider.newFacility.policy,
          },
        ),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      // Handle response
      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          IconSnackBar.show(
            context,
            label: 'Facility registered successfully',
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
}
