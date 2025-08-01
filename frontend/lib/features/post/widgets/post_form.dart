import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_avatar.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/common/screens/full_screen_media_view.dart';
import 'package:frontend/features/post/screens/post_detail_screen.dart';
import 'package:frontend/features/post/services/post_service.dart';
import 'package:frontend/models/post.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class PostFormWidget extends StatefulWidget {
  final Post currentPost;
  // NEW: Add callback functions
  final Function(String)? onPostDeleted;
  final Function(Post)? onPostUpdated;
  final VoidCallback? onNavigateToDetail;
  
  const PostFormWidget({
    Key? key,
    required this.currentPost,
    this.onPostDeleted,
    this.onPostUpdated,
    this.onNavigateToDetail,
  }) : super(key: key);

  @override
  State<PostFormWidget> createState() => _PostFormWidgetState();
}

class _PostFormWidgetState extends State<PostFormWidget>
    with SingleTickerProviderStateMixin {
  final _postService = PostService();

  int _activeIndex = 0;
  bool _isLiked = false;
  bool _isLikeLoading = false;
  int _likeCount = 0;

  late AnimationController _likeController;
  Map<int, VideoPlayerController> _videoControllers = {};
  Map<int, bool> _videoInitialized = {};

  @override
  void initState() {
    super.initState();
    _likeCount = widget.currentPost.likesCount;
    _isLiked = widget.currentPost.isLiked;

    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _initializeVideoControllers();
  }

  void _initializeVideoControllers() {
    for (int i = 0; i < widget.currentPost.resources.length; i++) {
      final resource = widget.currentPost.resources[i];
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

  @override
  void dispose() {
    _likeController.dispose();
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _toggleLike() async {
    if (_isLikeLoading) return;

    setState(() {
      _isLikeLoading = true;
    });

    final previousLikedState = _isLiked;
    final previousLikeCount = _likeCount;

    setState(() {
      if (_isLiked) {
        _likeCount--;
      } else {
        _likeCount++;
        _likeController.forward(from: 0.0);
      }
      _isLiked = !_isLiked;
    });

    try {
      await _postService.toggleLike(
        context: context,
        postId: widget.currentPost.id,
      );

      // NEW: Notify parent about the update
      if (widget.onPostUpdated != null) {
        final updatedPost = Post(
          id: widget.currentPost.id,
          title: widget.currentPost.title,
          content: widget.currentPost.content,
          publisherId: widget.currentPost.publisherId,
          publisherUsername: widget.currentPost.publisherUsername,
          publisherImageUrl: widget.currentPost.publisherImageUrl,
          resources: widget.currentPost.resources,
          likesCount: _likeCount,
          commentsCount: widget.currentPost.commentsCount,
          isLiked: _isLiked,
          createdAt: widget.currentPost.createdAt,
        );
        widget.onPostUpdated!(updatedPost);
      }
    } catch (error) {
      setState(() {
        _isLiked = previousLikedState;
        _likeCount = previousLikeCount;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to toggle like. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLikeLoading = false;
      });
    }
  }

  Future<void> _reportPost() async {
    try {
      await _postService.reportPost(
        context: context,
        postId: widget.currentPost.id,
      );
    } catch (error) {}
    Navigator.of(context).pop();
  }

  // NEW: Modified to handle post deletion
  Future<void> _deletePost() async {
    try {
      await _postService.deletePost(
        context: context,
        postId: widget.currentPost.id,
      );
      
      // Notify parent about deletion
      if (widget.onPostDeleted != null) {
        widget.onPostDeleted!(widget.currentPost.id);
      }
    } catch (error) {}
    Navigator.of(context).pop();
  }

  void _navigateToPostDetail() {
    // NEW: Use callback if provided, otherwise use default navigation
    if (widget.onNavigateToDetail != null) {
      widget.onNavigateToDetail!();
    } else {
      Navigator.of(context).pushNamed(
        PostDetailScreen.routeName,
        arguments: widget.currentPost.id,
      );
    }
  }

  void _navigateToMediaView(int initialIndex) {
    Navigator.of(context).pushNamed(
      FullScreenMediaView.routeName,
      arguments: {
        'resources': widget.currentPost.resources,
        'initialIndex': initialIndex,
        'postTitle': widget.currentPost.title,
      },
    );
  }

  String formatDate(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return DateFormat('MMM dd, yyyy').format(createdAt);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final resourceCount = widget.currentPost.resources.length;
    final hasTitle = widget.currentPost.title.isNotEmpty;
    final hasContent = widget.currentPost.content.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _navigateToPostDetail,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomAvatar(
                      radius: 20,
                      imageUrl: widget.currentPost.publisherImageUrl,
                      userId: widget.currentPost.publisherId,
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.currentPost.publisherUsername,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: GlobalVariables.blackGrey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formatDate(widget.currentPost.createdAt),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: GlobalVariables.darkGrey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      icon: Icon(
                        Icons.more_horiz,
                        color: GlobalVariables.darkGrey,
                      ),
                      onPressed: () {
                        _showPostOptions(
                            context, widget.currentPost.publisherId);
                      },
                    ),
                  ],
                ),
              ),

              if (hasTitle)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    widget.currentPost.title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: GlobalVariables.blackGrey,
                    ),
                  ),
                ),

              if (hasContent)
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, hasTitle ? 12 : 16),
                  child: Text(
                    widget.currentPost.content,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: GlobalVariables.blackGrey,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              if (resourceCount > 0) _buildMediaCarousel(resourceCount),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      height: 1,
                      color: Colors.grey.shade200,
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildActionButtonWithCount(
                          icon: _isLiked
                              ? Icons.thumb_up
                              : Icons.thumb_up_outlined,
                          label: 'Like',
                          count: _likeCount,
                          isActive: _isLiked,
                          isLoading: _isLikeLoading,
                          onTap: () {
                            _toggleLike();
                          },
                        ),

                        _buildActionButtonWithCount(
                          icon: Icons.comment_outlined,
                          label: 'Comment',
                          count: widget.currentPost.commentsCount,
                          onTap: () {
                            _navigateToPostDetail();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaCarousel(int resourceCount) {
    return Stack(
      children: [
        SizedBox(
          height: 300,
          child: CarouselSlider.builder(
            itemCount: resourceCount,
            options: CarouselOptions(
              viewportFraction: 1.0,
              enableInfiniteScroll: resourceCount > 1,
              height: 300,
              enlargeCenterPage: false,
              onPageChanged: (index, reason) => setState(() {
                _activeIndex = index;
                _pauseAllVideosExcept(index);
              }),
            ),
            itemBuilder: (context, index, realIndex) {
              final resource = widget.currentPost.resources[index];
              final isVideo = PostService.isVideoUrl(resource.url);

              return GestureDetector(
                onTap: () => _navigateToMediaView(index),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                  ),
                  child: isVideo
                      ? _buildVideoPlayer(index, resource.url)
                      : _buildImageWidget(resource.url),
                ),
              );
            },
          ),
        ),

        if (resourceCount > 1) ...[
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  int newIndex =
                      _activeIndex > 0 ? _activeIndex - 1 : resourceCount - 1;
                  setState(() {
                    _activeIndex = newIndex;
                  });
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  int newIndex =
                      _activeIndex < resourceCount - 1 ? _activeIndex + 1 : 0;
                  setState(() {
                    _activeIndex = newIndex;
                  });
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],

        if (resourceCount > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                resourceCount,
                (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _activeIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: _activeIndex == index ? 16 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _activeIndex == index
                            ? GlobalVariables.green
                            : Colors.white.withOpacity(0.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoPlayer(int index, String videoUrl) {
    final controller = _videoControllers[index];
    final isInitialized = _videoInitialized[index] ?? false;

    if (controller == null || !isInitialized) {
      return Container(
        width: double.infinity,
        height: 300,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(GlobalVariables.green),
              ),
              const SizedBox(height: 8),
              Text(
                'Loading video...',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            height: 300,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                if (controller.value.isPlaying) {
                  controller.pause();
                } else {
                  _pauseAllVideosExcept(index);
                  controller.play();
                }
              });
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _formatDuration(controller.value.duration),
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    return SizedBox(
      width: double.infinity,
      height: 300,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: Center(
              child: Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 50,
              ),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(GlobalVariables.green),
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      ),
    );
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

  Widget _buildActionButtonWithCount({
    required IconData icon,
    required String label,
    required int count,
    required VoidCallback onTap,
    bool isActive = false,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isActive
              ? GlobalVariables.green.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isActive ? GlobalVariables.green : GlobalVariables.darkGrey,
                  ),
                ),
              )
            else
              Icon(
                icon,
                size: 20,
                color:
                    isActive ? GlobalVariables.green : GlobalVariables.darkGrey,
              ),
            const SizedBox(width: 6),
            Text(
              count > 0 ? '$label ($count)' : label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    isActive ? GlobalVariables.green : GlobalVariables.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPostOptions(BuildContext context, String userId) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              if (userProvider.user.id == userId)
                _buildOptionItem(
                  icon: Icons.delete,
                  label: 'Delete this post',
                  onTap: _deletePost,
                )
              else
                _buildOptionItem(
                  icon: Icons.report_outlined,
                  label: 'Report this post',
                  onTap: _reportPost,
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: GlobalVariables.darkGrey,
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: GlobalVariables.blackGrey,
        ),
      ),
      onTap: onTap,
    );
  }
}