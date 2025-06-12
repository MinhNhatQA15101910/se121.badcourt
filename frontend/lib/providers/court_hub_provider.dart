import 'package:flutter/material.dart';
import 'package:frontend/common/services/court_hub_service.dart';
import 'package:frontend/models/court.dart';

class CourtHubProvider extends ChangeNotifier {
  final CourtHubService _courtHubService = CourtHubService();
  
  // Map of court IDs to Court objects
  final Map<String, Court> _courts = {};
  
  // Map of court IDs to connection status
  final Map<String, bool> _connectionStatus = {};
  
  // Get a court by ID
  Court? getCourt(String courtId) => _courts[courtId];
  
  // Get connection status for a court
  bool isConnected(String courtId) => _connectionStatus[courtId] ?? false;
  
  // Get all courts
  Map<String, Court> get courts => _courts;
  
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
      notifyListeners();
    } catch (e) {
      print('❌ [CourtHubProvider] Error disconnecting from all courts: $e');
    }
  }
  
  @override
  void dispose() {
    disconnectFromAllCourts();
    super.dispose();
  }
}
