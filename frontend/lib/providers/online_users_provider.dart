import 'package:flutter/material.dart';
import 'package:frontend/common/services/presence_service_hub.dart';

class OnlineUsersProvider extends ChangeNotifier {
  final Set<String> _onlineUsers = {};
  final PresenceService _presenceService = PresenceService();
  bool _isInitialized = false;

  OnlineUsersProvider() {
    _setupListeners();
  }

  Set<String> get onlineUsers => _onlineUsers;
  bool get isInitialized => _isInitialized;

  bool isUserOnline(String userId) {
    final isOnline = _onlineUsers.contains(userId);
    print('[OnlineUsersProvider] Checking if user $userId is online: $isOnline');
    print('[OnlineUsersProvider] Current online users: $_onlineUsers');
    return isOnline;
  }

  void _setupListeners() {
    print('[OnlineUsersProvider] Setting up listeners');
    
    _presenceService.onUserOnline = (userId) {
      print('[OnlineUsersProvider] User came online: $userId');
      _onlineUsers.add(userId);
      notifyListeners();
    };

    _presenceService.onUserOffline = (userId) {
      print('[OnlineUsersProvider] User went offline: $userId');
      _onlineUsers.remove(userId);
      notifyListeners();
    };

    _presenceService.onOnlineUsersReceived = (users) {
      print('[OnlineUsersProvider] Received online users list: $users');
      _onlineUsers.clear();
      _onlineUsers.addAll(users);
      _isInitialized = true;
      notifyListeners();
      print('[OnlineUsersProvider] Updated online users set: $_onlineUsers');
    };
  }

  Future<void> initialize(String accessToken) async {
    try {
      print('[OnlineUsersProvider] Initializing with token');
      if (!_presenceService.isConnected) {
        await _presenceService.startConnection(accessToken);
        _isInitialized = true;
        print('[OnlineUsersProvider] PresenceService connected successfully');
      } else {
        print('[OnlineUsersProvider] PresenceService already connected');
        _isInitialized = true;
      }
    } catch (e) {
      print('[OnlineUsersProvider] Error initializing: $e');
    }
  }

  // Method to manually refresh online users
  void refreshOnlineUsers() {
    print('[OnlineUsersProvider] Refreshing online users');
    notifyListeners();
  }

  // Method to add user manually (for testing)
  void addOnlineUser(String userId) {
    print('[OnlineUsersProvider] Manually adding online user: $userId');
    _onlineUsers.add(userId);
    notifyListeners();
  }

  // Method to remove user manually (for testing)
  void removeOnlineUser(String userId) {
    print('[OnlineUsersProvider] Manually removing online user: $userId');
    _onlineUsers.remove(userId);
    notifyListeners();
  }

  @override
  void dispose() {
    print('[OnlineUsersProvider] Disposing');
    _presenceService.stopConnection();
    super.dispose();
  }
}
