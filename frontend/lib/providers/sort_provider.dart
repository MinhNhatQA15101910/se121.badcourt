import 'package:flutter/material.dart';

enum Sort {
  location_asc('location', 'asc', 'Location: Near to far'),
  location_desc('location', 'desc', 'Location: Far to near'),
  registered_at_asc('registered_at', 'asc', 'Register date: Old to new'),
  registered_at_desc('registered_at', 'desc', 'Register date: New to old'),
  price_asc('price', 'asc', 'Price: Low to high'),
  price_desc('price', 'desc', 'Price: High to low');

  const Sort(this.sort, this.order, this.value);
  final String sort;
  final String order;
  final String value;
}

class SortProvider extends ChangeNotifier {
  Sort _sort = Sort.location_asc;

  Sort get sort => _sort;

  void setSort(Sort sort) {
    _sort = sort;
    notifyListeners();
  }

  void resetSort() {
    _sort = Sort.location_asc;
  }
}
