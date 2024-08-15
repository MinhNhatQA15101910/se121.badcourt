import 'package:flutter/material.dart';
import 'package:frontend/models/court.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/models/order.dart';
import 'package:frontend/models/order_period.dart';

class PlayerOrderProvider extends ChangeNotifier {
  Order _currentOrder = Order(
    id: '',
    userId: '',
    courtId: '',
    orderedAt: DateTime.now(),
    facilityName: '',
    address: '',
    imageUrl: '',
    price: 0,
    period: OrderPeriod(
      hourFrom: DateTime.now(),
      hourTo: DateTime.now().add(Duration(hours: 1)),
      userId: '',
    ),
  );

  Order get currentOrder => _currentOrder;

  void setOrder(Order order) {
    _currentOrder = order;
    notifyListeners();
  }
}
