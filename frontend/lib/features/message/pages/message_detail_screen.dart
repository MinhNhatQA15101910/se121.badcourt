import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/common/services/group_hub_service.dart';
import 'package:frontend/common/services/message_hub_service.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/message/widgets/message_widget.dart';
import 'package:frontend/models/group_dto.dart';
import 'package:frontend/providers/group_provider.dart';
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

class _MessageDetailScreenState extends State<MessageDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  // Add SignalR services
  final GroupHubService _groupHubService = GroupHubService();
  final MessageHubService _messageHubService = MessageHubService();
  late String? userId;
  UserDto? _otherUser;

  final ImagePicker _picker = ImagePicker();
  List<File>? _imageFiles = [];

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreMessages = true;
  bool _isSendingMessage = false;
  bool _isConnecting = false;
  bool _isConnected = false;

  int _pageNumber = 1;
  final int _pageSize = 10;

  String groupId = "";

  final ScrollController _scrollController = ScrollController();

  Timer? _connectionHealthTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrollListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userId = ModalRoute.of(context)!.settings.arguments as String?;

    if (userId != null) {
      _initializeServices();
      _loadOtherUserInfo();
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

    // Disconnect from MessageHub for this user
    if (userId != null) {
      _messageHubService.stopConnection(userId!);
    }
    super.dispose();
  }

  // Enhanced _initializeServices method with message loading
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
            _messages.insert(0, {
              'isSender': message.senderId == userProvider.user.id,
              'message': message.content,
              'time': message.messageSent.millisecondsSinceEpoch,
              'resources': [],
              'senderImageUrl': message.senderPhotoUrl,
            });
          });
        }
      };

      _messageHubService.onReceiveMessageThread = (messages) {
        print('Received message thread: ${messages.length} messages');
        if (mounted) {
          setState(() {
            _messages.clear();
            for (var message in messages.reversed) {
              _messages.add({
                'isSender': message.senderId == userProvider.user.id,
                'message': message.content,
                'time': message.messageSent.millisecondsSinceEpoch,
                'resources': [],
                'senderImageUrl': message.senderPhotoUrl,
              });
            }
            _isLoading = false;
          });
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
          });
          print(
              '[MessageDetailScreen] No messages received, stopping loading indicator');
        }
      }

      if (!isReady) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to connect to user. Please try again.'),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: _initializeServices,
              ),
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
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error: $e'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _initializeServices,
            ),
          ),
        );
      }
    }
  }

  Future<void> _fetchMessages({bool isLoadingMore = false}) async {
    // This method is kept for future implementation
    // Currently messages are loaded via SignalR callbacks
  }

  void _onScrollListener() {
    if (_isLoading || _isLoadingMore || !_hasMoreMessages) return;

    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchMessages(isLoadingMore: true);
    }
  }

  Future<void> _pickImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null) {
      setState(() {
        _imageFiles?.addAll(
          selectedImages.map((xfile) => File(xfile.path)).toList(),
        );
      });
    }
  }

  // Enhanced _sendMessage method với better retry logic
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty && _imageFiles!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message cannot be empty')),
      );
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
        print(
            '[MessageDetailScreen] Sending message attempt $attempt/$maxAttempts');

        // Kiểm tra và đảm bảo connection
        if (!_messageHubService.isConnectionReady(userId ?? "")) {
          print(
              '[MessageDetailScreen] Connection not ready, attempting to reconnect...');

          try {
            await _messageHubService.startConnection(
              userProvider.user.token,
              userId ?? "",
            );

            // Đợi connection ổn định
            await Future.delayed(Duration(milliseconds: 2000));

            if (!_messageHubService.isConnectionReady(userId ?? "")) {
              if (attempt < maxAttempts) {
                print(
                    '[MessageDetailScreen] Connection still not ready, retrying...');
                continue;
              } else {
                throw Exception('Unable to establish stable connection');
              }
            }
          } catch (connectionError) {
            print(
                '[MessageDetailScreen] Connection error on attempt $attempt: $connectionError');
            if (attempt < maxAttempts) {
              await Future.delayed(Duration(milliseconds: 1000 * attempt));
              continue;
            } else {
              throw Exception(
                  'Connection failed after $maxAttempts attempts: $connectionError');
            }
          }
        }

        // Hiển thị thông tin chi tiết trước khi gửi
        print('[MessageDetailScreen] Sending message to user: $userId');
        print('[MessageDetailScreen] Message content: $content');
        print(
            '[MessageDetailScreen] Connection state: ${_messageHubService.getConnectionStateString(userId ?? "")}');

        // Thử gửi tin nhắn
        try {
          success = await _messageHubService.sendMessage(
            userId ?? "",
            content,
            maxRetries: 1, // Đã có retry ở level này rồi
          );

          if (success) {
            print(
                '[MessageDetailScreen] Message sent successfully on attempt $attempt');
            break;
          } else {
            print(
                '[MessageDetailScreen] Failed to send message on attempt $attempt');
            if (attempt < maxAttempts) {
              await Future.delayed(Duration(milliseconds: 1000 * attempt));
            }
          }
        } catch (sendError) {
          print(
              '[MessageDetailScreen] Send error on attempt $attempt: $sendError');
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString()}'),
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                _sendMessage();
              },
            ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: GlobalVariables.green,
          title: Row(
            children: [
              if (_otherUser != null)
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: GlobalVariables.lightGreen,
                      backgroundImage: _otherUser?.photoUrl != null &&
                              _otherUser!.photoUrl!.isNotEmpty
                          ? NetworkImage(_otherUser!.photoUrl!)
                          : null,
                      child: _otherUser?.photoUrl == null ||
                              _otherUser!.photoUrl!.isEmpty
                          ? Text(
                              _otherUser?.username
                                      .substring(0, 1)
                                      .toUpperCase() ??
                                  '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _otherUser?.username ?? 'Chat',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              else
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
              // Connection status indicator
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isConnected ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isConnected ? Icons.circle : Icons.circle_outlined,
                      color: Colors.white,
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      _isConnected ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isConnecting
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: GlobalVariables.green),
                  SizedBox(height: 16),
                  Text(
                    'Connecting to user...',
                    style: GoogleFonts.inter(fontSize: 16),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                _isLoading
                    ? Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: GlobalVariables.green,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Loading messages...',
                                style: GoogleFonts.inter(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Expanded(
                        child: _messages.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      size: 64,
                                      color: GlobalVariables.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No messages yet',
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        color: GlobalVariables.grey,
                                      ),
                                    ),
                                    Text(
                                      'Start the conversation!',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: GlobalVariables.darkGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                reverse: true,
                                itemCount: _messages.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == _messages.length) {
                                    return _isLoadingMore
                                        ? const Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : const SizedBox.shrink();
                                  }

                                  final message = _messages[index];
                                  final nextMessage =
                                      index > 0 ? _messages[index - 1] : null;

                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: MessageWidget(
                                      isSender: message['isSender'] ?? false,
                                      message: message['message'] ?? '',
                                      time: message['time'],
                                      nextTime: nextMessage?['time'],
                                      imageUrls: (message['resources']
                                              as List<dynamic>?)
                                          ?.map((e) => e.toString())
                                          .toList(),
                                    ),
                                  );
                                },
                              ),
                      ),
                _buildMessageInput(),
              ],
            ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 1,
            color: GlobalVariables.grey,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Column(
          children: [
            if (_imageFiles != null && _imageFiles!.isNotEmpty)
              _buildImagePreview(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: _isConnected ? _pickImages : null,
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      color: _isConnected
                          ? GlobalVariables.green
                          : GlobalVariables.grey,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _messageController,
                    enabled: _isConnected,
                    maxLines: 4,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: _isConnected
                          ? 'Type your message...'
                          : 'Connecting...',
                      hintStyle: GoogleFonts.inter(
                        color: GlobalVariables.darkGrey,
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: GlobalVariables.grey,
                        ),
                      ),
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: _isConnected &&
                            (_messageController.text.trim().isNotEmpty ||
                                _imageFiles!.isNotEmpty)
                        ? _sendMessage
                        : null,
                    child: _isSendingMessage
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: GlobalVariables.green,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            Icons.send,
                            color: _isConnected
                                ? GlobalVariables.green
                                : GlobalVariables.grey,
                            size: 28,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _imageFiles!.length,
        itemBuilder: (context, index) {
          final imageFile = _imageFiles![index];
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.file(
                    imageFile,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _imageFiles?.removeAt(index);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
