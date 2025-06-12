import 'dart:async';

import 'package:signalr_netcore/signalr_client.dart';
import 'package:frontend/models/court.dart';
import 'package:frontend/constants/global_variables.dart';

class CourtHubService {
  static final CourtHubService _instance = CourtHubService._internal();
  factory CourtHubService() => _instance;
  CourtHubService._internal();

  final Map<String, HubConnection> _connections = {};
  final Map<String, Function(Court)> _courtUpdateCallbacks = {};
  final Map<String, Timer> _monitorTimers = {};

  // Connect to a specific court
  Future<void> connectToCourt(String accessToken, String courtId) async {
    try {
      // Don't create duplicate connections
      if (_connections.containsKey(courtId)) {
        print('[CourtHub] Already connected to court: $courtId');
        return;
      }

      print('[CourtHub] Connecting to court: $courtId');

      final connection = HubConnectionBuilder()
          .withUrl(
            '$signalrUri/hubs/court?courtId=$courtId',
            options: HttpConnectionOptions(
              accessTokenFactory: () async => accessToken,
              transport: HttpTransportType.WebSockets,
            ),
          )
          .withAutomaticReconnect()
          .build();

      // Set up event handlers
      connection.on('ReceiveCourt', (arguments) {
        if (arguments != null && arguments.isNotEmpty) {
          try {
            final courtData = arguments[0] as Map<String, dynamic>;
            final court = Court.fromMap(courtData);
            
            print('[CourtHub] Received court update: ${court.id}');
            
            // Notify callback if exists
            final callback = _courtUpdateCallbacks[courtId];
            if (callback != null) {
              callback(court);
            }
          } catch (e) {
            print('[CourtHub] Error parsing court data: $e');
          }
        }
      });

      // Start the connection
      await connection.start();
      _connections[courtId] = connection;
      
      print('✅ [CourtHub] Connected to court: $courtId');
      print('[CourtHub] Total active connections: ${_connections.length}');
      
      // Handle connection state changes manually if needed
      _monitorConnection(connection, courtId);
      
    } catch (e) {
      print('❌ [CourtHub] Error connecting to court $courtId: $e');
      rethrow;
    }
  }

  // Monitor connection state changes
  void _monitorConnection(HubConnection connection, String courtId) {
    // Cancel existing timer if any
    _monitorTimers[courtId]?.cancel();
    
    _monitorTimers[courtId] = Timer.periodic(Duration(seconds: 30), (timer) {
      if (!_connections.containsKey(courtId)) {
        print('[CourtHub] Monitor: Court $courtId no longer in connections, stopping timer');
        timer.cancel();
        _monitorTimers.remove(courtId);
        return;
      }
      
      final state = connection.state;
      print('[CourtHub] Monitor: Court $courtId state: $state');
      
      if (state == HubConnectionState.Disconnected) {
        print('[CourtHub] Connection to court $courtId is disconnected');
        _connections.remove(courtId);
        _courtUpdateCallbacks.remove(courtId);
        _monitorTimers.remove(courtId);
        timer.cancel();
      } else if (state == HubConnectionState.Reconnecting) {
        print('[CourtHub] Reconnecting to court $courtId...');
      } else if (state == HubConnectionState.Connected) {
        // Connection is healthy
        print('[CourtHub] Court $courtId connection is healthy');
      }
    });
  }

  // Disconnect from a specific court
  Future<void> disconnectFromCourt(String courtId) async {
    try {
      print('[CourtHub] Attempting to disconnect from court: $courtId');
      
      final connection = _connections[courtId];
      if (connection != null) {
        print('[CourtHub] Found connection for court: $courtId, stopping...');
        
        // Stop monitoring timer
        _monitorTimers[courtId]?.cancel();
        _monitorTimers.remove(courtId);
        
        // Stop the connection
        await connection.stop();
        
        // Remove from maps
        _connections.remove(courtId);
        _courtUpdateCallbacks.remove(courtId);
        
        print('✅ [CourtHub] Disconnected from court: $courtId');
        print('[CourtHub] Remaining active connections: ${_connections.length}');
      } else {
        print('[CourtHub] No connection found for court: $courtId');
      }
    } catch (e) {
      print('❌ [CourtHub] Error disconnecting from court $courtId: $e');
    }
  }

  // Disconnect from all courts
  Future<void> disconnectFromAllCourts() async {
    try {
      print('[CourtHub] Disconnecting from all courts...');
      print('[CourtHub] Current connections: ${_connections.keys.toList()}');
      
      // Stop all monitoring timers
      for (final timer in _monitorTimers.values) {
        timer.cancel();
      }
      _monitorTimers.clear();
      
      final courtIds = List<String>.from(_connections.keys);
      for (final courtId in courtIds) {
        await disconnectFromCourt(courtId);
      }
      
      print('✅ [CourtHub] Disconnected from all courts');
    } catch (e) {
      print('❌ [CourtHub] Error disconnecting from all courts: $e');
    }
  }

  // Set callback for court updates
  void setCourtUpdateCallback(String courtId, Function(Court) callback) {
    _courtUpdateCallbacks[courtId] = callback;
    print('[CourtHub] Set callback for court: $courtId');
  }

  // Remove callback for court updates
  void removeCourtUpdateCallback(String courtId) {
    _courtUpdateCallbacks.remove(courtId);
    print('[CourtHub] Removed callback for court: $courtId');
  }

  // Check if connected to a specific court
  bool isConnectedToCourt(String courtId) {
    final connection = _connections[courtId];
    final isConnected = connection != null && connection.state == HubConnectionState.Connected;
    print('[CourtHub] isConnectedToCourt($courtId): $isConnected');
    return isConnected;
  }

  // Get all connected court IDs
  List<String> get connectedCourts {
    final courts = _connections.keys.toList();
    print('[CourtHub] connectedCourts: $courts');
    return courts;
  }

  // Get connection state for a specific court
  HubConnectionState? getConnectionState(String courtId) {
    final state = _connections[courtId]?.state;
    print('[CourtHub] getConnectionState($courtId): $state');
    return state;
  }

  // Check if currently connecting to a court
  bool isConnectingToCourt(String courtId) {
    final connection = _connections[courtId];
    return connection != null && connection.state == HubConnectionState.Connecting;
  }

  // Check if currently reconnecting to a court
  bool isReconnectingToCourt(String courtId) {
    final connection = _connections[courtId];
    return connection != null && connection.state == HubConnectionState.Reconnecting;
  }

  // Debug method to get all connection info
  Map<String, String> getDebugInfo() {
    final info = <String, String>{};
    for (final entry in _connections.entries) {
      info[entry.key] = entry.value.state.toString();
    }
    return info;
  }
}
