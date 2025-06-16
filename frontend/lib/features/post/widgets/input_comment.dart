import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class InputComment extends StatefulWidget {
  final TextEditingController controller;
  final bool isLoading;
  final Function(String, List<File>) onSubmit;
  final Function() onMediaSelected;

  const InputComment({
    Key? key,
    required this.controller,
    required this.isLoading,
    required this.onSubmit,
    required this.onMediaSelected,
  }) : super(key: key);

  @override
  State<InputComment> createState() => _InputCommentState();
}

class _InputCommentState extends State<InputComment> {
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedMedia = [];
  Map<String, String?> _videoThumbnails = {};
  bool _showMediaOptions = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Listen to focus changes
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _showMediaOptions) {
        setState(() {
          _showMediaOptions = false;
        });
      }
    });

    // Listen to text changes
    widget.controller.addListener(() {
      if (widget.controller.text.isNotEmpty && _showMediaOptions) {
        setState(() {
          _showMediaOptions = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedMedia
              .addAll(images.map((image) => File(image.path)).toList());
        });

        widget.onMediaSelected();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 10),
      );

      if (video != null) {
        final file = File(video.path);
        final fileSize = await file.length();

        // Check file size (100MB = 100 * 1024 * 1024 bytes)
        if (fileSize > 100 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video size must be under 100MB')),
          );
          return;
        }

        // Generate thumbnail
        final thumbnail = await VideoThumbnail.thumbnailFile(
          video: video.path,
          thumbnailPath: (await Directory.systemTemp.createTemp()).path,
          imageFormat: ImageFormat.JPEG,
          maxHeight: 200,
          quality: 75,
        );

        setState(() {
          _selectedMedia.add(file);
          if (thumbnail != null) {
            _videoThumbnails[video.path] = thumbnail;
          }
        });

        widget.onMediaSelected();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking video: $e')),
      );
    }
  }

  void _removeMedia(int index) {
    final file = _selectedMedia[index];
    setState(() {
      _selectedMedia.removeAt(index);
      _videoThumbnails.remove(file.path);
    });

    widget.onMediaSelected();
  }

  bool _isVideoFile(String path) {
    final extension = path.toLowerCase().split('.').last;
    return ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension);
  }

  void _clearMedia() {
    setState(() {
      _selectedMedia.clear();
      _videoThumbnails.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        children: [
          // Media preview section
          if (_selectedMedia.isNotEmpty)
            Container(
              height: 90,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedMedia.length,
                itemBuilder: (context, index) {
                  final file = _selectedMedia[index];
                  final isVideo = _isVideoFile(file.path);

                  return Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                // Thumbnail
                                isVideo && _videoThumbnails[file.path] != null
                                    ? Image.file(
                                        File(_videoThumbnails[file.path]!),
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                      )
                                    : isVideo
                                        ? Container(
                                            width: 90,
                                            height: 90,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.black54,
                                                  Colors.black38
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.videocam,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                            ),
                                          )
                                        : Image.file(
                                            file,
                                            width: 90,
                                            height: 90,
                                            fit: BoxFit.cover,
                                          ),

                                // Video play icon overlay
                                if (isVideo)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.play_circle_filled,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // Remove button
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () => _removeMedia(index),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
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

          // Input row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Media options toggle button
              GestureDetector(
                onTap: () {
                  _focusNode.unfocus();
                  setState(() {
                    _showMediaOptions = !_showMediaOptions;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: AnimatedRotation(
                    turns: _showMediaOptions ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: _showMediaOptions
                          ? GlobalVariables.green
                          : GlobalVariables.darkGrey,
                      size: 24,
                    ),
                  ),
                ),
              ),

              // Media options (show when expanded)
              if (_showMediaOptions) ...[
                const SizedBox(width: 8),
                // Image picker button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showMediaOptions = false;
                    });
                    _pickImages();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 7),
                    child: Icon(
                      Icons.image_outlined,
                      color: GlobalVariables.green,
                      size: 32,
                    ),
                  ),
                ),

                const SizedBox(width: 6),
                // Video picker button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showMediaOptions = false;
                    });
                    _pickVideo();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 7),
                    child: Icon(
                      Icons.videocam_outlined,
                      color: GlobalVariables.green,
                      size: 32,
                    ),
                  ),
                ),
              ],

              // Text input field
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    left: 8,
                    right: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _focusNode.hasFocus
                          ? GlobalVariables.green.withOpacity(0.5)
                          : Colors.grey.shade300,
                      width: _focusNode.hasFocus ? 2 : 1.5,
                    ),
                    color: Colors.grey.shade50,
                    boxShadow: _focusNode.hasFocus
                        ? [
                            BoxShadow(
                              color: GlobalVariables.green.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : [],
                  ),
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: GlobalVariables.blackGrey,
                      height: 1.3,
                    ),
                    maxLines: 4,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Comment...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade500,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              // Send button
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      GlobalVariables.green,
                      GlobalVariables.green.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: GlobalVariables.green.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: widget.isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                  onPressed: () {
                    // Debug: Print media count before sending
                    print('DEBUG: Selected media count: ${_selectedMedia.length}');
                    for (int i = 0; i < _selectedMedia.length; i++) {
                      print('DEBUG: Media $i: ${_selectedMedia[i].path}');
                    }
                    
                    // Only proceed if there's content or media
                    if (widget.controller.text.trim().isEmpty && _selectedMedia.isEmpty) {
                      print('DEBUG: No content and no media, returning');
                      return;
                    }
                    
                    // Create deep copies to completely avoid concurrent modification
                    final textToSend = widget.controller.text.trim();
                    final List<File> mediaToSend = [];
                    
                    // Create new File objects with same paths
                    for (File file in _selectedMedia) {
                      mediaToSend.add(File(file.path));
                    }
                    
                    print('DEBUG: About to send - Text: "$textToSend", Media count: ${mediaToSend.length}');
                    
                    // Call onSubmit with copies
                    widget.onSubmit(textToSend, mediaToSend);
                    
                    // Clear input immediately
                    widget.controller.clear();
                    
                    // DON'T clear media immediately - wait for upload to complete
                    // The parent should handle clearing after successful upload
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
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
