import 'package:flutter/material.dart';
import 'package:frontend/models/court.dart';
import 'package:frontend/models/facility.dart';

class SelectedCourtProvider extends ChangeNotifier {
  Court? _selectedCourt;
  Facility? _selectedFacility;
  DateTime? _selectedDate;

  Court? get selectedCourt => _selectedCourt;
  Facility? get selectedFacility => _selectedFacility;
  DateTime? get selectedDate => _selectedDate;

  void setSelectedCourt(Court court, Facility facility, DateTime date) {
    _selectedCourt = court;
    _selectedFacility = facility;
    _selectedDate = date;
    notifyListeners();
  }

  void clearSelection() {
    _selectedCourt = null;
    _selectedFacility = null;
    _selectedDate = null;
    notifyListeners();
  }
}
