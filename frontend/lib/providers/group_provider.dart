import 'package:flutter/material.dart';
import 'package:frontend/common/services/group_hub_service.dart';
import 'package:frontend/models/group_dto.dart';
import 'package:frontend/models/message_dto.dart';

class GroupProvider extends ChangeNotifier {
  final GroupHubService _groupHubService = GroupHubService();
  
  List<GroupDto> _groups = [];
  Set<String> _unreadGroupIds = {};
  int _unreadMessageCount = 0;
  bool _isLoading = false;
  String? _error;
  bool _hasReceivedInitialGroups = false;
  
  // Pagination info
  int _currentPage = 1;
  int _totalPages = 1;
  int _pageSize = 20;
  int _totalCount = 0;
  bool _isLoadingMore = false;

  // Callback for new messages
  Function(MessageDto message)? onNewMessage;

  // Getters
  List<GroupDto> get groups => _groups;
  Set<String> get unreadGroupIds => _unreadGroupIds;
  int get unreadMessageCount => _unreadMessageCount;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get isConnected => _groupHubService.isConnected;
  bool get hasReceivedInitialGroups => _hasReceivedInitialGroups;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get pageSize => _pageSize;
  int get totalCount => _totalCount;
  bool get hasMorePages => _currentPage < _totalPages;
  
  // Add getter for GroupHubService
  GroupHubService get groupHubService => _groupHubService;

  // Initialize GroupHub connection
  Future<void> initializeGroupHub(String accessToken) async {
    try {
      _setLoading(true);
      _setError(null);

      // Set up callbacks - Updated to handle paginated data
      _groupHubService.onReceiveGroups = _onReceivePaginatedGroups;
      _groupHubService.onNewMessage = (message) {
        // Notify listeners about new message
        if (onNewMessage != null) {
          onNewMessage!(message);
        }
        
        // Update the group with new message and mark as unread
        _updateGroupWithNewMessage(message);
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
      _clearAllData();
      notifyListeners();
      print('[GroupProvider] GroupHub disconnected');
    } catch (e) {
      print('[GroupProvider] Error disconnecting GroupHub: $e');
    }
  }

  // Callback when receiving paginated groups from SignalR
  void _onReceivePaginatedGroups(PaginatedGroupsDto paginatedGroups) {
    print('[GroupProvider] Received paginated groups: ${paginatedGroups.items.length} groups on page ${paginatedGroups.currentPage}');
    
    // Update pagination info
    _currentPage = paginatedGroups.currentPage;
    _totalPages = paginatedGroups.totalPages;
    _pageSize = paginatedGroups.pageSize;
    _totalCount = paginatedGroups.totalCount;
    
    // If loading more pages, append to existing groups
    if (_isLoadingMore) {
      // Add only new groups that don't already exist
      final existingIds = _groups.map((g) => g.id).toSet();
      final newGroups = paginatedGroups.items.where((g) => !existingIds.contains(g.id)).toList();
      _groups.addAll(newGroups);
      _isLoadingMore = false;
    } else {
      // Otherwise replace all groups
      _groups = paginatedGroups.items;
    }
    
    _hasReceivedInitialGroups = true;
    _calculateUnreadCount();
    notifyListeners();
    
    print('[GroupProvider] Updated with ${_groups.length} groups, total: $_totalCount, page: $_currentPage/$_totalPages');
  }

  // Load next page of groups
  Future<void> loadNextPage() async {
    if (!isConnected || _currentPage >= _totalPages || _isLoadingMore) {
      return;
    }
    
    try {
      _isLoadingMore = true;
      notifyListeners();
      
      final nextPage = _currentPage + 1;
      print('[GroupProvider] Loading page $nextPage of $_totalPages');
      
      // Request next page from server
      await _groupHubService.requestPage(nextPage, _pageSize);
      
      // Wait for response via SignalR callback
      await Future.delayed(const Duration(seconds: 2));
      
    } catch (e) {
      print('[GroupProvider] Error loading next page: $e');
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Update groups from MessageScreen (maintain compatibility)
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
      _totalCount++;
    }
    
    // Mark group as having unread message if it has new message
    if (updatedGroup.hasMessage) {
      _unreadGroupIds.add(updatedGroup.id);
    }
    
    _calculateUnreadCount();
    notifyListeners();
    print('[GroupProvider] Group ${updatedGroup.id} updated');
  }

  // Update group with new message
  void _updateGroupWithNewMessage(MessageDto message) {
    final index = _groups.indexWhere((group) => group.id == message.groupId);
    if (index != -1) {
      // Create updated group with new last message
      final currentGroup = _groups[index];
      final updatedGroup = GroupDto(
        id: currentGroup.id,
        name: currentGroup.name,
        users: currentGroup.users,
        lastMessage: message,
        connections: currentGroup.connections,
        updatedAt: DateTime.now(),
      );
      
      _groups[index] = updatedGroup;
      
      // Mark as unread
      _unreadGroupIds.add(message.groupId);
      _calculateUnreadCount();
      
      print('[GroupProvider] Updated group ${message.groupId} with new message');
    } else {
      print('[GroupProvider] Group ${message.groupId} not found for new message');
    }
  }

  // Add unread group ID
  void addUnreadGroup(String groupId) {
    _unreadGroupIds.add(groupId);
    _calculateUnreadCount();
    notifyListeners();
  }

  // Calculate total unread message count using computed hasMessage property
  void _calculateUnreadCount() {
    // Count groups that have unread messages
    final hasMessageCount = _groups.where((group) => group.hasMessage).length;
    final unreadIdsCount = _unreadGroupIds.length;
    
    // Use the maximum to avoid double counting, but prioritize the computed property
    _unreadMessageCount = hasMessageCount > unreadIdsCount ? hasMessageCount : unreadIdsCount;
    
    // Also add any groups that are explicitly marked as unread
    for (final groupId in _unreadGroupIds) {
      final group = _groups.firstWhere(
        (g) => g.id == groupId,
        orElse: () => GroupDto(
          id: '',
          name: '',
          users: [],
          connections: [],
          updatedAt: DateTime.now(),
        ),
      );
      if (group.id.isNotEmpty && !group.hasMessage) {
        _unreadMessageCount++;
      }
    }
    
    print('[GroupProvider] Unread message count: $_unreadMessageCount');
  }

  // Mark group as read
  void markGroupAsRead(String groupId) {
    // Remove from unread group IDs
    _unreadGroupIds.remove(groupId);
    
    // Update the group to mark last message as read if it exists
    final index = _groups.indexWhere((group) => group.id == groupId);
    if (index != -1) {
      final currentGroup = _groups[index];
      if (currentGroup.lastMessage != null) {
        // Create new message with dateRead set
        final updatedMessage = MessageDto(
          id: currentGroup.lastMessage!.id,
          groupId: currentGroup.lastMessage!.groupId,
          senderId: currentGroup.lastMessage!.senderId,
          senderUsername: currentGroup.lastMessage!.senderUsername,
          senderImageUrl: currentGroup.lastMessage!.senderImageUrl,
          content: currentGroup.lastMessage!.content,
          dateRead: DateTime.now().toIso8601String(), // Mark as read
          messageSent: currentGroup.lastMessage!.messageSent,
        );
        
        // Create updated group with read message
        final updatedGroup = GroupDto(
          id: currentGroup.id,
          name: currentGroup.name,
          users: currentGroup.users,
          lastMessage: updatedMessage,
          connections: currentGroup.connections,
          updatedAt: currentGroup.updatedAt,
        );
        
        _groups[index] = updatedGroup;
      }
    }
    
    _calculateUnreadCount();
    notifyListeners();
    print('[GroupProvider] Group $groupId marked as read');
  }

  // Mark all messages as read
  void markAllMessagesAsRead() {
    _unreadGroupIds.clear();
    
    // Update all groups to mark their last messages as read
    for (int i = 0; i < _groups.length; i++) {
      final currentGroup = _groups[i];
      if (currentGroup.lastMessage != null && currentGroup.lastMessage!.dateRead == null) {
        // Create new message with dateRead set
        final updatedMessage = MessageDto(
          id: currentGroup.lastMessage!.id,
          groupId: currentGroup.lastMessage!.groupId,
          senderId: currentGroup.lastMessage!.senderId,
          senderUsername: currentGroup.lastMessage!.senderUsername,
          senderImageUrl: currentGroup.lastMessage!.senderImageUrl,
          content: currentGroup.lastMessage!.content,
          dateRead: DateTime.now().toIso8601String(), // Mark as read
          messageSent: currentGroup.lastMessage!.messageSent,
        );
        
        // Create updated group
        final updatedGroup = GroupDto(
          id: currentGroup.id,
          name: currentGroup.name,
          users: currentGroup.users,
          lastMessage: updatedMessage,
          connections: currentGroup.connections,
          updatedAt: currentGroup.updatedAt,
        );
        
        _groups[i] = updatedGroup;
      }
    }
    
    _unreadMessageCount = 0;
    notifyListeners();
    print('[GroupProvider] All messages marked as read');
  }

  // Check if group has unread message using computed property and unread IDs
  bool hasUnreadMessage(String groupId) {
    final group = _groups.firstWhere(
      (g) => g.id == groupId,
      orElse: () => GroupDto(
        id: '',
        name: '',
        users: [],
        connections: [],
        updatedAt: DateTime.now(),
      ),
    );
    
    // Check both the computed property and explicit unread tracking
    return _unreadGroupIds.contains(groupId) || 
           (group.id.isNotEmpty && group.hasMessage);
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

  void _clearAllData() {
    _groups.clear();
    _unreadGroupIds.clear();
    _unreadMessageCount = 0;
    _hasReceivedInitialGroups = false;
    _currentPage = 1;
    _totalPages = 1;
    _pageSize = 20;
    _totalCount = 0;
    _error = null;
    _isLoading = false;
    _isLoadingMore = false;
  }

  // Refresh groups manually - simplified to just wait for server updates
  Future<void> refreshGroups() async {
    if (_groupHubService.isConnected) {
      print('[GroupProvider] Connected to GroupHub - waiting for automatic group updates');
      
      // Request first page
      await _groupHubService.requestPage(1, _pageSize);
    } else {
      _setError('Not connected to GroupHub');
    }
  }

  // Simplified method - just indicate we're waiting for automatic updates
  Future<void> requestGroups() async {
    if (_groupHubService.isConnected) {
      print('[GroupProvider] Waiting for automatic group updates from server');
      
      // Request first page
      await _groupHubService.requestPage(1, _pageSize);
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

  // Get group by ID
  GroupDto? getGroupById(String groupId) {
    try {
      return _groups.firstWhere((group) => group.id == groupId);
    } catch (e) {
      return null;
    }
  }

  // Get groups for a specific user
  List<GroupDto> getGroupsForUser(String userId) {
    return _groups.where((group) => 
      group.userIds.contains(userId)
    ).toList();
  }

  // Sort groups by last message time
  void sortGroupsByLastMessage() {
    _groups.sort((a, b) {
      final aTime = a.lastMessage?.messageSent ?? a.updatedAt;
      final bTime = b.lastMessage?.messageSent ?? b.updatedAt;
      return bTime.compareTo(aTime); // Most recent first
    });
    notifyListeners();
  }
}
