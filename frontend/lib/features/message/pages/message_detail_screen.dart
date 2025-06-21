import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/common/services/message_hub_service.dart';
import 'package:frontend/common/services/presence_service_hub.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/message/services/message_service.dart';
import 'package:frontend/features/message/widgets/message_app_bar.dart';
import 'package:frontend/features/message/widgets/message_input_widget.dart';
import 'package:frontend/features/message/widgets/message_list_widget.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/providers/group_provider.dart';
import 'package:frontend/providers/online_users_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
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
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  // Add SignalR services
  final MessageHubService _messageHubService = MessageHubService();
  late String? userId;
  User? _otherUser;

  final ImagePicker _picker = ImagePicker();
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

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userId = ModalRoute.of(context)!.settings.arguments as String?;

    if (userId != null) {
      _initializeServices();
      _loadOtherUserInfo();

      // Khởi tạo OnlineUsersProvider nếu chưa được khởi tạo
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
    _messageController.dispose();
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
            // Thêm tin nhắn mới vào cuối danh sách
            _messages.add({
              'isSender': message.senderId == userProvider.user.id,
              'message': message.content,
              'time': message.messageSent.millisecondsSinceEpoch,
              'resources': [],
              'senderImageUrl': message.senderPhotoUrl,
            });
          });

          // Tự động cuộn xuống cuối danh sách khi có tin nhắn mới
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
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

            // If loading more, append messages (this path is for SignalR, not REST)
            if (_isLoadingMore) {
              // Convert new messages to map format và đảo ngược thứ tự
              final newMessages = paginatedMessages.items.reversed
                  .map((message) => {
                        'isSender': message.senderId == userProvider.user.id,
                        'message': message.content,
                        'time': message.messageSent.millisecondsSinceEpoch,
                        'resources': [],
                        'senderImageUrl': message.senderPhotoUrl,
                      })
                  .toList();

              // Add older messages to the beginning of the list
              _messages.insertAll(0, newMessages);
              _isLoadingMore = false;
            } else {
              // Otherwise replace all messages và đảo ngược thứ tự
              _messages.clear();
              for (var message in paginatedMessages.items.reversed) {
                _messages.add({
                  'isSender': message.senderId == userProvider.user.id,
                  'message': message.content,
                  'time': message.messageSent.millisecondsSinceEpoch,
                  'resources': [],
                  'senderImageUrl': message.senderPhotoUrl,
                });
              }

              // Cuộn xuống cuối danh sách sau khi tải tin nhắn ban đầu
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController
                      .jumpTo(_scrollController.position.maxScrollExtent);
                }
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

      // Nếu không nhận được tin nhắn sau khi kết nối, tắt loading
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

        // _showSnackBar(
        //   'Connection error: $e',
        //   action: SnackBarAction(
        //     label: 'Retry',
        //     onPressed: _initializeServices,
        //   ),
        // );
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
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          // Convert fetched MessageDto to the internal Map format and reverse order
          final newMessages = paginatedResponse.items.reversed
              .map((message) => {
                    'isSender': message.senderId == userProvider.user.id,
                    'message': message.content,
                    'time': message.messageSent.millisecondsSinceEpoch,
                    'resources':
                        [], // Assuming no resources from this API for simplicity
                    'senderImageUrl': message.senderPhotoUrl,
                  })
              .toList();

          // Add older messages to the beginning of the list
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

  // Removed _onScrollListener as it's now handled by MessageListWidget

  Future<void> _pickMedia() async {
    final ImagePicker _picker = ImagePicker();

    // Chọn ảnh (nhiều)
    final List<XFile>? images = await _picker.pickMultiImage();

    // Chọn video (chỉ 1 lần tại 1 thời điểm, bạn có thể lặp nếu cần nhiều video)
    final XFile? video = await _picker.pickVideo(
      source: ImageSource.gallery,
    );

    final List<File> pickedMedia = [];

    if (images != null) {
      pickedMedia.addAll(images.map((xfile) => File(xfile.path)));
    }

    if (video != null) {
      pickedMedia.add(File(video.path));
    }

    if (pickedMedia.isNotEmpty) {
      setState(() {
        _mediaFiles.addAll(pickedMedia);
      });
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _mediaFiles.removeAt(index);
    });
  }

  // Enhanced _sendMessage method với better retry logic
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty && _mediaFiles.isEmpty) {
      _showSnackBar('Message cannot be empty');
      return;
    }

    final content = _messageController.text.trim();
    final List<File> attachmentsToSend = List.from(_mediaFiles);

    // Clear UI immediately for better UX
    _messageController.clear();
    setState(() {
      _mediaFiles.clear();
      _isSendingMessage = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Validate file sizes before sending
      for (File file in attachmentsToSend) {
        final int fileSizeInBytes = await file.length();
        final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > 10) {
          // Reduced limit for base64 transmission
          throw Exception(
              'File ${file.path.split('/').last} is too large (${fileSizeInMB.toStringAsFixed(1)}MB). Maximum size is 10MB for direct upload.');
        }
      }

      print(
          '[MessageDetailScreen] Sending message with ${attachmentsToSend.length} attachments');

      // Send message directly with base64 attachments
      bool success = await _messageHubService.sendMessage(
        userId ?? "",
        content,
        attachments: attachmentsToSend,
      );

      if (success) {
        print('[MessageDetailScreen] Message sent successfully');
        if (attachmentsToSend.isNotEmpty) {
          _showSnackBar(
              'Message with ${attachmentsToSend.length} attachment(s) sent successfully');
        }
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      print('[MessageDetailScreen] Error sending message: $e');

      // Restore message content and attachments if sending failed
      _messageController.text = content;
      setState(() {
        _mediaFiles.addAll(attachmentsToSend);
      });

      if (mounted) {
        _showSnackBar(
          'Failed to send message: ${e.toString()}',
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              _sendMessage();
            },
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
                      onLoadMore: _loadMoreMessages,
                    ),
                  ),
                  MessageInputWidget(
                    messageController: _messageController,
                    mediaFiles: _mediaFiles,
                    isConnected: _isConnected,
                    isSendingMessage: _isSendingMessage,
                    onPickMedia: _pickMedia,
                    onRemoveMedia: _removeMedia,
                    onSendMessage: _sendMessage,
                  ),
                ],
              ),
            ),
    );
  }
}
