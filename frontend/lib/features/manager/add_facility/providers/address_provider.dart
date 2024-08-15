import 'package:flutter/material.dart';
import 'package:frontend/features/manager/add_facility/models/detail_address.dart';

class AddressProvider extends ChangeNotifier {
  DetailAddress _address = DetailAddress(
    city: '',
    district: '',
    ward: '',
    address: '',
    display: '',
    lng: 0.0,
    name: '',
    hsNum: '',
    street: '',
    cityId: 0,
    districtId: 0,
    wardId: 0,
    lat: 0,
  );

  DetailAddress get address => _address;

  void setAddress(DetailAddress address) {
    _address = address;
    notifyListeners();
  }
}
