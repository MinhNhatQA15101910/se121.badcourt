import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/common/widgets/loader.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/post/services/post_service.dart';

class InputCommentWidget extends StatefulWidget {
  final String postId;
  final VoidCallback onCommentCreated;

  const InputCommentWidget({
    Key? key,
    required this.postId,
    required this.onCommentCreated,
  }) : super(key: key);

  @override
  State<InputCommentWidget> createState() => _InputCommentWidgetState();
}

class _InputCommentWidgetState extends State<InputCommentWidget> {
  final TextEditingController _commentController = TextEditingController();
  final _postService = PostService();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  List<File> _selectedImages = [];

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages = images.map((image) => File(image.path)).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _createComment() async {
    if (_commentController.text.trim().isEmpty && _selectedImages.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _postService.createComment(
        context,
        widget.postId,
        _commentController.text,
        _selectedImages,
      );

      // Clear form after successful submission
      _commentController.clear();
      _selectedImages.clear();
      
      // Notify parent widget to update the comment list
      widget.onCommentCreated();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          // Image preview section
          if (_selectedImages.isNotEmpty)
            Container(
              height: 80,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImages[index],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          
          // Input row with auto-expanding height
          Row(
            crossAxisAlignment: CrossAxisAlignment.end, // Align to bottom for multi-line
            children: [
              // Image picker button
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  margin: const EdgeInsets.only(bottom: 4), // Add margin to align with text field
                  child: Icon(
                    Icons.image_outlined,
                    color: GlobalVariables.green,
                    size: 26,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: GlobalVariables.blackGrey,
                  ),
                  maxLines: 5, // Allow up to 5 lines
                  minLines: 1, // Start with 1 line
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline, // Allow new line with enter
                  decoration: InputDecoration(
                    hintText: 'Leave a comment',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: GlobalVariables.darkGrey,
                    ),
                    isDense: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300, // Light gray color
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: GlobalVariables.green,
                        width: 1,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300, // Light gray color
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12, // Increased padding for better multi-line appearance
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),

              // Send button
              _isLoading
                  ? Container(
                      padding: const EdgeInsets.all(6),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: SizedBox(
                        width: 24, 
                        height: 24, 
                        child: Loader(),
                      ),
                    )
                  : GestureDetector(
                      onTap: _createComment,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        margin: const EdgeInsets.only(bottom: 4), // Add margin to align with text field
                        child: Icon(
                          Icons.send_rounded,
                          color: GlobalVariables.green,
                          size: 26,
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}