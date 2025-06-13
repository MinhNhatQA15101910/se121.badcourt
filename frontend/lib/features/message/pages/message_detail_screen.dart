import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/common/services/group_hub_service.dart';
import 'package:frontend/common/services/message_hub_service.dart';
import 'package:frontend/common/services/presence_service_hub.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/message/widgets/message_app_bar.dart';
import 'package:frontend/features/message/widgets/message_input_widget.dart';
import 'package:frontend/features/message/widgets/message_list_widget.dart';
import 'package:frontend/models/user_dto.dart';
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

class _MessageDetailScreenState extends State<MessageDetailScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  // Add SignalR services
  final GroupHubService _groupHubService = GroupHubService();
  final MessageHubService _messageHubService = MessageHubService();
  late String? userId;
  UserDto? _otherUser;

  final ImagePicker _picker = ImagePicker();
  List<File> _imageFiles = [];

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMorePages = false;
  bool _isSendingMessage = false;
  bool _isConnecting = false;
  bool _isConnected = false;

  // Pagination info
  int _currentPage = 1;
  int _totalPages = 1;
  int _pageSize = 20;
  int _totalCount = 0;

  String groupId = "";

  final ScrollController _scrollController = ScrollController();

  Timer? _connectionHealthTimer;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrollListener);
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
      final onlineUsersProvider = Provider.of<OnlineUsersProvider>(context, listen: false);
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
        print('Received paginated message thread: ${paginatedMessages.items.length} messages on page ${paginatedMessages.currentPage}/${paginatedMessages.totalPages}');
        
        if (mounted) {
          setState(() {
            // Update pagination info
            _currentPage = paginatedMessages.currentPage;
            _totalPages = paginatedMessages.totalPages;
            _pageSize = paginatedMessages.pageSize;
            _totalCount = paginatedMessages.totalCount;
            _hasMorePages = _currentPage < _totalPages;
            
            // If loading more, append messages
            if (_isLoadingMore) {
              // Convert new messages to map format và đảo ngược thứ tự
              final newMessages = paginatedMessages.items.reversed.map((message) => {
                'isSender': message.senderId == userProvider.user.id,
                'message': message.content,
                'time': message.messageSent.millisecondsSinceEpoch,
                'resources': [],
                'senderImageUrl': message.senderPhotoUrl,
              }).toList();
              
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
                  _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                }
              });
            }
            
            _isLoading = false;
            _fadeController.forward();
          });
          
          print('[MessageDetailScreen] Updated UI with ${_messages.length} messages, page $_currentPage/$_totalPages');
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
          print('[MessageDetailScreen] No messages received, stopping loading indicator');
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

  // Updated to load more messages with pagination
  Future<void> _loadMoreMessages() async {
    if (!_hasMorePages || _isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      final nextPage = _currentPage + 1;
      print('[MessageDetailScreen] Loading more messages, page $nextPage');
      
      // Request next page from server
      final success = await _messageHubService.requestMessagePage(
        userId ?? "", 
        nextPage, 
        _pageSize
      );
      
      if (!success) {
        setState(() {
          _isLoadingMore = false;
        });
        
        // _showSnackBar(
        //   'Failed to load more messages',
        //   action: SnackBarAction(
        //     label: 'Retry',
        //     onPressed: _loadMoreMessages,
        //   ),
        // );
      }
      
      // Wait for response via SignalR callback
      await Future.delayed(Duration(seconds: 2));
      
      if (mounted && _isLoadingMore) {
        setState(() {
          _isLoadingMore = false;
        });
      }
      
    } catch (e) {
      print('[MessageDetailScreen] Error loading more messages: $e');
      
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

  void _onScrollListener() {
    if (_isLoading || _isLoadingMore || !_hasMorePages) return;

    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreMessages();
    }
  }

  Future<void> _pickImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null) {
      setState(() {
        _imageFiles.addAll(
          selectedImages.map((xfile) => File(xfile.path)).toList(),
        );
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  // Enhanced _sendMessage method với better retry logic
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty && _imageFiles.isEmpty) {
      _showSnackBar('Message cannot be empty');
      return;
    }

    final content = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _imageFiles = [];
      _isSendingMessage = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // Thử gửi tin nhắn với retry logic
      bool success = false;
      int maxAttempts = 3;
      
      for (int attempt = 1; attempt <= maxAttempts; attempt++) {
        print('[MessageDetailScreen] Sending message attempt $attempt/$maxAttempts');
        
        // Kiểm tra và đảm bảo connection
        if (!_messageHubService.isConnectionReady(userId ?? "")) {
          print('[MessageDetailScreen] Connection not ready, attempting to reconnect...');
          
          try {
            await _messageHubService.startConnection(
              userProvider.user.token,
              userId ?? "",
            );
            
            // Đợi connection ổn định
            await Future.delayed(Duration(milliseconds: 2000));
            
            if (!_messageHubService.isConnectionReady(userId ?? "")) {
              if (attempt < maxAttempts) {
                print('[MessageDetailScreen] Connection still not ready, retrying...');
                continue;
              } else {
                throw Exception('Unable to establish stable connection');
              }
            }
          } catch (connectionError) {
            print('[MessageDetailScreen] Connection error on attempt $attempt: $connectionError');
            if (attempt < maxAttempts) {
              await Future.delayed(Duration(milliseconds: 1000 * attempt));
              continue;
            } else {
              throw Exception('Connection failed after $maxAttempts attempts: $connectionError');
            }
          }
        }
        
        // Hiển thị thông tin chi tiết trước khi gửi
        print('[MessageDetailScreen] Sending message to user: $userId');
        print('[MessageDetailScreen] Message content: $content');
        print('[MessageDetailScreen] Connection state: ${_messageHubService.getConnectionStateString(userId ?? "")}');

        // Thử gửi tin nhắn
        try {
          success = await _messageHubService.sendMessage(
            userId ?? "",
            content,
            maxRetries: 1, // Đã có retry ở level này rồi
          );
          
          if (success) {
            print('[MessageDetailScreen] Message sent successfully on attempt $attempt');
            break;
          } else {
            print('[MessageDetailScreen] Failed to send message on attempt $attempt');
            if (attempt < maxAttempts) {
              await Future.delayed(Duration(milliseconds: 1000 * attempt));
            }
          }
        } catch (sendError) {
          print('[MessageDetailScreen] Send error on attempt $attempt: $sendError');
          if (attempt < maxAttempts) {
            await Future.delayed(Duration(milliseconds: 1000 * attempt));
          } else {
            throw sendError;
          }
        }
      }
      
      if (!success) {
        throw Exception('Failed to send message after $maxAttempts attempts');
      }
      
    } catch (e) {
      print('[MessageDetailScreen] Error sending message: $e');
      
      // Restore message content if sending failed
      _messageController.text = content;
      
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
  
  void _showSnackBar(String message, {Duration? duration, SnackBarAction? action}) {
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
                    imageFiles: _imageFiles,
                    isConnected: _isConnected,
                    isSendingMessage: _isSendingMessage,
                    onPickImages: _pickImages,
                    onRemoveImage: _removeImage,
                    onSendMessage: _sendMessage,
                  ),
                ],
              ),
            ),
    );
  }
}
