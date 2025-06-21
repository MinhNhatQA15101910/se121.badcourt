import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/message/pages/message_detail_screen.dart';
import 'package:frontend/features/message/services/message_service.dart';
import 'package:frontend/features/message/widgets/user_message_box.dart';
import 'package:frontend/models/group_dto.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/providers/group_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MessageScreen extends StatefulWidget {
  static const String routeName = '/messageScreen';

  const MessageScreen({Key? key}) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MessageService _messageService = MessageService();

  // Local state for hybrid approach
  List<GroupDto> _allGroups = [];
  List<GroupDto> filteredGroups = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMorePages = false;
  int _currentPage = 1;
  int _totalPages = 1;

  // Track previous groups count để detect changes
  int _previousGroupsCount = 0;
  List<String> _previousGroupIds = [];

  @override
  void initState() {
    super.initState();
    
    // Add scroll listener for infinite pagination
    _scrollController.addListener(_onScroll);
    
    _initializeScreen();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Scroll listener for infinite pagination
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreGroups();
    }
  }

  Future<void> _initializeScreen() async {
    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    // Set current user ID and calculate unread count
    if (userProvider.user.id.isNotEmpty) {
      groupProvider.setCurrentUserId(userProvider.user.id);
    }
    
    // Check if GroupProvider is connected and has groups
    if (groupProvider.isConnected) {
      if (groupProvider.groups.isNotEmpty) {
        // Already have groups from SignalR
        _syncWithProvider();
      } else {
        // Connected but no groups yet, wait for automatic updates
        print('[MessageScreen] Connected to GroupHub, waiting for groups...');
        await Future.delayed(const Duration(seconds: 2));
        _syncWithProvider();
      }
    } else {
      // Not connected yet, try to initialize GroupHub
      try {
        await groupProvider.initializeGroupHub(userProvider.user.token);
        print('[MessageScreen] Initialized GroupHub connection');
        
        // Set user ID after connection
        if (userProvider.user.id.isNotEmpty) {
          groupProvider.setCurrentUserId(userProvider.user.id);
        }
        
        // Wait for groups to load
        await Future.delayed(const Duration(seconds: 3));
        _syncWithProvider();
      } catch (e) {
        print('[MessageScreen] Error initializing GroupHub: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }

    // Check pagination info after initial load
    await _checkPaginationInfo();
  }

  // Sync local state with GroupProvider - Updated với logic reorder
  void _syncWithProvider() {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    
    setState(() {
      _allGroups = List.from(groupProvider.groups);
      _currentPage = 1; // SignalR provides first page
      _hasMorePages = true; // Will be updated by REST API
      _updateFilteredGroups();
      _isLoading = false;
    });

    // Update tracking variables
    _previousGroupsCount = _allGroups.length;
    _previousGroupIds = _allGroups.map((g) => g.id).toList();
  }

  // Handle new message received - Đẩy group lên đầu nếu đã tồn tại
  void _handleNewMessageReceived(GroupProvider groupProvider) {
    final newGroups = groupProvider.groups;
    
    // Check if there are any changes
    if (newGroups.length == _previousGroupsCount && 
        _listEquals(_previousGroupIds, newGroups.map((g) => g.id).toList())) {
      // No structural changes, but check for message updates
      _handleMessageUpdates(newGroups);
      return;
    }

    print('[MessageScreen] Detected group changes, syncing...');
    
    // Find new or updated groups
    final currentGroupIds = _allGroups.map((g) => g.id).toSet();
    final newGroupIds = newGroups.map((g) => g.id).toSet();
    
    // Check for new groups
    final addedGroupIds = newGroupIds.difference(currentGroupIds);
    
    // Check for updated groups (groups with new messages)
    final updatedGroups = <GroupDto>[];
    for (final newGroup in newGroups) {
      final existingGroup = _allGroups.firstWhere(
        (g) => g.id == newGroup.id,
        orElse: () => GroupDto(
          id: '',
          name: '',
          users: [],
          connections: [],
          updatedAt: DateTime.now(),
        ),
      );
      
      // Check if this group has a newer message
      if (existingGroup.id.isNotEmpty) {
        final existingMessageTime = existingGroup.lastMessage?.messageSent ?? existingGroup.updatedAt;
        final newMessageTime = newGroup.lastMessage?.messageSent ?? newGroup.updatedAt;
        
        if (newMessageTime.isAfter(existingMessageTime)) {
          updatedGroups.add(newGroup);
          print('[MessageScreen] Group ${newGroup.id} has new message, will move to top');
        }
      }
    }

    setState(() {
      // Handle new groups
      for (final groupId in addedGroupIds) {
        final newGroup = newGroups.firstWhere((g) => g.id == groupId);
        _allGroups.add(newGroup);
        print('[MessageScreen] Added new group: ${newGroup.id}');
      }

      // Handle updated groups - Move to top
      for (final updatedGroup in updatedGroups) {
        // Remove from current position
        _allGroups.removeWhere((g) => g.id == updatedGroup.id);
        // Add to top
        _allGroups.insert(0, updatedGroup);
        print('[MessageScreen] Moved group ${updatedGroup.id} to top');
      }

      // Update other groups that weren't moved
      for (int i = 0; i < _allGroups.length; i++) {
        final currentGroup = _allGroups[i];
        final updatedGroup = newGroups.firstWhere(
          (g) => g.id == currentGroup.id,
          orElse: () => currentGroup,
        );
        
        // Only update if it's not one of the groups we already moved
        if (!updatedGroups.any((g) => g.id == currentGroup.id)) {
          _allGroups[i] = updatedGroup;
        }
      }

      _updateFilteredGroups();
    });

    // Update tracking variables
    _previousGroupsCount = _allGroups.length;
    _previousGroupIds = _allGroups.map((g) => g.id).toList();
  }

  // Handle message updates without structural changes
  void _handleMessageUpdates(List<GroupDto> newGroups) {
    bool hasUpdates = false;
    
    for (int i = 0; i < _allGroups.length; i++) {
      final currentGroup = _allGroups[i];
      final newGroup = newGroups.firstWhere(
        (g) => g.id == currentGroup.id,
        orElse: () => currentGroup,
      );
      
      // Check if message content or timestamp changed
      final currentMessageTime = currentGroup.lastMessage?.messageSent ?? currentGroup.updatedAt;
      final newMessageTime = newGroup.lastMessage?.messageSent ?? newGroup.updatedAt;
      final currentMessageContent = currentGroup.lastMessage?.content ?? '';
      final newMessageContent = newGroup.lastMessage?.content ?? '';
      
      if (newMessageTime.isAfter(currentMessageTime) || currentMessageContent != newMessageContent) {
        // This group has a new message, move to top
        setState(() {
          _allGroups.removeAt(i);
          _allGroups.insert(0, newGroup);
          _updateFilteredGroups();
        });
        hasUpdates = true;
        print('[MessageScreen] Moved group ${newGroup.id} to top due to message update');
        break; // Only move one group at a time for smooth animation
      } else if (currentGroup != newGroup) {
        // Update group data without moving
        _allGroups[i] = newGroup;
        hasUpdates = true;
      }
    }
    
    if (hasUpdates) {
      setState(() {
        _updateFilteredGroups();
      });
    }
  }

  // Helper method to compare lists
  bool _listEquals<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  // Check pagination info by making a test call to page 2
  Future<void> _checkPaginationInfo() async {
    try {
      final testResponse = await _messageService.fetchGroup(
        context: context,
        pageNumber: 2, // Check if page 2 exists
      );
    
      if (mounted) {
        setState(() {
          _totalPages = testResponse.totalPages;
          _hasMorePages = _currentPage < _totalPages;
        });
        
        print('Group pagination info: totalPages=$_totalPages, hasMore=$_hasMorePages');
      }
    } catch (error) {
      print('Error checking group pagination info: $error');
      // If error, assume no more pages
      setState(() {
        _hasMorePages = false;
      });
    }
  }

  // Load more groups using REST API
  Future<void> _loadMoreGroups() async {
    if (_isLoadingMore) {
      return;
    }

    // For the first REST API call, we don't know total pages yet
    if (_totalPages > 1 && _currentPage >= _totalPages) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      print('Loading groups page $nextPage'); // Debug log
      
      final paginatedResponse = await _messageService.fetchGroup(
        context: context,
        pageNumber: nextPage,
      );

      if (mounted) {
        setState(() {
          // Update pagination info from REST API response
          _totalPages = paginatedResponse.totalPages;
          
          if (paginatedResponse.items.isNotEmpty) {
            // Add new groups to the list (only if they don't already exist)
            final existingIds = _allGroups.map((g) => g.id).toSet();
            final newGroups = paginatedResponse.items
                .where((g) => !existingIds.contains(g.id))
                .toList();
            
            _allGroups.addAll(newGroups);
            _currentPage = paginatedResponse.currentPage;
            _hasMorePages = _currentPage < _totalPages;
            
            print('Added ${newGroups.length} new groups from API');
          } else {
            _hasMorePages = false;
          }
          
          _updateFilteredGroups();
          
          print('Updated groups: currentPage=$_currentPage, totalPages=$_totalPages, hasMore=$_hasMorePages');
        });
        
        print('Loaded ${paginatedResponse.items.length} groups. Total: ${_allGroups.length}');
      }
    } catch (error) {
      if (mounted) {
        print('Error loading more groups: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load more conversations: $error'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  void _updateFilteredGroups() {
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isEmpty) {
      filteredGroups = List.from(_allGroups);
    } else {
      final currentUserId = Provider.of<UserProvider>(context, listen: false).user.id;
      filteredGroups = _allGroups.where((group) {
        // Find other user in the group
        final otherUser = group.users.firstWhere(
          (u) => u.id != currentUserId,
          orElse: () => User(
            id: 'unknown',
            username: 'Unknown User',
            email: 'unknown@example.com',
            roles: const ['Unknown'],
          ),
        );
        
        // Search by username or last message content
        return otherUser.username.toLowerCase().contains(searchQuery) ||
               (group.lastMessage?.content.toLowerCase().contains(searchQuery) ?? false);
      }).toList();
    }
    
    // Sort groups by last message time (most recent first) - nhưng giữ thứ tự đã được sắp xếp từ real-time updates
    if (searchQuery.isEmpty) {
      // Chỉ sort khi không search để giữ thứ tự real-time
      filteredGroups.sort((a, b) {
        final aTime = a.lastMessage?.messageSent ?? a.updatedAt;
        final bTime = b.lastMessage?.messageSent ?? b.updatedAt;
        return bTime.compareTo(aTime); // Descending order
      });
    }
  }

  Future<void> _refreshGroups() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _totalPages = 1;
      _hasMorePages = true;
      _allGroups.clear();
      _previousGroupsCount = 0;
      _previousGroupIds.clear();
    });

    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    
    try {
      // Request groups refresh via SignalR
      await groupProvider.refreshGroups();
      
      // Refresh unread count
      groupProvider.refreshUnreadCount();
      
      // Wait a bit for any updates
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Sync with provider
      _syncWithProvider();
      
      // Check pagination info
      await _checkPaginationInfo();
    } catch (e) {
      print('[MessageScreen] Error refreshing groups: $e');
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error refreshing conversations: $e'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _refreshGroups,
          ),
        ),
      );
    }
  }

  void _onGroupTapped(String groupId) {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    
    // Tìm user khác trong group để mark messages as read for that user
    final group = groupProvider.getGroupById(groupId);
    if (group != null) {
      final currentUserId = Provider.of<UserProvider>(context, listen: false).user.id;
      final otherUser = group.users.firstWhere(
        (u) => u.id != currentUserId,
        orElse: () => User(
          id: 'unknown',
          username: 'Unknown User',
          email: 'unknown@example.com',
          roles: const ['Unknown'],
        ),
      );
      
      // Mark messages as read for this specific user
      if (otherUser.id != 'unknown') {
        groupProvider.markMessagesAsReadForUser(otherUser.id);
      }
    }
    
    // Mark group as read via GroupProvider
    groupProvider.markGroupAsRead(groupId);
    
    // Also mark as read via SignalR using the public method
    groupProvider.markGroupAsReadViaSignalR(groupId);
  }

  // Kiểm tra xem group có tin nhắn chưa đọc không
  bool _hasUnreadMessage(GroupDto group) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    
    // Use the updated hasUnreadMessage method with current user ID
    return groupProvider.hasUnreadMessage(group.id, userProvider.user.id) || 
           _isRecentMessage(group.updatedAt);
  }

  // Kiểm tra tin nhắn có gần đây không (trong vòng 1 giờ)
  bool _isRecentMessage(DateTime messageTime) {
    final now = DateTime.now();
    final difference = now.difference(messageTime);
    return difference.inHours < 1;
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year(s) ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month(s) ago';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} week(s) ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalVariables.green,
        title: Row(
          children: [
            Text(
              'Message',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.none,
                color: GlobalVariables.white,
              ),
            ),
            const Spacer(),
            // Hiển thị trạng thái kết nối
            Consumer<GroupProvider>(
              builder: (context, groupProvider, _) {
                return Row(
                  children: [
                    // Hiển thị trạng thái kết nối GroupHub
                    Icon(
                      groupProvider.isConnected 
                          ? Icons.cloud_done 
                          : Icons.cloud_off,
                      color: groupProvider.isConnected 
                          ? Colors.white 
                          : Colors.red[300],
                      size: 20,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          // Add refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshGroups,
            tooltip: 'Refresh conversations',
          ),
          // Thêm button để xem unread count chi tiết
          Consumer<GroupProvider>(
            builder: (context, groupProvider, _) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.info_outline),
                onSelected: (value) {
                  if (value == 'show_details') {
                    _showUnreadDetails(groupProvider);
                  } else if (value == 'mark_all_read') {
                    groupProvider.markAllMessagesAsRead();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'show_details',
                    child: Text('Show unread details'),
                  ),
                  const PopupMenuItem(
                    value: 'mark_all_read',
                    child: Text('Mark all as read'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Container(
        color: GlobalVariables.defaultColor,
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Find recent user',
                  hintStyle: GoogleFonts.inter(
                    color: GlobalVariables.darkGrey,
                    fontSize: 16,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: GlobalVariables.lightGreen,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: GlobalVariables.lightGreen,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: GlobalVariables.darkGrey,
                  ),
                ),
                style: GoogleFonts.inter(
                  fontSize: 16,
                ),
                onChanged: (value) {
                  setState(() {
                    _updateFilteredGroups();
                  });
                },
              ),
            ),
            // Group list - Sử dụng Consumer để lắng nghe thay đổi real-time với logic reorder
            Consumer<GroupProvider>(
              builder: (context, groupProvider, _) {
                // Handle real-time updates với reorder logic
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (groupProvider.groups.isNotEmpty) {
                    _handleNewMessageReceived(groupProvider);
                  }
                });

                return _isLoading && _allGroups.isEmpty
                    ? const Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: GlobalVariables.green,
                              ),
                              SizedBox(height: 16),
                              Text('Loading conversations...'),
                            ],
                          ),
                        ),
                      )
                    : filteredGroups.isEmpty
                        ? Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    groupProvider.isConnected 
                                        ? 'No conversations yet'
                                        : 'Connecting to messages...',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    groupProvider.isConnected 
                                        ? 'Start a conversation with someone!'
                                        : 'Please wait while we connect',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  if (!groupProvider.isConnected)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 24.0),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          final userProvider = Provider.of<UserProvider>(
                                            context, 
                                            listen: false
                                          );
                                          await groupProvider.initializeGroupHub(
                                            userProvider.user.token
                                          );
                                          _refreshGroups();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: GlobalVariables.green,
                                        ),
                                        child: const Text('Connect'),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          )
                        : Expanded(
                            child: RefreshIndicator(
                              onRefresh: _refreshGroups,
                              color: GlobalVariables.green,
                              child: NotificationListener<ScrollNotification>(
                                onNotification: (ScrollNotification scrollInfo) {
                                  // Additional scroll detection for better infinite scroll
                                  if (scrollInfo is ScrollEndNotification &&
                                      scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100) {
                                    _loadMoreGroups();
                                  }
                                  return false;
                                },
                                child: CustomScrollView(
                                  controller: _scrollController,
                                  slivers: [
                                    // Pagination info
                                    if (_totalPages > 1 && _allGroups.isNotEmpty)
                                      SliverToBoxAdapter(
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 10,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.chat_outlined,
                                                size: 16,
                                                color: GlobalVariables.green,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Showing ${_allGroups.length} conversations',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: GlobalVariables.darkGrey,
                                                ),
                                              ),
                                              if (_hasMorePages) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: GlobalVariables.green.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    'Page $_currentPage of $_totalPages',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      color: GlobalVariables.green,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),

                                    // Groups list với AnimatedList để smooth reordering
                                    SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          final group = filteredGroups[index];

                                          // Lấy thông tin user hiện tại
                                          final currentUserId =
                                              Provider.of<UserProvider>(context, listen: false)
                                                  .user
                                                  .id;

                                          // Tìm user khác với user hiện tại
                                          final otherUser = group.users.firstWhere(
                                            (u) => u.id != currentUserId,
                                            orElse: () => User(
                                              id: 'default',
                                              username: 'Default User',
                                              email: 'default@example.com',
                                              photoUrl: '',
                                              roles: const ['Unknown'],
                                            ),
                                          );

                                          final hasUnread = _hasUnreadMessage(group);
                                          
                                          // Format last message time using updatedAt
                                          String formattedTime = _formatTimeAgo(group.updatedAt);

                                          return AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            key: ValueKey(group.id), // Key để maintain state khi reorder
                                            child: GestureDetector(
                                              onTap: () {
                                                _onGroupTapped(group.id);
                                                Navigator.of(context).pushNamed(
                                                  MessageDetailScreen.routeName,
                                                  arguments: otherUser.id,
                                                );
                                              },
                                              child: UserMessageBox(
                                                userName: otherUser.username,
                                                timestamp: formattedTime,
                                                userImageUrl: otherUser.photoUrl,
                                                role: otherUser.role,
                                                userId: otherUser.id,
                                                roomId: group.id,
                                                hasUnreadMessage: hasUnread,
                                              ),
                                            ),
                                          );
                                        },
                                        childCount: filteredGroups.length,
                                      ),
                                    ),

                                    // Loading more indicator
                                    if (_isLoadingMore)
                                      SliverToBoxAdapter(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 20),
                                          child: Center(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(25),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.1),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      valueColor: AlwaysStoppedAnimation<Color>(GlobalVariables.green),
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    'Loading more conversations...',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: GlobalVariables.darkGrey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                    // End of list indicator
                                    if (_allGroups.isNotEmpty && !_hasMorePages && !_isLoadingMore)
                                      SliverToBoxAdapter(
                                        child: Container(
                                          margin: const EdgeInsets.all(16),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 10,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.check_circle_outline,
                                                size: 16,
                                                color: GlobalVariables.green,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'All conversations loaded',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: GlobalVariables.darkGrey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                    // Bottom spacing
                                    const SliverToBoxAdapter(
                                      child: SizedBox(height: 20),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Hiển thị chi tiết unread count
  void _showUnreadDetails(GroupProvider groupProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unread Messages Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total unread: ${groupProvider.unreadMessageCount}'),
              const SizedBox(height: 16),
              const Text('By User:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...groupProvider.unreadCountByUser.entries.map((entry) {
                // Tìm username từ groups
                String username = 'Unknown';
                for (final group in groupProvider.groups) {
                  final user = group.users.firstWhere(
                    (u) => u.id == entry.key,
                    orElse: () => User(
                      id: '',
                      username: '',
                      email: '',
                      roles: const [],
                    ),
                  );
                  if (user.id.isNotEmpty) {
                    username = user.username;
                    break;
                  }
                }
                return Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text('$username: ${entry.value}'),
                );
              }).toList(),
              const SizedBox(height: 16),
              const Text('By Group:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...groupProvider.unreadCountByGroup.entries.map((entry) {
                // Tìm group name
                final group = groupProvider.getGroupById(entry.key);
                final groupName = group?.name ?? 'Unknown Group';
                return Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text('$groupName: ${entry.value}'),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
