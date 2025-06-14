import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/post_resource.dart';
import 'package:frontend/features/post/services/post_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';

class FullScreenMediaView extends StatefulWidget {
  static const String routeName = '/full-screen-media-view';
  
  final List<PostResource> resources;
  final int initialIndex;
  final String postTitle;

  const FullScreenMediaView({
    Key? key,
    required this.resources,
    required this.initialIndex,
    required this.postTitle,
  }) : super(key: key);

  @override
  State<FullScreenMediaView> createState() => _FullScreenMediaViewState();
}

class _FullScreenMediaViewState extends State<FullScreenMediaView> {
  late CarouselSliderController _carouselController;
  int _currentIndex = 0;
  bool _isControlsVisible = true;
  bool _isDownloading = false;
  
  // Video controllers
  Map<int, VideoPlayerController> _videoControllers = {};
  Map<int, bool> _videoInitialized = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _carouselController = CarouselSliderController();
    _initializeVideoControllers();
    
    // Hide controls after 3 seconds
    _hideControlsAfterDelay();
  }

  void _initializeVideoControllers() {
    for (int i = 0; i < widget.resources.length; i++) {
      final resource = widget.resources[i];
      if (PostService.isVideoUrl(resource.url)) {
        final controller = VideoPlayerController.network(resource.url);
        _videoControllers[i] = controller;
        _videoInitialized[i] = false;
        
        controller.initialize().then((_) {
          if (mounted) {
            setState(() {
              _videoInitialized[i] = true;
            });
          }
        }).catchError((error) {
          print('Error initializing video: $error');
        });
      }
    }
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isControlsVisible = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });
    
    if (_isControlsVisible) {
      _hideControlsAfterDelay();
    }
  }

  @override
  void dispose() {
    // Dispose all video controllers
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _downloadMedia() async {
    if (_isDownloading) return;
    
    setState(() {
      _isDownloading = true;
    });

    try {
      final resource = widget.resources[_currentIndex];
      final isVideo = PostService.isVideoUrl(resource.url);
      
      // Use app's document directory instead of external storage
      final directory = await getApplicationDocumentsDirectory();
      
      // Create BadCourt folder in app directory
      final badCourtDir = Directory('${directory.path}/BadCourt');
      if (!await badCourtDir.exists()) {
        await badCourtDir.create(recursive: true);
      }

      // Generate filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = isVideo ? 'mp4' : 'jpg';
      final filename = 'BadCourt_${timestamp}.$extension';
      final filePath = '${badCourtDir.path}/$filename';

      // Download file
      final response = await http.get(Uri.parse(resource.url));
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        
        IconSnackBar.show(
          context,
          label: '${isVideo ? 'Video' : 'Image'} saved to app folder successfully',
          snackBarType: SnackBarType.success,
        );
      } else {
        throw Exception('Failed to download file');
      }
    } catch (error) {
      IconSnackBar.show(
        context,
        label: 'Download failed: $error',
        snackBarType: SnackBarType.fail,
      );
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Media carousel
            CarouselSlider.builder(
              carouselController: _carouselController,
              itemCount: widget.resources.length,
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height,
                viewportFraction: 1.0,
                enableInfiniteScroll: widget.resources.length > 1,
                initialPage: widget.initialIndex,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                  // Pause all videos when changing page
                  _pauseAllVideos();
                },
              ),
              itemBuilder: (context, index, realIndex) {
                final resource = widget.resources[index];
                final isVideo = PostService.isVideoUrl(resource.url);
                
                return Center(
                  child: isVideo 
                    ? _buildVideoPlayer(index, resource.url)
                    : _buildImageWidget(resource.url),
                );
              },
            ),
            
            // Top controls
            AnimatedOpacity(
              opacity: _isControlsVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Back button
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        
                        // Title and counter
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.postTitle.isNotEmpty)
                                Text(
                                  widget.postTitle,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              Text(
                                '${_currentIndex + 1} of ${widget.resources.length}',
                                style: GoogleFonts.inter(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Download button
                        IconButton(
                          icon: _isDownloading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(
                                Icons.download,
                                color: Colors.white,
                                size: 24,
                              ),
                          onPressed: _isDownloading ? null : _downloadMedia,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(int index, String videoUrl) {
    final controller = _videoControllers[index];
    final isInitialized = _videoInitialized[index] ?? false;

    if (controller == null || !isInitialized) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(GlobalVariables.green),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading video...',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video player
          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),
          
          // Play/Pause button
          if (_isControlsVisible)
            GestureDetector(
              onTap: () {
                setState(() {
                  if (controller.value.isPlaying) {
                    controller.pause();
                  } else {
                    // Pause all other videos first
                    _pauseAllVideosExcept(index);
                    controller.play();
                  }
                });
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          
          // Video progress indicator
          if (_isControlsVisible && controller.value.isPlaying)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  // Progress bar
                  VideoProgressIndicator(
                    controller,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: GlobalVariables.green,
                      bufferedColor: Colors.white.withOpacity(0.3),
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Time display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(controller.value.position),
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _formatDuration(controller.value.duration),
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 3.0,
      panEnabled: true,
      scaleEnabled: true,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Image.network(
          imageUrl,
          fit: BoxFit.fitWidth,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load image',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(GlobalVariables.green),
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading image...',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _pauseAllVideos() {
    for (var controller in _videoControllers.values) {
      if (controller.value.isPlaying) {
        controller.pause();
      }
    }
  }

  void _pauseAllVideosExcept(int exceptIndex) {
    for (int i = 0; i < _videoControllers.length; i++) {
      if (i != exceptIndex) {
        final controller = _videoControllers[i];
        if (controller != null && controller.value.isPlaying) {
          controller.pause();
        }
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
