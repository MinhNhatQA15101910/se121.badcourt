import 'package:flutter/material.dart';
import 'package:frontend/models/court.dart';

class CheckoutProvider extends ChangeNotifier {
  Court _court = Court(
    id: '',
    facilityId: '',
    name: '',
    description: '',
    pricePerHour: 0,
    orderPeriods: [],
  );

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  // Getter và Setter cho Court
  Court get court => _court;

  set court(Court value) {
    _court = value;
    notifyListeners();
  }

  // Getter và Setter cho startDate
  DateTime get startDate => _startDate;

  set startDate(DateTime value) {
    _startDate = value;
    notifyListeners();
  }

  // Getter và Setter cho endDate
  DateTime get endDate => _endDate;

  set endDate(DateTime value) {
    _endDate = value;
    notifyListeners();
  }

  // Phương thức cập nhật thông tin của một Court
  void updateCourt(Court newCourt) {
    _court = newCourt;
    notifyListeners();
  }

  // Phương thức cập nhật thời gian đặt lịch
  void updateDates(DateTime newStartDate, DateTime newEndDate) {
    _startDate = newStartDate;
    _endDate = newEndDate;
    notifyListeners();
  }

  // Phương thức để clear tất cả các thông tin
  void clear() {
    _court = Court(
      id: '',
      facilityId: '',
      name: '',
      description: '',
      pricePerHour: 0,
      orderPeriods: [],
    );
    _startDate = DateTime.now();
    _endDate = DateTime.now();
    notifyListeners();
  }
}
