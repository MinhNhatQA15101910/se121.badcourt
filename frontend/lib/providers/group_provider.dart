import 'package:flutter/material.dart';
import 'package:frontend/common/services/group_hub_service.dart';
import 'package:frontend/models/group_dto.dart';
import 'package:frontend/models/message_dto.dart';
import 'package:frontend/models/paginated_groups_dto.dart';

class GroupProvider extends ChangeNotifier {
  final GroupHubService _groupHubService = GroupHubService();

  List<GroupDto> _groups = [];
  Set<String> _unreadGroupIds = {};
  int _unreadMessageCount = 0;
  bool _isLoading = false;
  String? _error;
  bool _hasReceivedInitialGroups = false;

  // Thêm Set để track các message đã xử lý để tránh duplicate
  final Set<String> _processedMessageIds = {};

  // Thêm Map để theo dõi số tin nhắn chưa đọc theo từng user/group
  Map<String, int> _unreadCountByUser = {}; // userId -> unread count
  Map<String, int> _unreadCountByGroup = {}; // groupId -> unread count

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
  Map<String, int> get unreadCountByUser => Map.unmodifiable(_unreadCountByUser);
  Map<String, int> get unreadCountByGroup => Map.unmodifiable(_unreadCountByGroup);
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
    notifyListeners();
  }

  // Get unread count for specific user
  int getUnreadCountForUser(String userId) {
    return _unreadCountByUser[userId] ?? 0;
  }

  // Get unread count for specific group
  int getUnreadCountForGroup(String groupId) {
    return _unreadCountByGroup[groupId] ?? 0;
  }

  // Initialize GroupHub connection
  Future<void> initializeGroupHub(String accessToken) async {
    try {
      _setLoading(true);
      _setError(null);

      // Clear processed messages when reconnecting
      _processedMessageIds.clear();

      // Set up callbacks - Updated to handle paginated data
      _groupHubService.onReceiveGroups = _onReceivePaginatedGroups;
      
      // Chỉ sử dụng onNewMessageReceived để tránh duplicate processing
      // Bỏ onNewMessage callback để tránh xử lý trùng lặp
      _groupHubService.onNewMessage = null;

      // Chỉ sử dụng callback này cho NewMessageReceived từ GroupHub
      _groupHubService.onNewMessageReceived = (group) {
        // Handle khi nhận được tin nhắn mới từ người khác (qua GroupHub)
        _handleNewMessageReceivedFromOtherUser(group);
      };

      _groupHubService.onGroupUpdated = (group) {
        updateGroup(group);
      };

      _groupHubService.onReceiveNumberOfUnreadMessages = (count) {
        _unreadMessageCount = count;

        // Optional: cập nhật danh sách group chưa đọc
        _unreadGroupIds = _groups
            .where((g) =>
                g.lastMessage?.dateRead == null &&
                g.lastMessage?.senderId != _currentUserId)
            .map((g) => g.id)
            .toSet();

        print('[GroupProvider] Received unread count from SignalR: $count');
        notifyListeners();
      };

      // Start connection
      await _groupHubService.startConnection(accessToken);

      print('[GroupProvider] GroupHub initialized successfully');

      // Wait a bit for initial groups to be received automatically
      await Future.delayed(const Duration(seconds: 2));

      if (!_hasReceivedInitialGroups) {
        print(
            '[GroupProvider] No initial groups received yet, but connection is established');
      }
    } catch (e) {
      _setError('Failed to connect to GroupHub: $e');
      print('[GroupProvider] Error initializing GroupHub: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Unified method để xử lý tin nhắn mới với duplicate prevention
  void _processNewMessage(MessageDto message, {bool isFromOtherUser = false}) {
    // Kiểm tra xem message đã được xử lý chưa
    final messageKey = '${message.id}_${message.groupId}_${message.messageSent.millisecondsSinceEpoch}';
    
    if (_processedMessageIds.contains(messageKey)) {
      print('[GroupProvider] Message already processed, skipping: ${message.id}');
      return;
    }

    // Đánh dấu message đã được xử lý
    _processedMessageIds.add(messageKey);
    
    // Giới hạn số lượng processed message IDs để tránh memory leak
    if (_processedMessageIds.length > 1000) {
      final oldestIds = _processedMessageIds.take(500).toList();
      for (final id in oldestIds) {
        _processedMessageIds.remove(id);
      }
    }

    print('[GroupProvider] Processing new message: ${message.content} from ${message.senderUsername}');

    // Notify listeners about new message
    if (onNewMessage != null) {
      onNewMessage!(message);
    }

    // Update the group with new message and mark as unread
    _updateGroupWithNewMessage(message, isFromOtherUser: isFromOtherUser);

    // Notify all listeners to update UI
    notifyListeners();

    print('[GroupProvider] Updated unread count: $_unreadMessageCount');
  }

  // Handle new message received from other user (from NewMessageReceived function)
  void _handleNewMessageReceivedFromOtherUser(GroupDto updatedGroup) {
    print('[GroupProvider] New message received from other user in group: ${updatedGroup.id}');

    // Kiểm tra xem có lastMessage không
    if (updatedGroup.lastMessage == null) {
      print('[GroupProvider] No lastMessage in updated group, skipping');
      return;
    }

    final lastMessage = updatedGroup.lastMessage!;
    
    // Kiểm tra xem message đã được xử lý chưa
    final messageKey = '${lastMessage.id}_${lastMessage.groupId}_${lastMessage.messageSent.millisecondsSinceEpoch}';
    
    if (_processedMessageIds.contains(messageKey)) {
      print('[GroupProvider] Group update with already processed message, skipping: ${lastMessage.id}');
      return;
    }

    // Cập nhật hoặc thêm group mới
    final index = _groups.indexWhere((group) => group.id == updatedGroup.id);
    if (index != -1) {
      _groups[index] = updatedGroup;
    } else {
      _groups.add(updatedGroup);
      _totalCount++;
    }

    // Đánh dấu group có tin nhắn chưa đọc nếu tin nhắn không phải từ user hiện tại
    if (_currentUserId == null || lastMessage.senderId != _currentUserId) {
      
      // Đánh dấu message đã được xử lý
      _processedMessageIds.add(messageKey);
      
      // Giới hạn số lượng processed message IDs
      if (_processedMessageIds.length > 1000) {
        final oldestIds = _processedMessageIds.take(500).toList();
        for (final id in oldestIds) {
          _processedMessageIds.remove(id);
        }
      }
      
      _unreadGroupIds.add(updatedGroup.id);
      
      // Tăng _unreadMessageCount
      _unreadMessageCount++;
      
      // Cập nhật unread count theo user
      final senderId = lastMessage.senderId;
      _unreadCountByUser[senderId] = (_unreadCountByUser[senderId] ?? 0) + 1;
      
      // Cập nhật unread count theo group
      _unreadCountByGroup[updatedGroup.id] = (_unreadCountByGroup[updatedGroup.id] ?? 0) + 1;
      
      print('[GroupProvider] Group ${updatedGroup.id} marked as unread - message from ${lastMessage.senderUsername}');
      print('[GroupProvider] Unread count for user $senderId: ${_unreadCountByUser[senderId]}');
      print('[GroupProvider] Unread count for group ${updatedGroup.id}: ${_unreadCountByGroup[updatedGroup.id]}');
    } else {
      print('[GroupProvider] Message from current user, not marking as unread');
    }

    // Sắp xếp lại groups theo thời gian cập nhật
    _groups.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    // Thông báo cho UI cập nhật
    notifyListeners();

    print('[GroupProvider] Updated total unread count after new message: $_unreadMessageCount');
  }

  // Public method to handle new message (can be called from outside)
  void handleNewMessage(MessageDto message) {
    _processNewMessage(message, isFromOtherUser: false);
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
    print(
        '[GroupProvider] Received paginated groups: ${paginatedGroups.items.length} groups on page ${paginatedGroups.currentPage}');

    // Update pagination info
    _currentPage = paginatedGroups.currentPage;
    _totalPages = paginatedGroups.totalPages;
    _pageSize = paginatedGroups.pageSize;
    _totalCount = paginatedGroups.totalCount;

    // If loading more pages, append to existing groups
    if (_isLoadingMore) {
      // Add only new groups that don't already exist
      final existingIds = _groups.map((g) => g.id).toSet();
      final newGroups = paginatedGroups.items
          .where((g) => !existingIds.contains(g.id))
          .toList();
      _groups.addAll(newGroups);
      _isLoadingMore = false;
    } else {
      // Otherwise replace all groups
      _groups = paginatedGroups.items;
    }

    _hasReceivedInitialGroups = true;
    notifyListeners();

    print(
        '[GroupProvider] Updated with ${_groups.length} groups, total: $_totalCount, page: $_currentPage/$_totalPages');
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

    notifyListeners();
    print('[GroupProvider] Group ${updatedGroup.id} updated');
  }

  // Update group with new message - Updated với duplicate prevention
  void _updateGroupWithNewMessage(MessageDto message, {bool isFromOtherUser = false}) {
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
        
        // Tăng unread count
        _unreadMessageCount++;
        _unreadCountByUser[message.senderId] = (_unreadCountByUser[message.senderId] ?? 0) + 1;
        _unreadCountByGroup[message.groupId] = (_unreadCountByGroup[message.groupId] ?? 0) + 1;
        
        print(
            '[GroupProvider] Group ${message.groupId} marked as unread - message from ${message.senderUsername}');
        print('[GroupProvider] Unread count for user ${message.senderId}: ${_unreadCountByUser[message.senderId]}');
      } else {
        print(
            '[GroupProvider] Group ${message.groupId} not marked as unread - message from self');
      }

      print(
          '[GroupProvider] Updated group ${message.groupId} with new message');
    } else {
      // Group not found, create new group with this message
      print(
          '[GroupProvider] Group ${message.groupId} not found, creating placeholder');

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
        
        // Tăng unread count
        _unreadMessageCount++;
        _unreadCountByUser[message.senderId] = (_unreadCountByUser[message.senderId] ?? 0) + 1;
        _unreadCountByGroup[message.groupId] = (_unreadCountByGroup[message.groupId] ?? 0) + 1;
      }

      print(
          '[GroupProvider] Created new group ${message.groupId} with message');
    }
  }

  // Add unread group ID
  void addUnreadGroup(String groupId) {
    _unreadGroupIds.add(groupId);
    notifyListeners();
  }

  // Mark group as read - Cập nhật để trừ unread count
  void markGroupAsRead(String groupId) {
    // Remove from unread group IDs
    final wasUnread = _unreadGroupIds.contains(groupId);
    _unreadGroupIds.remove(groupId);

    // Trừ unread count nếu group trước đó có unread messages
    if (wasUnread) {
      final unreadCountForGroup = _unreadCountByGroup[groupId] ?? 0;
      
      // Trừ từ tổng unread count
      _unreadMessageCount = (_unreadMessageCount - unreadCountForGroup).clamp(0, double.infinity).toInt();
      
      // Tìm sender của last message để trừ unread count theo user
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
      
      if (group.id.isNotEmpty && group.lastMessage != null) {
        final senderId = group.lastMessage!.senderId;
        final currentUserUnreadCount = _unreadCountByUser[senderId] ?? 0;
        _unreadCountByUser[senderId] = (currentUserUnreadCount - unreadCountForGroup).clamp(0, double.infinity).toInt();
        
        // Xóa entry nếu count = 0
        if (_unreadCountByUser[senderId] == 0) {
          _unreadCountByUser.remove(senderId);
        }
        
        print('[GroupProvider] Reduced unread count for user $senderId: ${_unreadCountByUser[senderId] ?? 0}');
      }
      
      // Reset unread count cho group này
      _unreadCountByGroup.remove(groupId);
      
      print('[GroupProvider] Marked group $groupId as read, reduced total unread count to $_unreadMessageCount');
    }

    // Update the group to mark last message as read if it exists
    final index = _groups.indexWhere((group) => group.id == groupId);
    if (index != -1) {
      final currentGroup = _groups[index];
      if (currentGroup.lastMessage != null &&
          currentGroup.lastMessage!.dateRead == null) {
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

    notifyListeners();
    print('[GroupProvider] Group $groupId marked as read');
  }

  // Mark all messages as read
  void markAllMessagesAsRead() {
    _unreadGroupIds.clear();
    
    // Reset all unread counts
    _unreadMessageCount = 0;
    _unreadCountByUser.clear();
    _unreadCountByGroup.clear();

    // Update all groups to mark their last messages as read
    for (int i = 0; i < _groups.length; i++) {
      final currentGroup = _groups[i];
      if (currentGroup.lastMessage != null &&
          currentGroup.lastMessage!.dateRead == null) {
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

    notifyListeners();
    print('[GroupProvider] All messages marked as read, reset all unread counts');
  }

  // Mark messages as read for specific user
  void markMessagesAsReadForUser(String userId) {
    final unreadCountForUser = _unreadCountByUser[userId] ?? 0;
    
    if (unreadCountForUser > 0) {
      // Trừ từ tổng unread count
      _unreadMessageCount = (_unreadMessageCount - unreadCountForUser).clamp(0, double.infinity).toInt();
      
      // Xóa unread count cho user này
      _unreadCountByUser.remove(userId);
      
      // Tìm và mark các groups có tin nhắn từ user này là đã đọc
      final groupsToMarkRead = _groups.where((group) => 
        group.lastMessage != null && 
        group.lastMessage!.senderId == userId &&
        _unreadGroupIds.contains(group.id)
      ).toList();
      
      for (final group in groupsToMarkRead) {
        _unreadGroupIds.remove(group.id);
        _unreadCountByGroup.remove(group.id);
      }
      
      notifyListeners();
      print('[GroupProvider] Marked all messages from user $userId as read, reduced total unread count to $_unreadMessageCount');
    }
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
          (currentUserId == null ||
              group.lastMessage!.senderId != currentUserId);
    }

    return false;
  }

  // Helper methods

  // Method to calculate unread count with current user ID
  void calculateUnreadCountForUser(String currentUserId) {
    _currentUserId = currentUserId;
    notifyListeners();
  }

  // Force refresh unread count
  void refreshUnreadCount() {
    if (_currentUserId != null) {
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
    _unreadCountByUser.clear();
    _unreadCountByGroup.clear();
    _processedMessageIds.clear(); // Clear processed messages
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
      print(
          '[GroupProvider] Connected to GroupHub - waiting for automatic group updates');

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
    return _groups.where((group) => group.userIds.contains(userId)).toList();
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

  // Method để clear processed messages (có thể gọi định kỳ)
  void clearOldProcessedMessages() {
    if (_processedMessageIds.length > 500) {
      final oldestIds = _processedMessageIds.take(250).toList();
      for (final id in oldestIds) {
        _processedMessageIds.remove(id);
      }
      print('[GroupProvider] Cleared ${oldestIds.length} old processed message IDs');
    }
  }
}
