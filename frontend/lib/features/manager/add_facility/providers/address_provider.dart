import 'package:flutter/material.dart';
import 'package:frontend/features/manager/add_facility/models/detail_address.dart';

class AddressProvider extends ChangeNotifier {
  DetailAddress? _address = null;

  DetailAddress? get address => _address;

  void setAddress(DetailAddress address) {
    _address = address;
    notifyListeners();
  }
}
