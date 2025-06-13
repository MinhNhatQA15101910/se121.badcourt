import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/post/services/post_service.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CreatePostScreen extends StatefulWidget {
  static const String routeName = '/createPostScreen';
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  final _postService = PostService();
  final ImagePicker _picker = ImagePicker();
  List<File>? _imageFiles = [];
  bool _isLoading = false;
  bool _canPost = false;

  Future<void> _createPost() async {
    if (!_canPost) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      await _postService.createPost(
        context,
        _imageFiles!,
        _descriptionController.text,
        _titleController.text,
      );

      // Navigate back to the previous screen
      Navigator.pop(context, true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage(
      imageQuality: 80,
      maxWidth: 1920,
      maxHeight: 1080,
    );
    
    if (selectedImages != null) {
      setState(() {
        // Calculate remaining slots available
        int remainingSlots = 10 - _imageFiles!.length;

        // Convert XFile to File and add only the remaining number of images if exceeding limit
        if (remainingSlots > 0) {
          _imageFiles?.addAll(
            selectedImages
                .take(remainingSlots)
                .map((xfile) => File(xfile.path))
                .toList(),
          );
        }
        _updateCanPost();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_onTextChanged);
    _titleController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    _updateCanPost();
  }
  
  void _updateCanPost() {
    setState(() {
      _canPost = _titleController.text.trim().isNotEmpty || 
                 _descriptionController.text.trim().isNotEmpty ||
                 (_imageFiles != null && _imageFiles!.isNotEmpty);
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: GlobalVariables.defaultColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: GlobalVariables.green,
        title: Text(
          'Create Post',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: GlobalVariables.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: GlobalVariables.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _isLoading
            ? Container(
                margin: const EdgeInsets.only(right: 16),
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : TextButton(
                onPressed: _canPost ? _createPost : null,
                child: Text(
                  'Post',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _canPost ? Colors.white : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(GlobalVariables.green),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Creating your post...',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: GlobalVariables.darkGrey,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User info section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: GlobalVariables.green,
                              width: 2.0,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              userProvider.user.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.person,
                                size: 32,
                                color: GlobalVariables.green,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          userProvider.user.username,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: GlobalVariables.blackGrey,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Title field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _titleController,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: GlobalVariables.blackGrey,
                        ),
                        maxLines: null,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Add a title to your post',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: GlobalVariables.darkGrey.withOpacity(0.7),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Description field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _descriptionController,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: GlobalVariables.blackGrey,
                        ),
                        maxLines: null,
                        minLines: 5,
                        decoration: InputDecoration(
                          hintText: 'What\'s on your mind?',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: GlobalVariables.darkGrey.withOpacity(0.7),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Image counter
                    if (_imageFiles != null && _imageFiles!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '${_imageFiles!.length}/10 images',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: GlobalVariables.darkGrey,
                          ),
                        ),
                      ),
                    
                    // Image grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: (_imageFiles?.length ?? 0) + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildAddImageButton();
                        } else {
                          return _buildImagePreview(index - 1);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: GlobalVariables.green.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 32,
              color: GlobalVariables.green,
            ),
            const SizedBox(height: 4),
            Text(
              'Add Photos',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: GlobalVariables.green,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _imageFiles![index],
              width: double.infinity,
              height: double.infinity,
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
                _updateCanPost();
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
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
  }
}
