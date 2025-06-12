import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/message/pages/message_detail_screen.dart';
import 'package:frontend/features/message/widgets/user_message_box.dart';
import 'package:frontend/models/group_dto.dart';
import 'package:frontend/models/user_dto.dart';
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

  List<GroupDto> groups = [];
  List<GroupDto> filteredGroups = [];
  bool _isLoading = true;
  bool _hasMorePages = false;
  int _currentPage = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
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
        // Already have groups
        setState(() {
          groups = groupProvider.groups;
          _currentPage = groupProvider.currentPage;
          _totalPages = groupProvider.totalPages;
          _hasMorePages = _currentPage < _totalPages;
          _updateFilteredGroups();
          _isLoading = false;
        });
      } else {
        // Connected but no groups yet, wait for automatic updates
        print('[MessageScreen] Connected to GroupHub, waiting for groups...');
        await Future.delayed(const Duration(seconds: 2));
        
        setState(() {
          groups = groupProvider.groups;
          _currentPage = groupProvider.currentPage;
          _totalPages = groupProvider.totalPages;
          _hasMorePages = _currentPage < _totalPages;
          _updateFilteredGroups();
          _isLoading = false;
        });
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
        
        setState(() {
          groups = groupProvider.groups;
          _currentPage = groupProvider.currentPage;
          _totalPages = groupProvider.totalPages;
          _hasMorePages = _currentPage < _totalPages;
          _updateFilteredGroups();
          _isLoading = false;
        });
      } catch (e) {
        print('[MessageScreen] Error initializing GroupHub: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateFilteredGroups() {
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isEmpty) {
      filteredGroups = List.from(groups);
    } else {
      final currentUserId = Provider.of<UserProvider>(context, listen: false).user.id;
      filteredGroups = groups.where((group) {
        // Find other user in the group
        final otherUser = group.users.firstWhere(
          (u) => u.id != currentUserId,
          orElse: () => UserDto(
            id: 'unknown',
            username: 'Unknown User',
            email: 'unknown@example.com',
            roles: const ['Unknown'], // Sử dụng roles thay vì role
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
    });

    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    
    try {
      // Request groups refresh
      await groupProvider.refreshGroups();
      
      // Refresh unread count
      groupProvider.refreshUnreadCount();
      
      // Wait a bit for any updates
      await Future.delayed(const Duration(milliseconds: 1000));
      
      setState(() {
        groups = groupProvider.groups;
        _currentPage = groupProvider.currentPage;
        _totalPages = groupProvider.totalPages;
        _hasMorePages = _currentPage < _totalPages;
        _updateFilteredGroups();
        _isLoading = false;
      });
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

  Future<void> _loadMoreGroups() async {
    if (!_hasMorePages) return;
    
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    if (!groupProvider.isConnected) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load next page
      await groupProvider.loadNextPage();
      
      setState(() {
        groups = groupProvider.groups;
        _currentPage = groupProvider.currentPage;
        _totalPages = groupProvider.totalPages;
        _hasMorePages = _currentPage < _totalPages;
        _updateFilteredGroups();
        _isLoading = false;
      });
    } catch (e) {
      print('[MessageScreen] Error loading more groups: $e');
      setState(() {
        _isLoading = false;
      });
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
                // Update local groups when GroupProvider changes
                if (groupProvider.groups != groups) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      groups = groupProvider.groups;
                      _currentPage = groupProvider.currentPage;
                      _totalPages = groupProvider.totalPages;
                      _hasMorePages = _currentPage < _totalPages;
                      _updateFilteredGroups();
                    });
                  });
                }

                return _isLoading && groups.isEmpty
                    ? const Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
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
                              child: NotificationListener<ScrollNotification>(
                                onNotification: (ScrollNotification scrollInfo) {
                                  if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
                                      _hasMorePages && !_isLoading) {
                                    _loadMoreGroups();
                                    return true;
                                  }
                                  return false;
                                },
                                child: ListView.builder(
                                  itemCount: filteredGroups.length + (_hasMorePages ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    // Show loading indicator at the bottom when loading more
                                    if (index == filteredGroups.length) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16.0),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }
                                    
                                    final group = filteredGroups[index];

                                    // Lấy thông tin user hiện tại
                                    final currentUserId =
                                        Provider.of<UserProvider>(context, listen: false)
                                            .user
                                            .id;

                                    // Tìm user khác với user hiện tại
                                    final otherUser = group.users.firstWhere(
                                      (u) => u.id != currentUserId,
                                      orElse: () => UserDto(
                                        id: 'default',
                                        username: 'Default User',
                                        email: 'default@example.com',
                                        photoUrl: '',
                                        roles: const ['Unknown'], // Sử dụng roles thay vì role
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
                                        userImageUrl: otherUser.photoUrl ?? '',
                                        role: otherUser.role, // Sử dụng getter role
                                        userId: otherUser.id,
                                        roomId: group.id,
                                        hasUnreadMessage: hasUnread,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
              },
            ),
            // Pagination info
            if (_totalPages > 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Page $_currentPage of $_totalPages',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
