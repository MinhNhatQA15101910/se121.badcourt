import 'package:flutter/material.dart';
import 'package:frontend/features/manager/add_facility/models/detail_address.dart';

class AddressProvider extends ChangeNotifier {
  DetailAddress _address = DetailAddress(
    display: '',
    name: '',
    hsNum: '',
    street: '',
    address: '',
    cityId: 0,
    city: '',
    districtId: 0,
    district: '',
    wardId: 0,
    ward: '',
    lat: 0.0,
    lng: 0.0,
  );

  void setAddress(DetailAddress detailAddress) {
    _address = detailAddress;
    notifyListeners();
  }
}
