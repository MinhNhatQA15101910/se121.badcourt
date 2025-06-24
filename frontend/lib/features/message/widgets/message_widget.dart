import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/common/screens/full_screen_media_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:frontend/models/file_dto.dart';

class MessageWidget extends StatelessWidget {
  final bool isSender;
  final String message;
  final int time;
  final int? nextTime;
  final List<FileDto>? mediaFiles;
  final bool? isNextMessageFromSameSender;
  final bool? isPreviousMessageFromSameSender;

  const MessageWidget({
    Key? key,
    required this.isSender,
    required this.message,
    required this.time,
    this.nextTime,
    this.mediaFiles,
    this.isNextMessageFromSameSender,
    this.isPreviousMessageFromSameSender,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentDate = DateTime.fromMillisecondsSinceEpoch(time);
    final nextDate = nextTime != null
        ? DateTime.fromMillisecondsSinceEpoch(nextTime!)
        : null;

    final formattedTime = DateFormat('HH:mm').format(currentDate);
    final isSameMinute =
        nextDate != null && currentDate.difference(nextDate).inMinutes == 0;

    final bottomMargin = _getBottomMargin();

    return Column(
      children: [
        Align(
          alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(
              left: isSender ? 60 : 0,
              right: isSender ? 0 : 60,
              bottom: bottomMargin,
            ),
            child: Column(
              crossAxisAlignment:
                  isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (mediaFiles != null && mediaFiles!.isNotEmpty)
                  _buildMediaGrid(context),
                if (message.isNotEmpty) _buildTextBubble(context),
                if (!isSameMinute && !_shouldHideTimestamp())
                  _buildTimeStamp(formattedTime),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double _getBottomMargin() {
    if (isNextMessageFromSameSender == true &&
        nextTime != null &&
        (time - nextTime!) < 120000) {
      return 2.0;
    }
    return 8.0;
  }

  bool _shouldHideTimestamp() {
    return isNextMessageFromSameSender == true &&
           nextTime != null &&
           (time - nextTime!) < 60000;
  }

  BorderRadius _getBorderRadius() {
    final isFirstInGroup = isPreviousMessageFromSameSender != true;
    final isLastInGroup = isNextMessageFromSameSender != true;

    if (isSender) {
      return BorderRadius.only(
        topLeft: const Radius.circular(20),
        topRight: Radius.circular(isFirstInGroup ? 20 : 6),
        bottomLeft: const Radius.circular(20),
        bottomRight: Radius.circular(isLastInGroup ? 20 : 6),
      );
    } else {
      return BorderRadius.only(
        topLeft: Radius.circular(isFirstInGroup ? 20 : 6),
        topRight: const Radius.circular(20),
        bottomLeft: Radius.circular(isLastInGroup ? 20 : 6),
        bottomRight: const Radius.circular(20),
      );
    }
  }

  Widget _buildMediaGrid(BuildContext context) {
    if (mediaFiles == null || mediaFiles!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: _getBorderRadius(),
        child: mediaFiles!.length == 1
            ? _buildSingleMedia(mediaFiles!.first, context)
            : _buildMultipleMedia(context),
      ),
    );
  }

  Widget _buildSingleMedia(FileDto file, BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToFullScreen(context, 0),
      child: Container(
        width: 200,
        height: 200,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildMediaWidget(file, context),
        ),
      ),
    );
  }

  Widget _buildMultipleMedia(BuildContext context) {
    return SizedBox(
      width: 200,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: mediaFiles!.length > 2 ? 2 : mediaFiles!.length,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1.0, // Square aspect ratio
        ),
        itemCount: mediaFiles!.length > 4 ? 4 : mediaFiles!.length,
        itemBuilder: (context, index) {
          if (index == 3 && mediaFiles!.length > 4) {
            return GestureDetector(
              onTap: () => _navigateToFullScreen(context, index),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildMoreMediaOverlay(),
              ),
            );
          }
          return GestureDetector(
            onTap: () => _navigateToFullScreen(context, index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildMediaWidget(mediaFiles![index], context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMediaWidget(FileDto file, BuildContext context) {
    switch (file.fileType.toLowerCase()) {
      case 'image':
        return _buildImageWidget(file.url);
      case 'video':
        return _buildVideoWidget(file.url, context);
      default:
        return _buildUnsupportedMediaWidget(file.fileType);
    }
  }

  Widget _buildImageWidget(String url) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image(
          image: url.startsWith('/data') || url.startsWith('/storage')
              ? FileImage(File(url))
              : NetworkImage(url) as ImageProvider,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey.shade200,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade300,
              child: const Center(
                child: Icon(
                  Icons.broken_image,
                  color: Colors.grey,
                  size: 40,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoWidget(String url, BuildContext context) {
    return VideoThumbnailWidget(
      videoUrl: url,
      onTap: () {
        _showVideoPlayer(url, context);
      },
    );
  }

  Widget _buildUnsupportedMediaWidget(String fileType) {
    return Container(
      color: Colors.grey.shade300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_drive_file,
              color: Colors.grey.shade600,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              fileType.toUpperCase(),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreMediaOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Text(
          '+${mediaFiles!.length - 3}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showVideoPlayer(String videoUrl, BuildContext context) {
    final index = mediaFiles!.indexWhere((file) => file.url == videoUrl);
    _navigateToFullScreen(context, index >= 0 ? index : 0);
  }

  Widget _buildTextBubble(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSender ? const Color(0xFF23C16B) : Colors.grey.shade200,
        borderRadius: _getBorderRadius(),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: isSender ? Colors.white : Colors.black87,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildTimeStamp(String formattedTime) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
      child: Text(
        formattedTime,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  void _navigateToFullScreen(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenMediaView(
          resources: mediaFiles!,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class VideoThumbnailWidget extends StatefulWidget {
  final String videoUrl;
  final VoidCallback onTap;

  const VideoThumbnailWidget({
    Key? key,
    required this.videoUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() async {
    try {
      _controller = widget.videoUrl.startsWith('/data') ||
                   widget.videoUrl.startsWith('/storage')
          ? VideoPlayerController.file(File(widget.videoUrl))
          : VideoPlayerController.network(widget.videoUrl);

      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Video thumbnail or loading/error state
              if (_isInitialized && _controller != null && !_hasError)
                AspectRatio(
                  aspectRatio: 1.0, // Square aspect ratio
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                )
              else if (_hasError)
                Container(
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ),
                )
              else
                Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                  ),
                ),

              // Play button overlay
              Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),

              // Duration badge
              if (_isInitialized && _controller != null && !_hasError)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _formatDuration(_controller!.value.duration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
