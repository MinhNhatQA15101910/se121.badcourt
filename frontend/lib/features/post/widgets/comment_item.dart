import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_avatar.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/post/screens/full_screen_media_view.dart';
import 'package:frontend/features/post/services/post_service.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/models/post_resource.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class CommentItem extends StatefulWidget {
  final Comment comment;
  final Function(DateTime) formatDateCallback;

  const CommentItem({
    Key? key,
    required this.comment,
    required this.formatDateCallback,
  }) : super(key: key);

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  final _postService = PostService();
  bool _isLiked = false;
  int _likesCount = 0;
  bool _isLikeLoading = false;
  
  // Video controllers for comment media
  Map<String, VideoPlayerController> _videoControllers = {};
  Map<String, bool> _videoInitialized = {};

  @override
  void initState() {
    super.initState();
    _isLiked = widget.comment.isLiked;
    _likesCount = widget.comment.likesCount;
    _initializeVideoControllers();
  }

  @override
  void dispose() {
    // Dispose video controllers
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeVideoControllers() {
    for (var resource in widget.comment.resources) {
      if (resource is Map<String, dynamic> && resource['url'] != null) {
        final url = resource['url'] as String;
        if (PostService.isVideoUrl(url)) {
          final controller = VideoPlayerController.network(url);
          _videoControllers[url] = controller;
          _videoInitialized[url] = false;
          
          controller.initialize().then((_) {
            if (mounted) {
              setState(() {
                _videoInitialized[url] = true;
              });
            }
          }).catchError((error) {
            print('Error initializing video: $error');
          });
        }
      }
    }
  }

  Future<void> _toggleLike() async {
    if (_isLikeLoading) return;

    setState(() {
      _isLikeLoading = true;
    });

    final previousLikedState = _isLiked;
    final previousLikeCount = _likesCount;

    setState(() {
      if (_isLiked) {
        _likesCount--;
      } else {
        _likesCount++;
      }
      _isLiked = !_isLiked;
    });

    try {
      final success = await _postService.toggleCommentLike(
        context: context,
        commentId: widget.comment.id,
      );

      if (!success) {
        setState(() {
          _isLiked = previousLikedState;
          _likesCount = previousLikeCount;
        });
      }
    } catch (error) {
      setState(() {
        _isLiked = previousLikedState;
        _likesCount = previousLikeCount;
      });
    } finally {
      setState(() {
        _isLikeLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasMedia = widget.comment.resources.isNotEmpty;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info row with like button
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomAvatar(
                radius: 16,
                imageUrl: widget.comment.publisherImageUrl,
                userId: widget.comment.publisherId,
              ),
              const SizedBox(width: 8),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.comment.publisherUsername,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: GlobalVariables.blackGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.formatDateCallback(widget.comment.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              
              GestureDetector(
                onTap: _toggleLike,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _isLiked
                        ? GlobalVariables.green.withOpacity(0.1)
                        : Colors.grey.shade100,
                    border: Border.all(
                      color: _isLiked
                          ? GlobalVariables.green.withOpacity(0.3)
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _isLikeLoading
                          ? SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _isLiked ? GlobalVariables.green : GlobalVariables.darkGrey,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.thumb_up,
                              size: 14,
                              color: _isLiked ? GlobalVariables.green : GlobalVariables.darkGrey,
                            ),
                      if (_likesCount > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          '$_likesCount',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _isLiked ? GlobalVariables.green : GlobalVariables.darkGrey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Comment content
          if (widget.comment.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                widget.comment.content,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: GlobalVariables.blackGrey,
                  height: 1.4,
                ),
              ),
            ),
          
          // Comment media (images and videos)
          if (hasMedia)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildCommentMedia(context, widget.comment.resources),
            ),
        ],
      ),
    );
  }
  
  Widget _buildCommentMedia(BuildContext context, List<dynamic> resources) {
    final mediaUrls = resources
        .where((resource) => resource is Map<String, dynamic> && resource['url'] != null)
        .map<String>((resource) => resource['url'] as String)
        .toList();
    
    if (mediaUrls.isEmpty) return const SizedBox();
    
    if (mediaUrls.length == 1) {
      final url = mediaUrls[0];
      final isVideo = PostService.isVideoUrl(url);
      
      return GestureDetector(
        onTap: () => _openFullScreenMedia(context, mediaUrls, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 16/9,
            child: isVideo 
              ? _buildVideoThumbnail(url)
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
          ),
        ),
      );
    }
    
    // Grid layout for multiple media
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: mediaUrls.length == 2 ? 2 : 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1.0,
      ),
      itemCount: mediaUrls.length > 9 ? 9 : mediaUrls.length,
      itemBuilder: (context, index) {
        final url = mediaUrls[index];
        final isVideo = PostService.isVideoUrl(url);
        
        if (index == 8 && mediaUrls.length > 9) {
          return GestureDetector(
            onTap: () => _openFullScreenMedia(context, mediaUrls, index),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: isVideo 
                    ? _buildVideoThumbnail(url)
                    : Image.network(url, fit: BoxFit.cover),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '+${mediaUrls.length - 8}',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        return GestureDetector(
          onTap: () => _openFullScreenMedia(context, mediaUrls, index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: isVideo 
              ? _buildVideoThumbnail(url)
              : Image.network(url, fit: BoxFit.cover),
          ),
        );
      },
    );
  }

  Widget _buildVideoThumbnail(String videoUrl) {
    final controller = _videoControllers[videoUrl];
    final isInitialized = _videoInitialized[videoUrl] ?? false;

    return Stack(
      children: [
        if (controller != null && isInitialized)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
          )
        else
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
    
    // Play button overlay
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
            size: 32,
          ),
        ),
      ),
    ),
  ],
);
}
  
  void _openFullScreenMedia(BuildContext context, List<String> mediaUrls, int initialIndex) {
    // Convert URLs to PostResource objects with required parameters
    final resources = mediaUrls.map((url) {
      final isVideo = PostService.isVideoUrl(url);
      return PostResource(
        id: url.hashCode.toString(),
        url: url,
        isMain: false, // Comment media is never main
        fileType: isVideo ? 'video' : 'image',
      );
    }).toList();

    Navigator.of(context).pushNamed(
      FullScreenMediaView.routeName,
      arguments: {
        'resources': resources,
        'initialIndex': initialIndex,
        'postTitle': 'Comment Media',
      },
    );
  }
}
