import 'package:flutter/material.dart';
import 'package:frontend/common/services/court_hub_service.dart';
import 'package:frontend/models/court.dart';
import 'package:frontend/models/time_period.dart';

class CourtHubProvider extends ChangeNotifier {
  final CourtHubService _courtHubService = CourtHubService();

  // Map of court IDs to Court objects
  final Map<String, Court> _courts = {};

  // Map of court IDs to connection status
  final Map<String, bool> _connectionStatus = {};

  // Map of court IDs to new order periods
  final Map<String, List<TimePeriod>> _newOrderPeriods = {};

  // Map of court IDs to court inactive periods
  final Map<String, List<TimePeriod>> _courtInactivePeriods = {};

  // NEW: Additional list for inactive courts (if needed for different logic)
  final Map<String, List<TimePeriod>> _inactiveCourt = {};

  // Get a court by ID
  Court? getCourt(String courtId) => _courts[courtId];

  // Get connection status for a court
  bool isConnected(String courtId) => _connectionStatus[courtId] ?? false;

  // Get all courts
  Map<String, Court> get courts => _courts;

  // Get new order periods for a court
  List<TimePeriod> getNewOrderPeriods(String courtId) =>
      _newOrderPeriods[courtId] ?? [];

  // Get court inactive periods for a court
  List<TimePeriod> getCourtInactivePeriods(String courtId, DateTime day) =>
      _courtInactivePeriods[courtId]?.where((period) {
        return period.hourFrom.month == day.month &&
            period.hourFrom.day == day.day;
      }).toList() ??
      [];

  // NEW: Get inactive court periods
  List<TimePeriod> getInactiveCourtPeriods(String courtId) =>
      _inactiveCourt[courtId] ?? [];

  // Connect to a court
  Future<void> connectToCourt(String accessToken, String courtId,
      {Court? initialCourt}) async {
    try {
      // If we have an initial court, add it to our map
      if (initialCourt != null) {
        _courts[courtId] = initialCourt;
        notifyListeners();
      }

      // Set up the callback before connecting
      _courtHubService.setCourtUpdateCallback(courtId, (court) {
        print('[CourtHubProvider] Updating court data: ${court.id}');
        _courts[courtId] = court;
        _connectionStatus[courtId] = true;

        if (court.inactivePeriods.isNotEmpty) {
          _courtInactivePeriods[courtId] = [...court.inactivePeriods];
          _inactiveCourt[courtId] = [...court.inactivePeriods];
          print(
              '[CourtHubProvider] Initialized inactivePeriods from court data: ${court.inactivePeriods.length}');
        }

        notifyListeners();
      });

      // Set up new order callback
      _courtHubService.setNewOrderCallback(courtId, (periodTime) {
        print(
            '[CourtHubProvider] New order period for court $courtId: ${periodTime.toString()}');
        // Add to the list of new order periods
        if (!_newOrderPeriods.containsKey(courtId)) {
          _newOrderPeriods[courtId] = [];
        }
        _newOrderPeriods[courtId]!.add(periodTime);
        notifyListeners();
      });

      // ENHANCED: Set up court inactive callback
      _courtHubService.setCourtInactiveCallback(courtId, (periodTime) {
        print(
            '[CourtHubProvider] Court inactive period for court $courtId: ${periodTime.toString()}');

        // Add to the list of inactive periods
        if (!_courtInactivePeriods.containsKey(courtId)) {
          _courtInactivePeriods[courtId] = [];
        }
        _courtInactivePeriods[courtId]!.add(periodTime);

        // NEW: Also add to _inactiveCourt if you need separate logic
        if (!_inactiveCourt.containsKey(courtId)) {
          _inactiveCourt[courtId] = [];
        }
        _inactiveCourt[courtId]!.add(periodTime);

        print(
            '[CourtHubProvider] Added inactive period. Total inactive periods: ${_courtInactivePeriods[courtId]!.length}');
        notifyListeners();
      });

      // Set up cancel order callback
      _courtHubService.setCancelOrderCallback(courtId, (periodTime) {
        print(
            '[CourtHubProvider] Cancel order period for court $courtId: ${periodTime.toString()}');
        // Remove the period from new order periods list
        if (_newOrderPeriods.containsKey(courtId)) {
          _newOrderPeriods[courtId]!.removeWhere((p) =>
              p.hourFrom == periodTime.hourFrom &&
              p.hourTo == periodTime.hourTo);

          print(
              '[CourtHubProvider] Removed cancelled period from new orders. Remaining periods: ${_newOrderPeriods[courtId]!.length}');
        }
        notifyListeners();
      });

      // Connect to the court
      await _courtHubService.connectToCourt(accessToken, courtId);

      // Update connection status
      _connectionStatus[courtId] = true;
      notifyListeners();
    } catch (e) {
      print('❌ [CourtHubProvider] Error connecting to court $courtId: $e');
      _connectionStatus[courtId] = false;
      notifyListeners();
      rethrow;
    }
  }

  // Disconnect from a court
  Future<void> disconnectFromCourt(String courtId) async {
    try {
      await _courtHubService.disconnectFromCourt(courtId);
      _connectionStatus[courtId] = false;
      // Keep court data but mark as disconnected
      // Clear the period lists when disconnecting
      _newOrderPeriods.remove(courtId);
      _courtInactivePeriods.remove(courtId);
      _inactiveCourt.remove(courtId); // NEW: Clear inactive court periods
      notifyListeners();
    } catch (e) {
      print('❌ [CourtHubProvider] Error disconnecting from court $courtId: $e');
    }
  }

  // Disconnect from all courts
  Future<void> disconnectFromAllCourts() async {
    try {
      await _courtHubService.disconnectFromAllCourts();
      _connectionStatus.clear();
      // Clear all period lists when disconnecting from all courts
      _newOrderPeriods.clear();
      _courtInactivePeriods.clear();
      _inactiveCourt.clear(); // NEW: Clear all inactive court periods
      notifyListeners();
    } catch (e) {
      print('❌ [CourtHubProvider] Error disconnecting from all courts: $e');
    }
  }

  // Clear new order periods for a specific court
  void clearNewOrderPeriods(String courtId) {
    _newOrderPeriods[courtId]?.clear();
    notifyListeners();
  }

  // Clear court inactive periods for a specific court
  void clearCourtInactivePeriods(String courtId) {
    _courtInactivePeriods[courtId]?.clear();
    _inactiveCourt[courtId]?.clear(); // NEW: Also clear inactive court periods
    notifyListeners();
  }

  // NEW: Clear inactive court periods for a specific court
  void clearInactiveCourtPeriods(String courtId) {
    _inactiveCourt[courtId]?.clear();
    notifyListeners();
  }

  // Remove a specific period from new orders
  void removeNewOrderPeriod(String courtId, TimePeriod period) {
    _newOrderPeriods[courtId]?.removeWhere(
        (p) => p.hourFrom == period.hourFrom && p.hourTo == period.hourTo);
    notifyListeners();
  }

  // Remove a specific period from inactive periods
  void removeCourtInactivePeriod(String courtId, TimePeriod period) {
    _courtInactivePeriods[courtId]?.removeWhere(
        (p) => p.hourFrom == period.hourFrom && p.hourTo == period.hourTo);
    _inactiveCourt[courtId]?.removeWhere(
        (p) => p.hourFrom == period.hourFrom && p.hourTo == period.hourTo);
    notifyListeners();
  }

  // NEW: Remove a specific period from inactive court periods
  void removeInactiveCourtPeriod(String courtId, TimePeriod period) {
    _inactiveCourt[courtId]?.removeWhere(
        (p) => p.hourFrom == period.hourFrom && p.hourTo == period.hourTo);
    notifyListeners();
  }

  // NEW: Get total count of all periods for a court
  int getTotalPeriodsCount(String courtId) {
    final newOrders = _newOrderPeriods[courtId]?.length ?? 0;
    final inactive = _courtInactivePeriods[courtId]?.length ?? 0;
    return newOrders + inactive;
  }

  // NEW: Get debug info for periods
  Map<String, dynamic> getPeriodsDebugInfo(String courtId) {
    return {
      'newOrderPeriods': _newOrderPeriods[courtId]?.length ?? 0,
      'courtInactivePeriods': _courtInactivePeriods[courtId]?.length ?? 0,
      'inactiveCourtPeriods': _inactiveCourt[courtId]?.length ?? 0,
    };
  }

  @override
  void dispose() {
    disconnectFromAllCourts();
    super.dispose();
  }
}
