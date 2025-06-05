import 'package:flutter/material.dart';
import 'package:frontend/common/services/presence_service_hub.dart';

class OnlineUsersProvider extends ChangeNotifier {
  final Set<String> _onlineUsers = {};
  final PresenceService _presenceService = PresenceService();

  OnlineUsersProvider() {
    _setupListeners();
  }

  Set<String> get onlineUsers => _onlineUsers;

  bool isUserOnline(String userId) {
    return _onlineUsers.contains(userId);
  }

  void _setupListeners() {
    _presenceService.onUserOnline = (userId) {
      _onlineUsers.add(userId);
      notifyListeners();
    };

    _presenceService.onUserOffline = (userId) {
      _onlineUsers.remove(userId);
      notifyListeners();
    };

    _presenceService.onOnlineUsersReceived = (users) {
      _onlineUsers.clear();
      _onlineUsers.addAll(users);
      notifyListeners();
    };
  }

  Future<void> initialize(String accessToken) async {
    try {
      await _presenceService.startConnection(accessToken);
    } catch (e) {
      print('Error initializing OnlineUsersProvider: $e');
    }
  }

  void dispose() {
    _presenceService.stopConnection();
    super.dispose();
  }
}
