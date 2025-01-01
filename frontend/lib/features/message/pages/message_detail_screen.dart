import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/common/services/socket_service.dart';
import 'package:frontend/features/message/services/message_service.dart';
import 'package:frontend/features/message/widgets/message_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/user_provider.dart';

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
  final ImagePicker _picker = ImagePicker();
  final List<File> _imageFiles = [];
  final List<Map<String, dynamic>> _messages = [];

  final _messageService = MessageService();
  final _socketService = SocketService();

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
          final timestamp = data['createdAt'];
          final timeFormatted = DateFormat('HH:mm')
              .format(DateTime.fromMillisecondsSinceEpoch(timestamp));
          _messages.insert(0, {
            'isSender': false,
            'message': data['content'],
            'time': timeFormatted,
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
          final timestamp = msg['createdAt'];
          final timeFormatted = DateFormat('HH:mm')
              .format(DateTime.fromMillisecondsSinceEpoch(timestamp));

          return {
            'isSender': msg['isSender'],
            'message': msg['content'],
            'time': timeFormatted,
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

    setState(() {
      _fetchMessages(roomId);
    });

    _messageController.clear();

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
                      return MessageWidget(
                        isSender: message['isSender'] ?? false,
                        message: message['message'] ?? '',
                        time: message['time'] ?? '',
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
