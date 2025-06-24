import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/common/services/message_hub_service.dart';
import 'package:frontend/common/services/presence_service_hub.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/message/services/message_service.dart';
import 'package:frontend/features/message/widgets/message_app_bar.dart';
import 'package:frontend/features/message/widgets/message_input_widget.dart';
import 'package:frontend/features/message/widgets/message_list_widget.dart';
import 'package:frontend/models/file_dto.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/models/message_dto.dart';
import 'package:frontend/providers/group_provider.dart';
import 'package:frontend/providers/online_users_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'dart:async';

class MessageDetailScreen extends StatefulWidget {
  static const String routeName = '/messageDetailScreen';

  const MessageDetailScreen({
    Key? key,
  }) : super(key: key);

  @override
  _MessageDetailScreenState createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  final List<MessageDto> _messages = [];

  // Add SignalR services
  final MessageHubService _messageHubService = MessageHubService();
  late String? userId;
  User? _otherUser;

  List<File> _mediaFiles = [];

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMorePages = false;
  bool _isSendingMessage = false;
  bool _isConnecting = false;
  bool _isConnected = false;

  // Pagination info
  int _currentPage = 1;
  int _totalPages = 1;

  String groupId = "";

  final ScrollController _scrollController = ScrollController();

  Timer? _connectionHealthTimer;
  late AnimationController _fadeController;

  // Keyboard handling
  double _keyboardHeight = 0;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Listen to focus changes
    _messageFocusNode.addListener(_onFocusChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userId = ModalRoute.of(context)!.settings.arguments as String?;

    if (userId != null) {
      _initializeServices();
      _loadOtherUserInfo();

      // Initialize OnlineUsersProvider if not already initialized
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final onlineUsersProvider =
          Provider.of<OnlineUsersProvider>(context, listen: false);
      if (!PresenceService().isConnected) {
        onlineUsersProvider.initialize(userProvider.user.token);
      }
    } else {
      print('userId is null');
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final newKeyboardHeight = bottomInset / WidgetsBinding.instance.window.devicePixelRatio;
    
    if (newKeyboardHeight != _keyboardHeight) {
      setState(() {
        _keyboardHeight = newKeyboardHeight;
        _isKeyboardVisible = newKeyboardHeight > 0;
      });

      // Auto scroll to bottom when keyboard appears
      if (_isKeyboardVisible && _scrollController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom(animate: true);
        });
      }
    }
  }

  void _onFocusChanged() {
    if (_messageFocusNode.hasFocus && _scrollController.hasClients) {
      // Delay scroll to allow keyboard animation
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _scrollController.hasClients) {
          _scrollToBottom(animate: true);
        }
      });
    }
  }

  void _scrollToBottom({bool animate = true}) {
    if (_scrollController.hasClients) {
      if (animate) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      }
    }
  }

  void _loadOtherUserInfo() {
    if (userId == null) return;

    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    // Find the group that contains this user
    for (var group in groupProvider.groups) {
      for (var user in group.users) {
        if (user.id == userId) {
          setState(() {
            _otherUser = user;
          });
          return;
        }
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _messageFocusNode.removeListener(_onFocusChanged);
    _messageFocusNode.dispose();
    _scrollController.dispose();
    _connectionHealthTimer?.cancel();
    _fadeController.dispose();

    // Disconnect from MessageHub for this user
    if (userId != null) {
      _messageHubService.stopConnection(userId!);
    }
    super.dispose();
  }

  // Enhanced _initializeServices method with paginated message loading
  Future<void> _initializeServices() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    setState(() {
      _isConnecting = true;
      _isLoading = true;
    });

    try {
      print('[MessageDetailScreen] Initializing services for user: $userId');

      // Set up message callbacks first
      _messageHubService.onNewMessage = (message) {
        print('Received new message: ${message.content}');
        if (mounted) {
          setState(() {
            // Add new message to the end of the list (newest at bottom)
            _messages.add(message);
          });

          // Auto-scroll to bottom when new message arrives
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom(animate: true);
          });
        }
      };

      // Update to handle paginated messages
      _messageHubService.onReceiveMessageThread = (paginatedMessages) {
        print(
            'Received paginated message thread: ${paginatedMessages.items.length} messages on page ${paginatedMessages.currentPage}/${paginatedMessages.totalPages}');

        if (mounted) {
          setState(() {
            // Update pagination info from SignalR initial load
            _currentPage = paginatedMessages.currentPage;
            _totalPages = paginatedMessages.totalPages;
            _hasMorePages = _currentPage < _totalPages;

            // Sort messages by time (oldest first for proper display order)
            final sortedMessages =
                List<MessageDto>.from(paginatedMessages.items);
            sortedMessages
                .sort((a, b) => a.messageSent.compareTo(b.messageSent));

            if (_isLoadingMore) {
              // When loading more (older messages), add them to the beginning
              final existingIds = _messages.map((m) => m.id).toSet();
              final newMessages = sortedMessages
                  .where((m) => !existingIds.contains(m.id))
                  .toList();

              // Add older messages to the beginning of the list
              _messages.insertAll(0, newMessages);
              _isLoadingMore = false;
            } else {
              // Initial load - replace all messages with sorted messages
              _messages.clear();
              _messages.addAll(sortedMessages);

              // Scroll to bottom after initial load
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom(animate: false);
              });
            }

            _isLoading = false;
            _fadeController.forward();
          });

          print(
              '[MessageDetailScreen] Updated UI with ${_messages.length} messages, page $_currentPage/$_totalPages');
        }
      };

      // Connect to MessageHub for this specific user
      await _messageHubService.startConnection(
        userProvider.user.token,
        userId ?? "",
      );

      // Wait a bit for connection to stabilize
      await Future.delayed(Duration(milliseconds: 2000));

      // Check connection state
      final isReady = _messageHubService.isConnectionReady(userId ?? "");
      print('[MessageDetailScreen] Connection ready: $isReady');

      setState(() {
        _isConnected = isReady;
        _isConnecting = false;
      });

      // If no messages received after connection, stop loading
      if (_messages.isEmpty) {
        await Future.delayed(Duration(milliseconds: 3000));
        if (mounted && _messages.isEmpty) {
          setState(() {
            _isLoading = false;
            _fadeController.forward();
          });
          print(
              '[MessageDetailScreen] No messages received, stopping loading indicator');
        }
      }

      if (!isReady) {
        if (mounted) {
          _showSnackBar(
            'Failed to connect to user. Please try again.',
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _initializeServices,
            ),
          );
        }
      }
    } catch (e) {
      print('[MessageDetailScreen] Error initializing services: $e');
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _isLoading = false;
          _isConnected = false;
          _fadeController.forward();
        });
      }
    }
  }

  // Updated to load more messages with pagination using MessageService
  Future<void> _loadMoreMessages() async {
    // Ensure we don't load more if already loading, no more pages, or initial loading
    if (_isLoading || _isLoadingMore || !_hasMorePages) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      print(
          '[MessageDetailScreen] Loading more messages via REST API, page $nextPage');

      final messageService = MessageService();
      final paginatedResponse = await messageService.fetchMessagesByOrderUserId(
        context: context,
        userId: userId ?? "",
        pageNumber: nextPage,
      );

      if (mounted) {
        setState(() {
          // Sort fetched messages by time (oldest first)
          final sortedMessages = List<MessageDto>.from(paginatedResponse.items);
          sortedMessages.sort((a, b) => a.messageSent.compareTo(b.messageSent));

          // Add older messages to the beginning of the list
          final existingIds = _messages.map((m) => m.id).toSet();
          final newMessages =
              sortedMessages.where((m) => !existingIds.contains(m.id)).toList();
          _messages.insertAll(0, newMessages);

          // Update pagination info from REST API response
          _currentPage = paginatedResponse.currentPage;
          _totalPages = paginatedResponse.totalPages;
          _hasMorePages = _currentPage < _totalPages;
          _isLoadingMore = false;
        });

        print(
            '[MessageDetailScreen] Loaded ${_messages.length} messages, now on page $_currentPage/$_totalPages');
      }
    } catch (e) {
      print(
          '[MessageDetailScreen] Error loading more messages via REST API: $e');

      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });

        _showSnackBar(
          'Error loading more messages: $e',
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _loadMoreMessages,
          ),
        );
      }
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _mediaFiles.removeAt(index);
    });
  }

  void _clearMediaFiles() {
    setState(() {
      _mediaFiles.clear();
    });
  }

  // Enhanced _sendMessage method - cải thiện UX
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty && _mediaFiles.isEmpty) {
      _showSnackBar('Message cannot be empty');
      return;
    }

    final content = _messageController.text.trim();
    final List<File> attachmentsToSend = List.from(_mediaFiles);

    // Tạo tin nhắn tạm thời để hiển thị ngay lập tức (optimistic UI)
    final tempMessage = MessageDto(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      senderId: Provider.of<UserProvider>(context, listen: false).user.id,
      groupId: '',
      content: content,
      messageSent: DateTime.now(),
      resources: _mediaFiles.map((file) => FileDto(
        url: file.path,
        isMain: false,
        fileType: file.path.toLowerCase().endsWith('.mp4') || 
                  file.path.toLowerCase().endsWith('.mov') ? 'video' : 'image',
      )).toList(),
    );

    // Thêm tin nhắn tạm thời vào danh sách ngay lập tức
    setState(() {
      _messages.add(tempMessage);
      _messageController.clear(); // Xóa text ngay lập tức
      _mediaFiles.clear(); // Xóa media files ngay lập tức
      _isSendingMessage = true;
    });

    // Scroll to bottom ngay lập tức
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(animate: true);
    });

    // Giữ focus trên input
    if (_messageFocusNode.canRequestFocus) {
      _messageFocusNode.requestFocus();
    }

    try {
      // Validate file sizes
      for (File file in attachmentsToSend) {
        final int fileSizeInBytes = await file.length();
        final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
        if (fileSizeInMB > 100) {
          throw Exception(
            'File ${file.path.split('/').last} is too large (${fileSizeInMB.toStringAsFixed(1)}MB). Max size: 10MB',
          );
        }
      }

      print('[MessageDetailScreen] Sending message via HTTP with ${attachmentsToSend.length} file(s)');

      // Send via REST API
      await MessageService().sendMessage(
        context: context,
        recipientId: userId ?? '',
        content: content,
        resources: attachmentsToSend,
      );

      print('[MessageDetailScreen] Message sent successfully');
      
      // Xóa tin nhắn tạm thời (tin nhắn thật sẽ được nhận từ SignalR)
      if (mounted) {
        setState(() {
          _messages.removeWhere((msg) => msg.id == tempMessage.id);
        });
      }
    } catch (e) {
      print('[MessageDetailScreen] Error sending message: $e');

      // Rollback: xóa tin nhắn tạm thời và restore nội dung
      if (mounted) {
        setState(() {
          _messages.removeWhere((msg) => msg.id == tempMessage.id);
          _messageController.text = content;
          _mediaFiles.addAll(attachmentsToSend);
        });

        _showSnackBar(
          'Failed to send message: ${e.toString()}',
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _sendMessage,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingMessage = false;
        });
      }
    }
  }

  void _showSnackBar(String message,
      {Duration? duration, SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 3),
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: MessageAppBar(
          otherUser: _otherUser,
          isConnected: _isConnected,
        ),
      ),
      body: _isConnecting
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      color: GlobalVariables.green,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Connecting to user...',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: GlobalVariables.darkGreen,
                    ),
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: _fadeController,
              child: Column(
                children: [
                  Expanded(
                    child: MessageListWidget(
                      messages: _messages,
                      isLoading: _isLoading,
                      isLoadingMore: _isLoadingMore,
                      hasMorePages: _hasMorePages,
                      currentPage: _currentPage,
                      totalPages: _totalPages,
                      scrollController: _scrollController,
                      currentUserId:
                          Provider.of<UserProvider>(context, listen: false)
                              .user
                              .id,
                      onLoadMore: _loadMoreMessages,
                    ),
                  ),
                  MessageInputWidget(
                    messageController: _messageController,
                    messageFocusNode: _messageFocusNode,
                    mediaFiles: _mediaFiles,
                    isConnected: _isConnected,
                    isSendingMessage: _isSendingMessage,
                    onPickMedia: (files) {
                      setState(() {
                        _mediaFiles.addAll(files);
                      });
                    },
                    onRemoveMedia: _removeMedia,
                    onSendMessage: _sendMessage,
                    onClearMedia: _clearMediaFiles,
                  ),
                ],
              ),
            ),
    );
  }
}