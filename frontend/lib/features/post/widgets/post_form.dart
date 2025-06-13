import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/common/widgets/custom_avatar.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/image_view/screens/full_screen_image_view.dart';
import 'package:frontend/features/post/screens/post_detail_screen.dart';
import 'package:frontend/features/post/services/post_service.dart';
import 'package:frontend/models/post.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PostFormWidget extends StatefulWidget {
  final Post currentPost;
  const PostFormWidget({
    Key? key,
    required this.currentPost,
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
  late Animation<double> _likeAnimation;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.currentPost.likesCount;
    _isLiked = widget.currentPost.isLiked;

    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _likeAnimation = CurvedAnimation(
      parent: _likeController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    if (_isLikeLoading) return;

    setState(() {
      _isLikeLoading = true;
    });

    // Optimistic update
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
    } catch (error) {
      // Revert changes if API call fails
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

  void _navigateToPostDetail() {
    Navigator.of(context).pushNamed(
      PostDetailScreen.routeName,
      arguments: widget.currentPost.id,
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
    final imageCount = widget.currentPost.resources.length;
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
              // Post header with user info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    CustomAvatar(
                      radius: 20,
                      imageUrl: widget.currentPost.publisherImageUrl,
                      userId: widget.currentPost.publisherId,
                    ),
                    const SizedBox(width: 12),

                    // Username and date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.currentPost.publisherUsername,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
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

                    // More options button
                    IconButton(
                      icon: Icon(
                        Icons.more_horiz,
                        color: GlobalVariables.darkGrey,
                      ),
                      onPressed: () {
                        // Show post options
                        _showPostOptions(context);
                      },
                    ),
                  ],
                ),
              ),

              // Post title (if exists)
              if (hasTitle)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    widget.currentPost.title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: GlobalVariables.blackGrey,
                    ),
                  ),
                ),

              // Post content (if exists)
              if (hasContent)
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, hasTitle ? 12 : 16),
                  child: Text(
                    widget.currentPost.content,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: GlobalVariables.blackGrey,
                      height: 1.4,
                      // Add max lines to truncate long content
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Post images (if any)
              if (imageCount > 0) _buildImageCarousel(imageCount),

              // Post actions (like, comment)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Like and comment counts
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Like count with animation
                        Row(
                          children: [
                            ScaleTransition(
                              scale: _likeAnimation,
                              child: Icon(
                                _isLiked
                                    ? Icons.thumb_up
                                    : Icons.thumb_up_outlined,
                                size: 20,
                                color: _isLiked
                                    ? GlobalVariables.green
                                    : GlobalVariables.darkGrey,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$_likeCount ${_likeCount == 1 ? 'like' : 'likes'}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: GlobalVariables.darkGrey,
                              ),
                            ),
                          ],
                        ),

                        // Comment count
                        Row(
                          children: [
                            Icon(
                              Icons.comment_outlined,
                              size: 20,
                              color: GlobalVariables.darkGrey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.currentPost.commentsCount} ${widget.currentPost.commentsCount == 1 ? 'comment' : 'comments'}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: GlobalVariables.darkGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Divider
                    Container(
                      height: 1,
                      color: Colors.grey.shade200,
                    ),

                    const SizedBox(height: 12),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Like button
                        _buildActionButton(
                          icon: _isLiked
                              ? Icons.thumb_up
                              : Icons.thumb_up_outlined,
                          label: 'Like',
                          isActive: _isLiked,
                          isLoading: _isLikeLoading,
                          onTap: () {
                            // Handle like action without navigating
                            _toggleLike();
                          },
                        ),

                        // Comment button
                        _buildActionButton(
                          icon: Icons.comment_outlined,
                          label: 'Comment',
                          onTap: () {
                            // Navigate to post detail
                            _navigateToPostDetail();
                          },
                        ),

                        // Share button
                        _buildActionButton(
                          icon: Icons.share_outlined,
                          label: 'Share',
                          onTap: () {
                            // Share functionality
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

  Widget _buildImageCarousel(int imageCount) {
    return Stack(
      children: [
        // Image carousel
        CarouselSlider.builder(
          itemCount: imageCount,
          options: CarouselOptions(
            viewportFraction: 1.0,
            enableInfiniteScroll: imageCount > 1,
            aspectRatio: 4 / 3,
            enlargeCenterPage: false,
            onPageChanged: (index, reason) => setState(() {
              _activeIndex = index;
            }),
          ),
          itemBuilder: (context, index, realIndex) {
            return GestureDetector(
              onTap: _navigateToPostDetail,
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                ),
                child: Image.network(
                  widget.currentPost.resources[index].url,
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                            GlobalVariables.green),
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),

        // Navigation arrows (only if more than one image)
        if (imageCount > 1) ...[
          // Left arrow
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              // Use onTap instead of onTapDown
              onTap: () {
                // Prevent event bubbling by handling the tap here
                int newIndex =
                    _activeIndex > 0 ? _activeIndex - 1 : imageCount - 1;
                setState(() {
                  _activeIndex = newIndex;
                });
                // Don't call _navigateToPostDetail() here
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

          // Right arrow
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              // Use onTap instead of onTapDown
              onTap: () {
                // Prevent event bubbling by handling the tap here
                int newIndex =
                    _activeIndex < imageCount - 1 ? _activeIndex + 1 : 0;
                setState(() {
                  _activeIndex = newIndex;
                });
                // Don't call _navigateToPostDetail() here
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
        ],

        // Image indicators
        if (imageCount > 1)
          // Fix the image indicators
// Replace the image indicators Positioned widget with this corrected version
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                imageCount,
                (index) {
                  return GestureDetector(
                    onTap: () {
                      // Prevent event bubbling by handling the tap here
                      setState(() {
                        _activeIndex = index;
                      });
                      // Don't call _navigateToPostDetail() here
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    bool isLoading = false,
  }) {
    return GestureDetector(
      // Use onTap instead of onTapDown
      onTap: () {
        // Call the onTap callback directly
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isActive
              ? GlobalVariables.green.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Row(
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
              label,
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

  void _showPostOptions(BuildContext context) {
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
              _buildOptionItem(
                icon: Icons.bookmark_border,
                label: 'Save post',
                onTap: () {
                  Navigator.pop(context);
                  // Save post functionality
                },
              ),
              _buildOptionItem(
                icon: Icons.share_outlined,
                label: 'Share post',
                onTap: () {
                  Navigator.pop(context);
                  // Share post functionality
                },
              ),
              _buildOptionItem(
                icon: Icons.report_outlined,
                label: 'Report post',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  // Report post functionality
                },
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
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : GlobalVariables.darkGrey,
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : GlobalVariables.blackGrey,
        ),
      ),
      onTap: onTap,
    );
  }
}
