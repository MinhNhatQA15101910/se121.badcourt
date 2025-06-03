import 'package:flutter/material.dart';
import 'package:frontend/common/services/group_hub_service.dart';
import 'package:frontend/models/group_dto.dart';

class GroupProvider extends ChangeNotifier {
  final GroupHubService _groupHubService = GroupHubService();
  
  List<GroupDto> _groups = [];
  Set<String> _unreadGroupIds = {};
  int _unreadMessageCount = 0;
  bool _isLoading = false;
  String? _error;
  bool _hasReceivedInitialGroups = false;

  // Callback for new messages
  Function(MessageDto message)? onNewMessage;

  // Getters
  List<GroupDto> get groups => _groups;
  Set<String> get unreadGroupIds => _unreadGroupIds;
  int get unreadMessageCount => _unreadMessageCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _groupHubService.isConnected;
  bool get hasReceivedInitialGroups => _hasReceivedInitialGroups;
  
  // Add getter for GroupHubService
  GroupHubService get groupHubService => _groupHubService;

  // Initialize GroupHub connection
  Future<void> initializeGroupHub(String accessToken) async {
    try {
      _setLoading(true);
      _setError(null);

      // Set up callbacks
      _groupHubService.onReceiveGroups = _onReceiveGroups;
      _groupHubService.onNewMessage = (message) {
        // Notify listeners about new message
        if (onNewMessage != null) {
          onNewMessage!(message);
        }
        
        // Update unread count
        _unreadGroupIds.add(message.groupId);
        _calculateUnreadCount();
        notifyListeners();
      };

      _groupHubService.onGroupUpdated = (group) {
        updateGroup(group);
      };

      // Start connection
      await _groupHubService.startConnection(accessToken);
      
      print('[GroupProvider] GroupHub initialized successfully');
      
      // Wait a bit for initial groups to be received automatically
      await Future.delayed(const Duration(seconds: 2));
      
      if (!_hasReceivedInitialGroups) {
        print('[GroupProvider] No initial groups received yet, but connection is established');
      }
      
    } catch (e) {
      _setError('Failed to connect to GroupHub: $e');
      print('[GroupProvider] Error initializing GroupHub: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Disconnect GroupHub
  Future<void> disconnectGroupHub() async {
    try {
      await _groupHubService.stopConnection();
      _groups.clear();
      _unreadGroupIds.clear();
      _unreadMessageCount = 0;
      _hasReceivedInitialGroups = false;
      notifyListeners();
      print('[GroupProvider] GroupHub disconnected');
    } catch (e) {
      print('[GroupProvider] Error disconnecting GroupHub: $e');
    }
  }

  // Callback when receiving groups from SignalR
  void _onReceiveGroups(List<GroupDto> groups) {
    print('[GroupProvider] Received ${groups.length} groups');
    _groups = groups;
    _hasReceivedInitialGroups = true;
    _calculateUnreadCount();
    notifyListeners();
  }

  // Update groups from MessageScreen
  void updateGroups(List<GroupDto> groups) {
    _groups = groups;
    _hasReceivedInitialGroups = true;
    _calculateUnreadCount();
    notifyListeners();
  }

  // Update a specific group (when new message received)
  void updateGroup(GroupDto updatedGroup) {
    final index = _groups.indexWhere((group) => group.id == updatedGroup.id);
    if (index != -1) {
      _groups[index] = updatedGroup;
    } else {
      _groups.add(updatedGroup);
    }
    
    // Mark group as having unread message if it has new message
    if (updatedGroup.hasMessage) {
      _unreadGroupIds.add(updatedGroup.id);
    }
    
    _calculateUnreadCount();
    notifyListeners();
    print('[GroupProvider] Group ${updatedGroup.id} updated');
  }

  // Add unread group ID
  void addUnreadGroup(String groupId) {
    _unreadGroupIds.add(groupId);
    _calculateUnreadCount();
    notifyListeners();
  }

  // Calculate total unread message count
  void _calculateUnreadCount() {
    // Count from both hasMessage property and unread group IDs
    final hasMessageCount = _groups.where((group) => group.hasMessage).length;
    final unreadIdsCount = _unreadGroupIds.length;
    
    // Use the maximum to avoid double counting
    _unreadMessageCount = hasMessageCount > unreadIdsCount ? hasMessageCount : unreadIdsCount;
    print('[GroupProvider] Unread message count: $_unreadMessageCount');
  }

  // Mark group as read
  void markGroupAsRead(String groupId) {
    final index = _groups.indexWhere((group) => group.id == groupId);
    if (index != -1) {
      // Create updated group with hasMessage = false
      final updatedGroup = GroupDto(
        id: _groups[index].id,
        name: _groups[index].name,
        userIds: _groups[index].userIds,
        users: _groups[index].users,
        connections: _groups[index].connections,
        lastMessage: _groups[index].lastMessage,
        lastMessageAttachment: _groups[index].lastMessageAttachment,
        hasMessage: false, // Mark as read
        createdAt: _groups[index].createdAt,
        updatedAt: _groups[index].updatedAt,
      );
      
      _groups[index] = updatedGroup;
    }
    
    // Remove from unread group IDs
    _unreadGroupIds.remove(groupId);
    _calculateUnreadCount();
    notifyListeners();
    print('[GroupProvider] Group $groupId marked as read');
  }

  // Mark all messages as read
  void markAllMessagesAsRead() {
    _unreadGroupIds.clear();
    
    // Update all groups to mark hasMessage as false
    for (int i = 0; i < _groups.length; i++) {
      if (_groups[i].hasMessage) {
        _groups[i] = GroupDto(
          id: _groups[i].id,
          name: _groups[i].name,
          userIds: _groups[i].userIds,
          users: _groups[i].users,
          connections: _groups[i].connections,
          lastMessage: _groups[i].lastMessage,
          lastMessageAttachment: _groups[i].lastMessageAttachment,
          hasMessage: false,
          createdAt: _groups[i].createdAt,
          updatedAt: _groups[i].updatedAt,
        );
      }
    }
    
    _unreadMessageCount = 0;
    notifyListeners();
    print('[GroupProvider] All messages marked as read');
  }

  // Check if group has unread message
  bool hasUnreadMessage(String groupId) {
    final group = _groups.firstWhere(
      (g) => g.id == groupId,
      orElse: () => GroupDto(
        id: '',
        name: '',
        userIds: [],
        users: [],
        connections: [],
        hasMessage: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return _unreadGroupIds.contains(groupId) || group.hasMessage;
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Refresh groups manually - simplified to just wait for server updates
  Future<void> refreshGroups() async {
    if (_groupHubService.isConnected) {
      print('[GroupProvider] Connected to GroupHub - waiting for automatic group updates');
      // The server should automatically send groups when connected
      // No explicit request needed since the methods don't exist
    } else {
      _setError('Not connected to GroupHub');
    }
  }

  // Simplified method - just indicate we're waiting for automatic updates
  Future<void> requestGroups() async {
    if (_groupHubService.isConnected) {
      print('[GroupProvider] Waiting for automatic group updates from server');
      // Server should send groups automatically upon connection
    } else {
      _setError('Not connected to GroupHub');
    }
  }

  // Add method to mark group as read via SignalR
  Future<void> markGroupAsReadViaSignalR(String groupId) async {
    if (_groupHubService.isConnected) {
      try {
        await _groupHubService.markGroupAsRead(groupId);
        print('[GroupProvider] Marked group $groupId as read via SignalR');
      } catch (e) {
        print('[GroupProvider] Error marking group as read via SignalR: $e');
      }
    }
  }
}
