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
import 'package:intl/intl.dart';

class MessageDetailScreen extends StatefulWidget {
  static const String routeName = '/messageDetailScreen';
  final String userId;

  const MessageDetailScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _MessageDetailScreenState createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final _messageService = MessageService();
  final _socketService = SocketService();
  final ImagePicker _picker = ImagePicker();
  List<File>? _imageFiles = [];

  bool _isLoading = true;
  String roomId = "";

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _socketService.socket?.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null) {
      setState(() {
        // Convert XFile to File and add images
        _imageFiles?.addAll(
          selectedImages.map((xfile) => File(xfile.path)).toList(),
        );
      });
    }
  }

  Future<void> _initializeServices() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      // Fetch or create the personal message room to get the roomId
      roomId = await _messageService.getOrCreatePersonalMessageRoom(
        context: context,
        userId: widget.userId,
      );

      // Connect to the socket using the token from UserProvider
      _socketService.connect(userProvider.user.token);

      // Enter the room using the fetched roomId
      _socketService.enterRoom(roomId);

      // Listen for new messages
      _socketService.onNewMessage((data) {
        setState(() {
          _messages.insert(0, {
            'isSender': data['senderId'] == userProvider.user.id,
            'message': data['content'] ?? '',
            'time': data['createdAt'], // Store as int
          });
        });
      });

      // Fetch existing messages from the room
      await _fetchMessages(roomId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing message services: $e')),
      );
    }
  }

  Future<void> _fetchMessages(String roomId) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final messages = await _messageService.getMessages(
        roomId: roomId,
        context: context,
      );

      setState(() {
        _messages.clear();
        _messages.addAll(messages.map<Map<String, dynamic>>((msg) {
          return {
            'isSender': msg['senderId'] == userProvider.user.id,
            'message': msg['content'] ?? '',
            'time': msg['createdAt'] as int? ?? 0,
          };
        }).toList());

        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching messages: $e')),
      );
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
      // REST API for saving the message
      await _messageService.sendMessageToRoom(
        roomId: roomId,
        content: content,
        context: context,
      );
      // Socket event to notify other users
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
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
                Container(
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
                          Container(
                            margin: EdgeInsets.only(bottom: 8),
                            width: double
                                .infinity, // Ensure it takes up the full width
                            child: GridView.builder(
                              shrinkWrap:
                                  true, // Ensure the grid only takes up as much space as needed
                              physics:
                                  NeverScrollableScrollPhysics(), // Prevent scrolling within the grid
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                crossAxisSpacing:
                                    4, // Horizontal spacing between images
                                mainAxisSpacing:
                                    4, // Vertical spacing between images
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
                                        width: double.infinity,
                                        height: double.infinity,
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
                                            color: Colors.black.withOpacity(
                                                0.5), // Semi-transparent background for the "X"
                                            borderRadius: BorderRadius.circular(
                                                12), // Rounded corners for the "X"
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors
                                                .white, // White icon color
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
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
                            SizedBox(
                              width: 8,
                            ),
                            SizedBox(width: 8),
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
                                  if (_messageController.text
                                          .trim()
                                          .isNotEmpty ||
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
                ),
              ],
            ),
    );
  }
}
