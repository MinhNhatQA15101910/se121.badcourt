import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/message/screens/message_detail_screen.dart';
import 'package:frontend/features/message/services/message_service.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/providers/group_provider.dart';
import 'package:frontend/providers/online_users_provider.dart';
import 'package:provider/provider.dart';

class UserMessageBox extends StatefulWidget {
  final String userName;
  final String timestamp;
  final String userImageUrl;
  final String role;
  final String userId;
  final String? roomId;
  final bool hasUnreadMessage;

  const UserMessageBox({
    Key? key,
    required this.userName,
    required this.timestamp,
    required this.userImageUrl,
    required this.role,
    required this.userId,
    this.roomId,
    this.hasUnreadMessage = false,
  }) : super(key: key);

  @override
  State<UserMessageBox> createState() => _UserMessageBoxState();
}

class _UserMessageBoxState extends State<UserMessageBox> {
  final MessageService _messageService = MessageService();
  User? _user;
  bool _previousOnlineStatus = false;
  bool _isLoadingUser = false;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only check for online status changes after initial load
    if (_hasInitialized) {
      _checkOnlineStatusChange();
    }
  }

  Future<void> _initializeUser() async {
    await _loadUser();
    if (mounted) {
      setState(() {
        _hasInitialized = true;
      });
      // Set initial online status
      final onlineProvider = Provider.of<OnlineUsersProvider>(context, listen: false);
      _previousOnlineStatus = onlineProvider.isUserOnline(widget.userId);
    }
  }

  Future<void> _loadUser() async {
    if (_isLoadingUser) return;
    
    setState(() {
      _isLoadingUser = true;
    });

    try {
      final fetchedUser = await _messageService.fetchUserById(
        context: context,
        userId: widget.userId,
      );
      
      if (!mounted) return;
      
      setState(() {
        _user = fetchedUser;
        _isLoadingUser = false;
      });
      
      print('[UserMessageBox] User data loaded for ${widget.userId}: lastOnlineAt = ${fetchedUser?.lastOnlineAt}');
    } catch (e) {
      print('[UserMessageBox] Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }

  void _checkOnlineStatusChange() {
    final onlineProvider = Provider.of<OnlineUsersProvider>(context, listen: false);
    final currentOnlineStatus = onlineProvider.isUserOnline(widget.userId);
    
    if (_previousOnlineStatus != currentOnlineStatus) {
      print('[UserMessageBox] Online status changed for ${widget.userId}: $_previousOnlineStatus -> $currentOnlineStatus');
      
      // Update previous status immediately to prevent multiple calls
      _previousOnlineStatus = currentOnlineStatus;
      
      // Delay to allow server to update lastOnlineAt
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted && !_isLoadingUser) {
          _loadUser();
        }
      });
    }
  }

  bool _isUserOnline(DateTime? lastOnlineAt) {
    return lastOnlineAt == null;
  }

  String _getOfflineTimeText(DateTime? lastOnlineAt) {
    if (lastOnlineAt == null) {
      return 'Online';
    }
    
    final now = DateTime.now();
    final difference = now.difference(lastOnlineAt);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'Last seen ${years} year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'Last seen ${months} month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return 'Last seen ${weeks} week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return 'Last seen ${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return 'Last seen ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return 'Last seen ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Last seen just now';
    }
  }

  void _navigateToMessageScreen(BuildContext context, String userId) {
    if (widget.roomId != null) {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      groupProvider.markGroupAsRead(widget.roomId!);
      groupProvider.markGroupAsReadViaSignalR(widget.roomId!);
      groupProvider.markMessagesAsReadForUser(userId);
    }
    Navigator.of(context).pushNamed(
      MessageDetailScreen.routeName,
      arguments: userId,
    );
  }

  String _getStatusText(bool isOnline, String timestamp) {
    return isOnline ? 'Online' : timestamp;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<OnlineUsersProvider, GroupProvider>(
      builder: (context, onlineUsersProvider, groupProvider, child) {
        final bool isOnlineFromProvider = onlineUsersProvider.isUserOnline(widget.userId);
        
        final bool isOnline = _user != null 
            ? _isUserOnline(_user!.lastOnlineAt)
            : isOnlineFromProvider;

        final unreadCount = groupProvider.getUnreadCountForUser(widget.userId);
        final hasUnread = unreadCount > 0 || widget.hasUnreadMessage;

        String statusText;
        if (_user != null) {
          statusText = _getOfflineTimeText(_user!.lastOnlineAt);
        } else {
          statusText = _getStatusText(isOnline, widget.timestamp);
        }

        String lastMessage = 'Start a conversation';
        if (widget.roomId != null) {
          final group = groupProvider.getGroupById(widget.roomId!);
          if (group != null && group.lastMessage != null) {
            lastMessage = group.lastMessage!.content;
            if (group.lastMessage!.resources.isNotEmpty) {
              final resourceCount = group.lastMessage!.resources.length;
              if (lastMessage.isEmpty) {
                lastMessage = resourceCount == 1
                    ? '📎 Attachment'
                    : '📎 $resourceCount attachments';
              } else {
                lastMessage = '$lastMessage 📎';
              }
            }
            if (lastMessage.length > 50) {
              lastMessage = '${lastMessage.substring(0, 47)}...';
            }
          } else if (group?.lastMessageAttachment != null) {
            lastMessage = '📎 Attachment';
          }
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _navigateToMessageScreen(context, widget.userId),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: GlobalVariables.green.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Avatar with online status indicator
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: GlobalVariables.lightGreen,
                            backgroundImage: widget.userImageUrl.isNotEmpty
                                ? NetworkImage(widget.userImageUrl)
                                : null,
                            child: widget.userImageUrl.isEmpty
                                ? Text(
                                    widget.userName.isNotEmpty
                                        ? widget.userName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: isOnline
                                  ? GlobalVariables.green
                                  : const Color(0xFF9E9E9E),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isOnline
                                      ? GlobalVariables.green.withOpacity(0.4)
                                      : Colors.black.withOpacity(0.15),
                                  blurRadius: isOnline ? 8 : 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User name and role badge row
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.userName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: hasUnread
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: hasUnread
                                        ? GlobalVariables.green
                                        : const Color(0xFF1A1A1A),
                                    letterSpacing: -0.1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      GlobalVariables.green.withOpacity(0.1),
                                      GlobalVariables.lightGreen
                                          .withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        GlobalVariables.green.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  widget.role,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: GlobalVariables.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          // Online/Offline status
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isOnline
                                      ? GlobalVariables.green
                                      : const Color(0xFF9E9E9E),
                                  shape: BoxShape.circle,
                                  boxShadow: isOnline
                                      ? [
                                          BoxShadow(
                                            color: GlobalVariables.green.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        statusText,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isOnline ? FontWeight.w600 : FontWeight.w500,
                                          color: isOnline
                                              ? GlobalVariables.green
                                              : const Color(0xFF9E9E9E),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (_isLoadingUser)
                                      Container(
                                        margin: const EdgeInsets.only(left: 4),
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            GlobalVariables.green.withOpacity(0.6),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Last message with unread count
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  lastMessage,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: hasUnread
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: hasUnread
                                        ? GlobalVariables.green
                                        : const Color(0xFF616161),
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (unreadCount > 0)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.red,
                                        Colors.red.withOpacity(0.8)
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    unreadCount > 99
                                        ? '99+'
                                        : unreadCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}