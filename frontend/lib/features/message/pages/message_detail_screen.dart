import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/message/widgets/message_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class MessageDetailScreen extends StatefulWidget {
  static const String routeName = '/messageDetailScreen';
  const MessageDetailScreen({Key? key}) : super(key: key);

  @override
  _MessageDetailScreenState createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File>? _imageFiles = [];
  final List<Map<String, dynamic>> _messages = [
    {
      'isSender': false,
      'message': 'Chào bạn',
      'time': '03:30 pm',
    },
    {
      'isSender': false,
      'message': 'Có phải bạn muốn đặt sân cầu lông bên mình không',
      'time': '03:30 pm',
    },
    {
      'isSender': true,
      'message': 'Đúng rồi bạn',
      'time': '03:34 pm',
      'imageUrl': 'https://via.placeholder.com/300',
    },
    {
      'isSender': true,
      'message': 'Mình muốn đặt sân này',
      'time': '03:34 pm',
    },
    {
      'isSender': false,
      'message': 'Oke bạn!',
      'time': '08:30 am',
    },
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty && _imageFiles!.isEmpty) return;

    setState(() {
      _messages.add({
        'isSender': true,
        'message': _messageController.text.trim(),
        'time': _getCurrentTime(),
        'imageFiles': _imageFiles, // Add images to the message
      });
      _imageFiles = []; // Clear images after sending
    });

    _messageController.clear();
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'pm' : 'am';
    return '$hour:$minute $period';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalVariables.green,
        title: Text(
          'Message detail',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.none,
            color: GlobalVariables.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: GlobalVariables.grey,
                ),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://via.placeholder.com/150',
                  ),
                  radius: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nhật Duy',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      Text(
                        'Sân cầu lông nhật duy',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      'https://via.placeholder.com/150',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return MessageWidget(
                  isSender: message['isSender'],
                  message: message['message'],
                  time: message['time'],
                  imageUrl: message['imageUrl'],
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
                      width:
                          double.infinity, // Ensure it takes up the full width
                      child: GridView.builder(
                        shrinkWrap:
                            true, // Ensure the grid only takes up as much space as needed
                        physics:
                            NeverScrollableScrollPhysics(), // Prevent scrolling within the grid
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing:
                              4, // Horizontal spacing between images
                          mainAxisSpacing: 4, // Vertical spacing between images
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
                                      color: Colors.white, // White icon color
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
          ),
        ],
      ),
    );
  }
}
