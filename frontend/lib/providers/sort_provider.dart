import 'package:flutter/material.dart';

enum Sort {
  location_asc('asc', 'location', 'Near your location'),
  registered_at_asc('asc', 'registeredAt', 'Oldest facilities'),
  registered_at_desc('desc', 'registeredAt', 'Newest facilities'),
  price_asc('asc', 'price', 'Ascending price order'),
  price_desc('desc', 'price', 'Descending price order');

  const Sort(this.order, this.sort, this.value);
  final String order;
  final String sort;
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
