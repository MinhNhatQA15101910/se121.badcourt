import 'package:flutter/material.dart';

class FilterProvider extends ChangeNotifier {
  double _minPrice = 0;
  double _maxPrice = double.infinity;
  String _province = '';
  bool _usingTag = false;
  int _tagIndex = -1;
  bool _firstFilter = true;

  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  String get province => _province;
  bool get usingTag => _usingTag;
  int get tagIndex => _tagIndex;
  bool get firstFilter => _firstFilter;

  void setMinPrice(double minPrice) {
    _minPrice = minPrice;
    notifyListeners();
  }

  void setMaxPrice(double maxPrice) {
    _maxPrice = maxPrice;
    notifyListeners();
  }

  void setProvince(String province) {
    _province = province;
    notifyListeners();
  }

  void setUsingTag(bool usingTag) {
    _usingTag = usingTag;
    notifyListeners();
  }

  void setTagIndex(int tagIndex) {
    _tagIndex = tagIndex;
    notifyListeners();
  }

  void setFirstFilter(bool firstFilter) {
    _firstFilter = firstFilter;
    notifyListeners();
  }

  void resetFilter() {
    _minPrice = 0;
    _maxPrice = double.infinity;
    _province = '';
    _usingTag = false;
    _tagIndex = -1;
    _firstFilter = true;
  }
}
