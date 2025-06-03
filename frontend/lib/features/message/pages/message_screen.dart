import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/message/widgets/user_message_box.dart';
import 'package:frontend/models/group_dto.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    setState(() {
      _isLoading = true;
    });

    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    
    // Check if GroupProvider is connected and has groups
    if (groupProvider.isConnected) {
      if (groupProvider.groups.isNotEmpty) {
        // Already have groups
        setState(() {
          groups = groupProvider.groups;
          _updateFilteredGroups();
          _isLoading = false;
        });
      } else {
        // Connected but no groups yet, wait for automatic updates
        print('[MessageScreen] Connected to GroupHub, waiting for groups...');
        await Future.delayed(const Duration(seconds: 2));
        
        setState(() {
          groups = groupProvider.groups;
          _updateFilteredGroups();
          _isLoading = false;
        });
      }
    } else {
      // Not connected yet, wait for connection
      print('[MessageScreen] Waiting for GroupHub connection...');
      await Future.delayed(const Duration(seconds: 3));
      
      setState(() {
        groups = groupProvider.groups;
        _updateFilteredGroups();
        _isLoading = false;
      });
    }
  }

  void _updateFilteredGroups() {
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isEmpty) {
      filteredGroups = List.from(groups);
    } else {
      final currentUserId = Provider.of<UserProvider>(context, listen: false).user.id;
      filteredGroups = groups.where((group) {
        final user = group.users.firstWhere(
          (u) => u.id != currentUserId,
          orElse: () => UserDto(
            id: 'unknown',
            username: 'Unknown User',
            email: 'unknown@example.com',
            role: 'Unknown',
          ),
        );
        return user.username.toLowerCase().contains(searchQuery);
      }).toList();
    }
  }

  Future<void> _refreshGroups() async {
    setState(() {
      _isLoading = true;
    });

    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    
    // Just wait for automatic updates from the server
    await groupProvider.refreshGroups();
    
    // Wait a bit for any updates
    await Future.delayed(const Duration(milliseconds: 1000));
    
    setState(() {
      groups = groupProvider.groups;
      _updateFilteredGroups();
      _isLoading = false;
    });
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
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    return groupProvider.hasUnreadMessage(group.id) || 
           group.hasMessage ||
           (group.lastMessage != null && _isRecentMessage(group.lastMessage!.messageSent));
  }

  // Kiểm tra tin nhắn có gần đây không (trong vòng 1 giờ)
  bool _isRecentMessage(DateTime messageTime) {
    final now = DateTime.now();
    final difference = now.difference(messageTime);
    return difference.inHours < 1;
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
                      _updateFilteredGroups();
                    });
                  });
                }

                return _isLoading
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
                                ],
                              ),
                            ),
                          )
                        : Expanded(
                            child: RefreshIndicator(
                              onRefresh: _refreshGroups,
                              child: ListView.builder(
                                itemCount: filteredGroups.length,
                                itemBuilder: (context, index) {
                                  final group = filteredGroups[index];

                                  // Lấy thông tin user hiện tại
                                  final currentUserId =
                                      Provider.of<UserProvider>(context, listen: false)
                                          .user
                                          .id;

                                  // Tìm user khác với user hiện tại
                                  final user = group.users.firstWhere(
                                    (u) => u.id != currentUserId,
                                    orElse: () => UserDto(
                                      id: 'default',
                                      username: 'Default User',
                                      email: 'default@example.com',
                                      photoUrl: '',
                                      role: 'Unknown',
                                    ),
                                  );

                                  final hasUnread = _hasUnreadMessage(group);

                                  return GestureDetector(
                                    onTap: () => _onGroupTapped(group.id),
                                    child: UserMessageBox(
                                      userName: user.username,
                                      lastMessage: group.lastMessage?.content ?? 
                                                 (group.lastMessageAttachment != null ? 'Attachment' : ''),
                                      timestamp: _formatTimestamp(
                                          group.updatedAt.millisecondsSinceEpoch),
                                      userImageUrl: user.photoUrl ?? '',
                                      role: user.role,
                                      userId: user.id,
                                      roomId: group.id,
                                      hasUnreadMessage: hasUnread,
                                    ),
                                  );
                                },
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

  String _formatTimestamp(int? timestamp) {
    if (timestamp == null) return '';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
