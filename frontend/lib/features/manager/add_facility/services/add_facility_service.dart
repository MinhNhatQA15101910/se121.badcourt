import 'dart:convert';
import 'package:frontend/features/manager/add_facility/models/detail_address.dart';
import 'package:http/http.dart' as http;

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
}
