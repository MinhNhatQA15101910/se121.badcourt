import 'package:flutter/material.dart';
import 'package:frontend/common/services/presence_service_hub.dart';

class OnlineUsersProvider extends ChangeNotifier {
  final Set<String> _onlineUsers = {};
  final PresenceService _presenceService = PresenceService();
  bool _isInitialized = false;
  bool _isDisposed = false;

  OnlineUsersProvider() {
    print('[OnlineUsersProvider] Constructor called');
  }

  Set<String> get onlineUsers => _onlineUsers;
  bool get isInitialized => _isInitialized;

  bool isUserOnline(String userId) {
    final isOnline = _onlineUsers.contains(userId);
    // Remove excessive logging to prevent spam
    // print('[OnlineUsersProvider] Checking if user $userId is online: $isOnline');
    return isOnline;
  }

  Future<void> initialize(String accessToken) async {
    if (_isInitialized || _isDisposed) {
      print('[OnlineUsersProvider] Already initialized or disposed – skipping setup');
      return;
    }

    try {
      print('[OnlineUsersProvider] Initializing with token...');
      _setupListeners();
      _presenceService.testCallbacks();
      
      if (!_presenceService.isConnected) {
        await _presenceService.startConnection(accessToken);
        print('[OnlineUsersProvider] PresenceService connected successfully');
      } else {
        print('[OnlineUsersProvider] PresenceService already connected');
      }
      
      _isInitialized = true;
    } catch (e) {
      print('[OnlineUsersProvider] Error initializing: $e');
    }
  }

  void _setupListeners() {
    print('[OnlineUsersProvider] Setting up listeners');
    _presenceService.setCallbacks(
      onUserOnline: (userId) {
        if (_isDisposed) return;
        if (_onlineUsers.add(userId)) {
          print('[OnlineUsersProvider] User came online: $userId');
          _safeNotifyListeners();
        }
      },
      onUserOffline: (userId) {
        if (_isDisposed) return;
        if (_onlineUsers.remove(userId)) {
          print('[OnlineUsersProvider] User went offline: $userId');
          _safeNotifyListeners();
        }
      },
      onOnlineUsersReceived: (users) {
        if (_isDisposed) return;
        final incomingSet = users.toSet();
        if (!_setsAreEqual(_onlineUsers, incomingSet)) {
          print('[OnlineUsersProvider] Online users updated from server: $incomingSet');
          _onlineUsers
            ..clear()
            ..addAll(incomingSet);
          _safeNotifyListeners();
        }
      },
    );
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  bool _setsAreEqual(Set<String> a, Set<String> b) {
    return a.length == b.length && a.containsAll(b);
  }

  void refreshOnlineUsers() {
    if (_isDisposed) return;
    print('[OnlineUsersProvider] Refreshing online users manually');
    _safeNotifyListeners();
  }

  void addOnlineUser(String userId) {
    if (_isDisposed) return;
    if (_onlineUsers.add(userId)) {
      print('[OnlineUsersProvider] Manually added online user: $userId');
      _safeNotifyListeners();
    }
  }

  void removeOnlineUser(String userId) {
    if (_isDisposed) return;
    if (_onlineUsers.remove(userId)) {
      print('[OnlineUsersProvider] Manually removed online user: $userId');
      _safeNotifyListeners();
    }
  }

  @override
  void dispose() {
    print('[OnlineUsersProvider] Disposing...');
    _isDisposed = true;
    _presenceService.stopConnection();
    super.dispose();
  }
}