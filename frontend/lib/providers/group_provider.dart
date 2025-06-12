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
  
  // Current user ID for filtering messages
  String? _currentUserId;

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

  // Set current user ID
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
    _calculateUnreadCount(_currentUserId);
    notifyListeners();
  }

  // Initialize GroupHub connection
  Future<void> initializeGroupHub(String accessToken) async {
    try {
      _setLoading(true);
      _setError(null);

      // Set up callbacks - Updated to handle paginated data
      _groupHubService.onReceiveGroups = _onReceivePaginatedGroups;
      _groupHubService.onNewMessage = (message) {
        // Handle new message received
        _handleNewMessageReceived(message);
      };

      // Thêm callback mới cho NewMessageReceived từ MessageHub
      _groupHubService.onNewMessageReceived = (group) {
        // Handle khi nhận được tin nhắn mới từ người khác (qua GroupHub)
        _handleNewMessageReceivedFromOtherUser(group);
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

  // Handle new message received (from NewMessageReceived function)
  void _handleNewMessageReceived(MessageDto message) {
    print('[GroupProvider] New message received: ${message.content} from ${message.senderUsername}');
    
    // Notify listeners about new message
    if (onNewMessage != null) {
      onNewMessage!(message);
    }
    
    // Update the group with new message and mark as unread
    _updateGroupWithNewMessage(message);
    
    // Recalculate unread count immediately
    if (_currentUserId != null) {
      _calculateUnreadCount(_currentUserId);
    }
    
    // Notify all listeners to update UI
    notifyListeners();
    
    print('[GroupProvider] Updated unread count: $_unreadMessageCount');
  }

  // Handle new message received from other user (from NewMessageReceived function)
  void _handleNewMessageReceivedFromOtherUser(GroupDto updatedGroup) {
    print('[GroupProvider] New message received from other user in group: ${updatedGroup.id}');
    
    // Cập nhật hoặc thêm group mới
    final index = _groups.indexWhere((group) => group.id == updatedGroup.id);
    if (index != -1) {
      _groups[index] = updatedGroup;
    } else {
      _groups.add(updatedGroup);
      _totalCount++;
    }
    
    // Đánh dấu group có tin nhắn chưa đọc nếu tin nhắn không phải từ user hiện tại
    if (updatedGroup.lastMessage != null && 
        (_currentUserId == null || updatedGroup.lastMessage!.senderId != _currentUserId)) {
      _unreadGroupIds.add(updatedGroup.id);
      print('[GroupProvider] Group ${updatedGroup.id} marked as unread - message from ${updatedGroup.lastMessage!.senderUsername}');
    }
    
    // Sắp xếp lại groups theo thời gian cập nhật
    _groups.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    // Tính lại số tin nhắn chưa đọc
    _calculateUnreadCount(_currentUserId);
    
    // Thông báo cho UI cập nhật
    notifyListeners();
    
    print('[GroupProvider] Updated unread count after new message: $_unreadMessageCount');
  }

  // Public method to handle new message (can be called from outside)
  void handleNewMessage(MessageDto message) {
    _handleNewMessageReceived(message);
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
    _calculateUnreadCount(_currentUserId);
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
    _calculateUnreadCount(_currentUserId);
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
    
    _calculateUnreadCount(_currentUserId);
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
      
      // Mark as unread only if message is from someone else
      if (_currentUserId == null || message.senderId != _currentUserId) {
        _unreadGroupIds.add(message.groupId);
        print('[GroupProvider] Group ${message.groupId} marked as unread - message from ${message.senderUsername}');
      } else {
        print('[GroupProvider] Group ${message.groupId} not marked as unread - message from self');
      }
      
      print('[GroupProvider] Updated group ${message.groupId} with new message');
    } else {
      // Group not found, create new group with this message
      print('[GroupProvider] Group ${message.groupId} not found, creating placeholder');
      
      // Create a minimal group for this message
      final newGroup = GroupDto(
        id: message.groupId,
        name: 'New Conversation',
        users: [], // Will be populated when full group data is received
        lastMessage: message,
        connections: [],
        updatedAt: DateTime.now(),
      );
      
      _groups.add(newGroup);
      _totalCount++;
      
      // Mark as unread if from someone else
      if (_currentUserId == null || message.senderId != _currentUserId) {
        _unreadGroupIds.add(message.groupId);
      }
      
      print('[GroupProvider] Created new group ${message.groupId} with message');
    }
  }

  // Add unread group ID
  void addUnreadGroup(String groupId) {
    _unreadGroupIds.add(groupId);
    _calculateUnreadCount(_currentUserId);
    notifyListeners();
  }

  // Calculate total unread message count using computed hasMessage property
  void _calculateUnreadCount([String? currentUserId]) {
    // Đếm số group có tin nhắn chưa đọc dựa vào dateRead của lastMessage
    // và chỉ đếm tin nhắn từ người khác (không phải từ user hiện tại)
    int unreadCount = 0;
    
    for (final group in _groups) {
      // Kiểm tra nếu group có lastMessage, dateRead là null, và senderId khác với user hiện tại
      if (group.lastMessage != null && 
          group.lastMessage!.dateRead == null && 
          (currentUserId == null || group.lastMessage!.senderId != currentUserId)) {
        unreadCount++;
      }
    }
    
    _unreadMessageCount = unreadCount;
    
    print('[GroupProvider] Calculated unread count: $_unreadMessageCount');
    print('[GroupProvider] Groups with unread messages from others:');
    for (final group in _groups) {
      if (group.lastMessage != null && 
          group.lastMessage!.dateRead == null && 
          (currentUserId == null || group.lastMessage!.senderId != currentUserId)) {
        print('  - Group ${group.id}: "${group.lastMessage!.content}" from ${group.lastMessage!.senderUsername}');
      }
    }
  }

  // Mark group as read
  void markGroupAsRead(String groupId) {
    // Remove from unread group IDs
    _unreadGroupIds.remove(groupId);
    
    // Update the group to mark last message as read if it exists
    final index = _groups.indexWhere((group) => group.id == groupId);
    if (index != -1) {
      final currentGroup = _groups[index];
      if (currentGroup.lastMessage != null && currentGroup.lastMessage!.dateRead == null) {
        // Create new message with dateRead set
        final updatedMessage = MessageDto(
          id: currentGroup.lastMessage!.id,
          groupId: currentGroup.lastMessage!.groupId,
          senderId: currentGroup.lastMessage!.senderId,
          senderUsername: currentGroup.lastMessage!.senderUsername,
          senderPhotoUrl: currentGroup.lastMessage!.senderPhotoUrl,
          content: currentGroup.lastMessage!.content,
          dateRead: DateTime.now(), // Mark as read - sử dụng DateTime thay vì String
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
    
    _calculateUnreadCount(_currentUserId);
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
          senderPhotoUrl: currentGroup.lastMessage!.senderPhotoUrl,
          content: currentGroup.lastMessage!.content,
          dateRead: DateTime.now(), // Mark as read
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
    
    _calculateUnreadCount(_currentUserId);
    notifyListeners();
    print('[GroupProvider] All messages marked as read');
  }

  // Check if group has unread message using computed property and unread IDs
  bool hasUnreadMessage(String groupId, [String? currentUserId]) {
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
    
    // Chỉ kiểm tra dateRead của lastMessage và senderId khác với user hiện tại
    if (group.id.isNotEmpty && group.lastMessage != null) {
      return group.lastMessage!.dateRead == null && 
             (currentUserId == null || group.lastMessage!.senderId != currentUserId);
    }
    
    return false;
  }

  // Helper methods

  // Method to calculate unread count with current user ID
  void calculateUnreadCountForUser(String currentUserId) {
    _currentUserId = currentUserId;
    _calculateUnreadCount(_currentUserId);
    notifyListeners();
  }

  // Force refresh unread count
  void refreshUnreadCount() {
    if (_currentUserId != null) {
      _calculateUnreadCount(_currentUserId);
      notifyListeners();
    }
  }

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
    _currentUserId = null;
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
