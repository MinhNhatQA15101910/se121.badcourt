import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/common/services/socket_service.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/message/services/message_service.dart';
import 'package:frontend/features/message/widgets/message_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/user_provider.dart';

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
  final _messageService = MessageService();
  final _socketService = SocketService();
  late String? userId;

  final ImagePicker _picker = ImagePicker();
  List<File>? _imageFiles = [];

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreMessages = true;

  int _pageNumber = 1;
  final int _pageSize = 10;

  String roomId = "";

  final ScrollController _scrollController = ScrollController();

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
    } else {
      print('userId is null');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _socketService.socket?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      roomId = await _messageService.getOrCreatePersonalMessageRoom(
        context: context,
        userId: userId ?? "",
      );

      _socketService.connect(userProvider.user.token);
      _socketService.enterRoom(roomId);

      _socketService.onNewMessage((data) {
        setState(() {
          _messages.insert(0, {
            'isSender': data['senderId'] == userProvider.user.id,
            'message': data['content'] ?? '',
            'time': data['createdAt'],
          });
        });
      });

      await _fetchMessages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing message services: $e')),
      );
    }
  }

  Future<void> _fetchMessages({bool isLoadingMore = false}) async {
    if (isLoadingMore) {
      if (_isLoadingMore || !_hasMoreMessages) return;
      setState(() {
        _isLoadingMore = true;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final messages = await _messageService.getMessages(
        roomId: roomId,
        context: context,
        pageNumber: _pageNumber,
        pageSize: _pageSize,
      );

      setState(() {
        if (messages.isEmpty || messages.length < _pageSize) {
          _hasMoreMessages = false;
        } else {
          _pageNumber++;
        }

        final newMessages = messages.map<Map<String, dynamic>>((msg) {
          return {
            'isSender': msg['senderId'] == userProvider.user.id,
            'message': msg['content'] ?? '',
            'time': msg['createdAt'] as int? ?? 0,
          };
        }).toList();

        _messages.addAll(newMessages);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching messages: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
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

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message cannot be empty')),
      );
      return;
    }

    final content = _messageController.text.trim();
    _messageController.clear();
    _imageFiles = [];

    try {
      await _messageService.sendMessageToRoom(
        roomId: roomId,
        content: content,
        context: context,
      );
      _socketService.sendMessage(roomId, content);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Details'),
      ),
      body: Column(
        children: [
          _isLoading
              ? CircularProgressIndicator()
              : Expanded(
                  child: ListView.builder(
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: MessageWidget(
                          isSender: message['isSender'] ?? false,
                          message: message['message'] ?? '',
                          time: message['time'],
                          nextTime: nextMessage?['time'],
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
                    onTap: _pickImages,
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: GlobalVariables.green,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _messageController,
                    maxLines: 4,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
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
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () {
                      if (_messageController.text.trim().isNotEmpty ||
                          _imageFiles!.isNotEmpty) {
                        _sendMessage();
                      }
                    },
                    child: const Icon(
                      Icons.send,
                      color: GlobalVariables.green,
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
                child: Image.file(
                  imageFile,
                  fit: BoxFit.cover,
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
