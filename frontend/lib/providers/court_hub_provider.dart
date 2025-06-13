import 'package:flutter/material.dart';
import 'package:frontend/common/services/court_hub_service.dart';
import 'package:frontend/models/court.dart';
import 'package:frontend/models/period_time.dart';

class CourtHubProvider extends ChangeNotifier {
  final CourtHubService _courtHubService = CourtHubService();
  
  // Map of court IDs to Court objects
  final Map<String, Court> _courts = {};
  
  // Map of court IDs to connection status
  final Map<String, bool> _connectionStatus = {};

  // Add these properties after the existing ones
  final Map<String, List<PeriodTime>> _newOrderPeriods = {};
  final Map<String, List<PeriodTime>> _courtInactivePeriods = {};
  
  // Get a court by ID
  Court? getCourt(String courtId) => _courts[courtId];
  
  // Get connection status for a court
  bool isConnected(String courtId) => _connectionStatus[courtId] ?? false;
  
  // Get all courts
  Map<String, Court> get courts => _courts;

  // Get new order periods for a court
  List<PeriodTime> getNewOrderPeriods(String courtId) => _newOrderPeriods[courtId] ?? [];

  // Get court inactive periods for a court
  List<PeriodTime> getCourtInactivePeriods(String courtId) => _courtInactivePeriods[courtId] ?? [];
  
  // Connect to a court
  Future<void> connectToCourt(String accessToken, String courtId, {Court? initialCourt}) async {
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
        notifyListeners();
      });

      // In the connectToCourt method, after setting up the court update callback, add:

      // Set up new order callback
      _courtHubService.setNewOrderCallback(courtId, (periodTime) {
        print('[CourtHubProvider] New order period for court $courtId: ${periodTime.toString()}');

        // Add to the list of new order periods
        if (!_newOrderPeriods.containsKey(courtId)) {
          _newOrderPeriods[courtId] = [];
        }
        _newOrderPeriods[courtId]!.add(periodTime);

        notifyListeners();
      });

      // Set up court inactive callback
      _courtHubService.setCourtInactiveCallback(courtId, (periodTime) {
        print('[CourtHubProvider] Court inactive period for court $courtId: ${periodTime.toString()}');

        // Add to the list of inactive periods
        if (!_courtInactivePeriods.containsKey(courtId)) {
          _courtInactivePeriods[courtId] = [];
        }
        _courtInactivePeriods[courtId]!.add(periodTime);

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

      // In the disconnectFromCourt method, after updating connection status, add:
      _newOrderPeriods.remove(courtId);
      _courtInactivePeriods.remove(courtId);

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

      // In the disconnectFromAllCourts method, after clearing connection status, add:
      _newOrderPeriods.clear();
      _courtInactivePeriods.clear();

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
    notifyListeners();
  }

  // Remove a specific period from new orders
  void removeNewOrderPeriod(String courtId, PeriodTime period) {
    _newOrderPeriods[courtId]?.removeWhere((p) => 
      p.hourFrom == period.hourFrom && p.hourTo == period.hourTo);
    notifyListeners();
  }

  // Remove a specific period from inactive periods
  void removeCourtInactivePeriod(String courtId, PeriodTime period) {
    _courtInactivePeriods[courtId]?.removeWhere((p) => 
      p.hourFrom == period.hourFrom && p.hourTo == period.hourTo);
    notifyListeners();
  }
  
  @override
  void dispose() {
    disconnectFromAllCourts();
    super.dispose();
  }
}
