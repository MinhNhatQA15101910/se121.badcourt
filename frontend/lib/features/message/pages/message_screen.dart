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

  // Sync local state with GroupProvider
  void _syncWithProvider() {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    
    setState(() {
      _allGroups = List.from(groupProvider.groups);
      _currentPage = 1; // SignalR provides first page
      _hasMorePages = true; // Will be updated by REST API
      _updateFilteredGroups();
      _isLoading = false;
    });
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
            // Add new groups to the list
            _allGroups.addAll(paginatedResponse.items);
            _currentPage = paginatedResponse.currentPage;
            _hasMorePages = _currentPage < _totalPages;
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
    
    // Sort groups by updatedAt time (most recent first)
    filteredGroups.sort((a, b) {
      return b.updatedAt.compareTo(a.updatedAt); // Descending order
    });
  }

  Future<void> _refreshGroups() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _totalPages = 1;
      _hasMorePages = true;
      _allGroups.clear();
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
    // Mark group as read via GroupProvider
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
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
            // Hiển thị số tin nhắn chưa đọc và trạng thái kết nối
            Consumer<GroupProvider>(
              builder: (context, groupProvider, _) {
                final unreadCount = groupProvider.unreadMessageCount;
                return Row(
                  children: [
                    if (unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
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
            // Group list - Listen to GroupProvider for real-time updates
            Consumer<GroupProvider>(
              builder: (context, groupProvider, _) {
                // Listen for new groups from SignalR and sync
                if (groupProvider.groups.length != _allGroups.length) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    // Only sync if SignalR has more recent data
                    if (groupProvider.groups.isNotEmpty) {
                      _syncWithProvider();
                    }
                  });
                }

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

                                    // Groups list
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

                                          return GestureDetector(
                                            onTap: () {
                                              _onGroupTapped(group.id);
                                              Navigator.of(context).pushNamed(
                                                MessageDetailScreen.routeName,
                                                arguments: otherUser.id,
                                              );
                                            },
                                            child: UserMessageBox(
                                              userName: otherUser.username,
                                              lastMessage: group.lastMessage?.content ?? 
                                                         (group.lastMessageAttachment != null ? 'Attachment' : 'Start a conversation'),
                                              timestamp: formattedTime,
                                              userImageUrl: otherUser.photoUrl,
                                              role: otherUser.role,
                                              userId: otherUser.id,
                                              roomId: group.id,
                                              hasUnreadMessage: hasUnread,
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
}
