import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationProvider extends ChangeNotifier {
  double _latitude = 0;
  double _longitude = 0;

  double get latitude => _latitude;
  double get longitude => _longitude;

  void setLocation(LocationData location) {
    _latitude = location.latitude!;
    _longitude = location.longitude!;
    notifyListeners();
  }
}
