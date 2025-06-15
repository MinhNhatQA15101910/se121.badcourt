import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class InputComment extends StatefulWidget {
  final TextEditingController controller;
  final bool isLoading;
  final Function(List<File>) onMediaSelected;
  final VoidCallback onSubmit;

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

  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose Images'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImages();
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Choose Video'),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo();
                },
              ),
            ],
          ),
        );
      },
    );
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
          _selectedMedia.addAll(images.map((image) => File(image.path)).toList());
        });
        
        widget.onMediaSelected(_selectedMedia);
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
        
        widget.onMediaSelected(_selectedMedia);
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
    
    widget.onMediaSelected(_selectedMedia);
  }

  bool _isVideoFile(String path) {
    final extension = path.toLowerCase().split('.').last;
    return ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        children: [
          // Media preview section
          if (_selectedMedia.isNotEmpty)
            Container(
              height: 80,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedMedia.length,
                itemBuilder: (context, index) {
                  final file = _selectedMedia[index];
                  final isVideo = _isVideoFile(file.path);
                  
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Stack(
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
                            child: Stack(
                              children: [
                                // Thumbnail
                                isVideo && _videoThumbnails[file.path] != null
                                  ? Image.file(
                                      File(_videoThumbnails[file.path]!),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    )
                                  : isVideo
                                    ? Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.black54,
                                        child: const Center(
                                          child: Icon(
                                            Icons.videocam,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      )
                                    : Image.file(
                                        file,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                
                                // Video play icon overlay
                                if (isVideo)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                          size: 20,
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
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeMedia(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14,
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
            children: [
              // Media picker button
              GestureDetector(
                onTap: _pickMedia,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedMedia.isNotEmpty
                        ? GlobalVariables.green.withOpacity(0.1)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    color: _selectedMedia.isNotEmpty
                        ? GlobalVariables.green
                        : GlobalVariables.darkGrey,
                    size: 22,
                  ),
                ),
              ),
              
              // Text input field
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1.5,
                    ),
                    color: Colors.grey.shade50,
                  ),
                  child: TextField(
                    controller: widget.controller,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: GlobalVariables.blackGrey,
                    ),
                    maxLines: 4,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
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
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: GlobalVariables.green,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: widget.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                  onPressed: widget.onSubmit,
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
