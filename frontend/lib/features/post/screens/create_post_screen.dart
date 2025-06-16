import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/post/services/post_service.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

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
  List<File>? _mediaFiles = [];
  bool _isLoading = false;
  bool _canPost = false;

  // Video controllers for preview - Fixed indexing
  List<VideoPlayerController?> _videoControllers = [];
  List<bool> _videoInitialized = [];

  Future<void> _createPost() async {
    if (!_canPost) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _postService.createPost(
        context,
        _mediaFiles!,
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
      await _addMediaFiles(
          selectedImages.map((xfile) => File(xfile.path)).toList());
    }
  }

  Future<void> _pickVideo() async {
    final XFile? selectedVideo = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 10), // 10 minute limit
    );

    if (selectedVideo != null) {
      await _addMediaFiles([File(selectedVideo.path)]);
    }
  }

  Future<void> _addMediaFiles(List<File> newFiles) async {
    List<File> validFiles = [];

    for (File file in newFiles) {
      // Check file size (100MB limit)
      final fileSize = file.lengthSync();
      if (fileSize > PostService.maxFileSize) {
        final fileSizeString = _postService.getFileSizeString(fileSize);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'File "${file.path.split('/').last}" ($fileSizeString) exceeds 100MB limit'),
            backgroundColor: Colors.red,
          ),
        );
        continue;
      }

      // Check if we have space for more files
      if (_mediaFiles!.length >= 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Maximum 10 files allowed'),
            backgroundColor: Colors.orange,
          ),
        );
        break;
      }

      validFiles.add(file);
    }

    if (validFiles.isNotEmpty) {
      setState(() {
        _mediaFiles?.addAll(validFiles);
        _updateCanPost();
      });

      // Initialize video controllers for new video files
      await _initializeNewVideoControllers(validFiles);
    }
  }

  Future<void> _initializeNewVideoControllers(List<File> newFiles) async {
    // Không cần initialize video controllers nữa
    // Chỉ cần return
    return;
  }

  bool _isVideoFile(File file) {
    final fileName = file.path.toLowerCase();
    return PostService.supportedVideoFormats
        .any((format) => fileName.endsWith(format));
  }

  bool _isImageFile(File file) {
    final fileName = file.path.toLowerCase();
    return PostService.supportedImageFormats
        .any((format) => fileName.endsWith(format));
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
          (_mediaFiles != null && _mediaFiles!.isNotEmpty);
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _titleController.dispose();
    // Dispose all video controllers
    for (var controller in _videoControllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
        // Bỏ actions - không có nút Post ở AppBar nữa
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(GlobalVariables.green),
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
          : Column(
              children: [
                // Main content - scrollable
                Expanded(
                  child: SingleChildScrollView(
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
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
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
                                  color:
                                      GlobalVariables.darkGrey.withOpacity(0.7),
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
                                  color:
                                      GlobalVariables.darkGrey.withOpacity(0.7),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Media selection buttons
                          Row(
                            children: [
                              Expanded(
                                child: _buildMediaButton(
                                  icon: Icons.photo_library_outlined,
                                  label: 'Photos',
                                  onTap: _pickImages,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMediaButton(
                                  icon: Icons.videocam_outlined,
                                  label: 'Video',
                                  onTap: _pickVideo,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Media counter and info
                          if (_mediaFiles != null &&
                              _mediaFiles!.isNotEmpty) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_mediaFiles!.length}/10 files',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: GlobalVariables.darkGrey,
                                  ),
                                ),
                                Text(
                                  'Max 100MB per file',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: GlobalVariables.darkGrey
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],

                          // Media grid
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1,
                            ),
                            itemCount: _mediaFiles?.length ?? 0,
                            itemBuilder: (context, index) {
                              return _buildMediaPreview(index);
                            },
                          ),

                          // Add bottom padding to avoid FAB overlap
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context)
              .viewInsets
              .bottom, // <-- tự động đẩy khi bàn phím hiện
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              top: BorderSide(
                color: GlobalVariables.lightGrey,
                width: 1.0,
              ),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canPost ? _createPost : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canPost ? GlobalVariables.green : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Creating...',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Create Post',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: GlobalVariables.green.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: GlobalVariables.green,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: GlobalVariables.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview(int index) {
    final file = _mediaFiles![index];
    final isVideo = _isVideoFile(file);
    final fileSize = file.lengthSync();
    final fileSizeString = _postService.getFileSizeString(fileSize);

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
            child: isVideo
                ? _buildVideoPreview(index, file)
                : _buildImagePreview(file),
          ),
        ),

        // File type and size indicator
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isVideo ? Icons.play_circle_outline : Icons.image,
                  color: Colors.white,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  fileSizeString,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Remove button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              setState(() {
                // Dispose video controller if it exists
                if (index < _videoControllers.length &&
                    _videoControllers[index] != null) {
                  _videoControllers[index]!.dispose();
                }

                _mediaFiles?.removeAt(index);
                if (index < _videoControllers.length) {
                  _videoControllers.removeAt(index);
                }
                if (index < _videoInitialized.length) {
                  _videoInitialized.removeAt(index);
                }

                _updateCanPost();
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.8),
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

  Widget _buildVideoPreview(int index, File videoFile) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video thumbnail placeholder
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          // Video icon
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.videocam,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  'Video',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Play button
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(File imageFile) {
    return Image.file(
      imageFile,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
