import 'dart:convert';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/error_handling.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/add_facility/models/detail_address.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AddFacilityService {
  Future<String?> fetchAddressRefId(String apiKey, String searchText) async {
    String apiUrl = 'https://maps.vietmap.vn/api/search/v3';
    String fullUrl = '$apiUrl?apikey=$apiKey&text=$searchText&layers=ADDRESS';

    try {
      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          return data[0]['ref_id'] as String?;
        }
      } else {
        print('HTTP Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }

    return null;
  }

  Future<DetailAddress?> fetchDetailAddress(String apiKey, String refId) async {
    String apiUrl = 'https://maps.vietmap.vn/api/place/v3';
    String fullUrl = '$apiUrl?apikey=$apiKey&refid=$refId';

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

  Future<void> registerFacility({
    required BuildContext context,
    required String facilityName,
    required double latitude,
    required double longitude,
    required String detailAddress,
    required String province,
    required List<File> facilityImageUrls,
    required String fullName,
    required String email,
    required String facebookUrl,
    required String phoneNumber,
    required String citizenId,
    required File citizenImageFront,
    required File citizenImageBack,
    required File bankCardFront,
    required File bankCardBack,
    required List<File> businessLicenseImageUrls,
    required String description,
    required String policy,
  }) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    try {
      final cloudinary = CloudinaryPublic('dauyd6npv', 'nkklif97');

      List<String> uploadedFacilityImageUrls = [];
      List<String> uploadedBusinessLicenseImageUrls = [];

      // Upload facility images
      for (File file in facilityImageUrls) {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            file.path,
            folder: 'facilities/$facilityName',
          ),
        );
        uploadedFacilityImageUrls.add(response.secureUrl);
      }

      // Upload business license images
      for (File file in businessLicenseImageUrls) {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            file.path,
            folder: 'business_license/$facilityName',
          ),
        );
        uploadedBusinessLicenseImageUrls.add(response.secureUrl);
      }

      // Upload citizen image front
      CloudinaryResponse citizenFrontResponse = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          citizenImageFront.path,
          folder: 'citizen_images/$facilityName',
        ),
      );
      String? citizenImageUrlFront = citizenFrontResponse.secureUrl;

      // Upload citizen image back
      CloudinaryResponse citizenBackResponse = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          citizenImageBack.path,
          folder: 'citizen_images/$facilityName',
        ),
      );
      String? citizenImageUrlBack = citizenBackResponse.secureUrl;

      // Upload bank card front
      CloudinaryResponse bankCardFrontResponse = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          bankCardFront.path,
          folder: 'bank_cards/$facilityName',
        ),
      );
      String? bankCardUrlFront = bankCardFrontResponse.secureUrl;

      // Upload bank card back
      CloudinaryResponse bankCardBackResponse = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          bankCardBack.path,
          folder: 'bank_cards/$facilityName',
        ),
      );
      String? bankCardUrlBack = bankCardBackResponse.secureUrl;

      // Prepare and send the POST request
      http.Response response = await http.post(
        Uri.parse('$uri/manager/register-facility'),
        body: jsonEncode(
          {
            "facility_name": facilityName,
            "lat": latitude,
            "lon": longitude,
            "detail_address": detailAddress,
            "province": province,
            "facility_image_urls": uploadedFacilityImageUrls,
            "full_name": fullName,
            "email": email,
            "facebook_url": facebookUrl,
            "phone_number": phoneNumber,
            "citizen_id": citizenId,
            "citizen_image_url_front": citizenImageUrlFront,
            "citizen_image_url_back": citizenImageUrlBack,
            "bank_card_url_front": bankCardUrlFront,
            "bank_card_url_back": bankCardUrlBack,
            "business_license_image_urls": uploadedBusinessLicenseImageUrls,
            "description": description,
            "policy": policy,
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
