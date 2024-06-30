import 'package:flutter/material.dart';

class FilterProvider extends ChangeNotifier {
  double _lowerPrice = 0;
  double _higherPrice = double.infinity;
  bool _usingTag = false;

  double get lowerPrice => _lowerPrice;
  double get higherPrice => _higherPrice;
  bool get usingTag => _usingTag;

  void setLowerPrice(double lowerPrice) {
    _lowerPrice = lowerPrice;
    notifyListeners();
  }

  void setHigherPrice(double higherPrice) {
    _higherPrice = higherPrice;
    notifyListeners();
  }

  void setUsingTag(bool usingTag) {
    _usingTag = usingTag;
    notifyListeners();
  }
}
