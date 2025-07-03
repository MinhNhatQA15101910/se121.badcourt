import 'package:flutter/material.dart';
import 'package:frontend/models/court.dart';

class CheckoutProvider extends ChangeNotifier {
  Court _court = Court(
    id: '',
    courtName: 'Default Court Name',
    description: 'Default description for the court.',
    pricePerHour: 100000,
    state: 'Active',
    createdAt: DateTime.now().toUtc().toIso8601String(),
    orderPeriods: [], inactivePeriods: [],
  );

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  Court get court => _court;

  set court(Court value) {
    _court = value;
    notifyListeners();
  }

  DateTime get startDate => _startDate;

  set startDate(DateTime value) {
    _startDate = value;
    notifyListeners();
  }

  DateTime get endDate => _endDate;

  set endDate(DateTime value) {
    _endDate = value;
    notifyListeners();
  }

  void updateCourt(Court newCourt) {
    _court = newCourt;
    notifyListeners();
  }

  void updateDates(DateTime newStartDate, DateTime newEndDate) {
    _startDate = newStartDate;
    _endDate = newEndDate;
    notifyListeners();
  }

  void clear() {
    _court = Court(
      id: '',
      courtName: 'Default Court Name',
      description: 'Default description for the court.',
      pricePerHour: 100000,
      state: 'Active',
      createdAt: DateTime.now().toUtc().toIso8601String(),
      orderPeriods: [], inactivePeriods: [],
    );
    _startDate = DateTime.now();
    _endDate = DateTime.now();
    notifyListeners();
  }
}
