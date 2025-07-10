import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/common/widgets/custom_avatar.dart';
import 'package:frontend/common/widgets/loader.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/common/screens/full_screen_media_view.dart';
import 'package:frontend/features/post/services/post_service.dart';
import 'package:frontend/features/post/widgets/comment_item.dart';
import 'package:frontend/features/post/widgets/input_comment.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/models/post.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';

class PostDetailScreen extends StatefulWidget {
  static const String routeName = '/post-detail';
  final String postId;

  const PostDetailScreen({
    Key? key,
    required this.postId,
  }) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen>
    with SingleTickerProviderStateMixin {
  final _postService = PostService();
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Post? _post;
  Post? _originalPost;
  bool _isLoading = true;
  bool _isLikeLoading = false;
  bool _isCommentLoading = false;
  int _activeIndex = 0;
  int _currentPage = 1;
  int _totalPages = 1;
  List<Comment> _commentList = [];
  bool _isLoadingComments = false;

  bool _isLiked = false;
  int _likeCount = 0;
  int _commentCount = 0;

  late AnimationController _likeController;
  Map<int, VideoPlayerController> _videoControllers = {};
  Map<int, bool> _videoInitialized = {};

  @override
  void initState() {
    super.initState();

    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fetchPostDetails();
  }

  @override
  void dispose() {
    _likeController.dispose();
    _commentController.dispose();
    _scrollController.dispose();
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeVideoControllers() {
    if (_post == null) return;

    for (int i = 0; i < _post!.resources.length; i++) {
      final resource = _post!.resources[i];
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

  Future<void> _reportPost() async {
    try {
      await _postService.reportPost(
        context: context,
        postId: widget.postId,
      );
    } catch (error) {}
    Navigator.of(context).pop();
  }

  // FIXED: Immediately navigate back with deletion result
  Future<void> _deletePost() async {
    // Close the bottom sheet first
    Navigator.of(context).pop();
    
    try {
      await _postService.deletePost(
        context: context,
        postId: widget.postId,
      );
      
      // FIXED: Navigate back immediately with deletion result
      if (mounted) {
        Navigator.of(context).pop({
          'action': 'deleted',
          'postId': widget.postId,
        });
      }
    } catch (error) {
      // Even if there's an error, we might want to go back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete post: $error'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _fetchPostDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final post = await _postService.fetchPostById(
        context: context,
        postId: widget.postId,
      );

      if (post != null) {
        setState(() {
          _post = post;
          _originalPost = post;
          _isLiked = post.isLiked;
          _likeCount = post.likesCount;
          _commentCount = post.commentsCount;
        });

        _initializeVideoControllers();
        _fetchCommentByPostId();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post not found'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading post: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCommentByPostId() async {
    if (_isLoadingComments || (_currentPage > _totalPages)) return;

    setState(() {
      _isLoadingComments = true;
    });

    try {
      final result = await _postService.fetchCommentsByPostId(
        context: context,
        postId: widget.postId,
        pageNumber: _currentPage,
      );

      final List<Comment> newComments = result['comments'] ?? [];
      final int totalPages = result['totalPages'] ?? 0;

      setState(() {
        _commentList.addAll(newComments);
        _totalPages = totalPages;
        _currentPage++;
      });
    } catch (error) {
      IconSnackBar.show(
        context,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );
    } finally {
      setState(() {
        _isLoadingComments = false;
      });
    }
  }

  Future<void> _refreshComments() async {
    setState(() {
      _commentList.clear();
      _currentPage = 1;
      _totalPages = 1;
    });
    await _fetchCommentByPostId();
  }

  Future<void> _submitComment(String commentText, List<File> mediaFiles) async {
    if ((commentText.isEmpty && mediaFiles.isEmpty) || _isCommentLoading) {
      return;
    }

    setState(() {
      _isCommentLoading = true;
    });

    try {
      await _postService.createComment(
        context,
        widget.postId,
        commentText,
        mediaFiles,
      );

      await _refreshComments();

      // FIXED: Update comment count immediately
      setState(() {
        _commentCount++;
      });

      // Update the post object
      if (_post != null) {
        final updatedPost = Post(
          id: _post!.id,
          title: _post!.title,
          content: _post!.content,
          publisherId: _post!.publisherId,
          publisherUsername: _post!.publisherUsername,
          publisherImageUrl: _post!.publisherImageUrl,
          resources: _post!.resources,
          likesCount: _likeCount,
          commentsCount: _commentCount,
          isLiked: _isLiked,
          createdAt: _post!.createdAt,
        );

        setState(() {
          _post = updatedPost;
        });
      }

    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to post comment: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isCommentLoading = false;
      });
    }
  }

  void _onMediaSelected() {
    print('DEBUG: Media selected callback');
  }

  Future<void> _toggleLike() async {
    if (_isLikeLoading || _post == null) return;

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
        postId: widget.postId,
      );

      // Update the post object
      if (_post != null) {
        final updatedPost = Post(
          id: _post!.id,
          title: _post!.title,
          content: _post!.content,
          publisherId: _post!.publisherId,
          publisherUsername: _post!.publisherUsername,
          publisherImageUrl: _post!.publisherImageUrl,
          resources: _post!.resources,
          likesCount: _likeCount,
          commentsCount: _commentCount,
          isLiked: _isLiked,
          createdAt: _post!.createdAt,
        );

        setState(() {
          _post = updatedPost;
        });
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

  // FIXED: Better change detection and navigation result
  void _navigateBack() {
    if (_originalPost != null && _post != null) {
      final hasChanges = _originalPost!.likesCount != _likeCount ||
                        _originalPost!.commentsCount != _commentCount ||
                        _originalPost!.isLiked != _isLiked;
      
      if (hasChanges) {
        final updatedPost = Post(
          id: _post!.id,
          title: _post!.title,
          content: _post!.content,
          publisherId: _post!.publisherId,
          publisherUsername: _post!.publisherUsername,
          publisherImageUrl: _post!.publisherImageUrl,
          resources: _post!.resources,
          likesCount: _likeCount,
          commentsCount: _commentCount,
          isLiked: _isLiked,
          createdAt: _post!.createdAt,
        );
        
        Navigator.of(context).pop({
          'action': 'updated',
          'post': updatedPost,
        });
      } else {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: GlobalVariables.green,
          title: Text(
            'Post Details',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _navigateBack,
          ),
        ),
        body: const Center(child: Loader()),
      );
    }

    if (_post == null) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: GlobalVariables.green,
          title: Text(
            'Post Details',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Post not found',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: GlobalVariables.darkGrey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The post you are looking for does not exist or has been removed',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final imageCount = _post!.resources.length;
    final hasTitle = _post!.title.isNotEmpty;
    final hasContent = _post!.content.isNotEmpty;

    // FIXED: Use WillPopScope to handle back button
    return WillPopScope(
      onWillPop: () async {
        _navigateBack();
        return false; // Prevent default back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: GlobalVariables.green,
          title: Text(
            'Post Details',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _navigateBack, // FIXED: Use custom navigation
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () => _showPostOptions(context, _post!.publisherId),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _fetchPostDetails();
                },
                color: GlobalVariables.green,
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 80),
                  children: [
                    // Post header with user info
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomAvatar(
                            radius: 20,
                            imageUrl: _post!.publisherImageUrl,
                            userId: _post!.publisherId,
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _post!.publisherUsername,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: GlobalVariables.blackGrey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  formatDate(_post!.createdAt),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: GlobalVariables.darkGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (hasTitle)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Text(
                          _post!.title,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: GlobalVariables.blackGrey,
                          ),
                        ),
                      ),

                    if (hasContent)
                      Padding(
                        padding:
                            EdgeInsets.fromLTRB(16, 0, 16, hasTitle ? 12 : 16),
                        child: Text(
                          _post!.content,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: GlobalVariables.blackGrey,
                            height: 1.4,
                          ),
                        ),
                      ),

                    if (imageCount > 0) _buildImageCarousel(imageCount),

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
                              _buildActionButton(
                                icon: _isLiked
                                    ? Icons.thumb_up
                                    : Icons.thumb_up_outlined,
                                label:
                                    'Like ${_likeCount > 0 ? '($_likeCount)' : ''}',
                                isActive: _isLiked,
                                isLoading: _isLikeLoading,
                                onTap: _toggleLike,
                              ),

                              _buildActionButton(
                                icon: Icons.comment_outlined,
                                label:
                                    'Comment ${_commentCount > 0 ? '($_commentCount)' : ''}',
                                onTap: () {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  _scrollController.animateTo(
                                    _scrollController.position.maxScrollExtent,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Container(
                      height: 8,
                      color: Colors.grey.shade100,
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Comments',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: GlobalVariables.blackGrey,
                                ),
                              ),
                              if (_commentList.isNotEmpty)
                                TextButton(
                                  onPressed: _refreshComments,
                                  style: TextButton.styleFrom(
                                    foregroundColor: GlobalVariables.green,
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Refresh',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          if (_commentList.isEmpty && _isLoadingComments)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      GlobalVariables.green),
                                ),
                              ),
                            )
                          else if (_commentList.isEmpty && !_isLoadingComments)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      size: 40,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No comments yet',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: GlobalVariables.darkGrey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Be the first to comment',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _commentList.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: CommentItem(
                                    comment: _commentList[index],
                                    formatDateCallback: formatDate,
                                  ),
                                );
                              },
                            ),

                          if (_currentPage <= _totalPages &&
                              _commentList.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Center(
                                child: _isLoadingComments
                                    ? CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            GlobalVariables.green),
                                      )
                                    : TextButton(
                                        onPressed: _fetchCommentByPostId,
                                        style: TextButton.styleFrom(
                                          foregroundColor: GlobalVariables.green,
                                        ),
                                        child: Text(
                                          'Load more comments',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            InputComment(
              key: ValueKey(_isCommentLoading),
              controller: _commentController,
              isLoading: _isCommentLoading,
              onSubmit: _submitComment,
              onMediaSelected: _onMediaSelected,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel(int imageCount) {
    return Stack(
      children: [
        CarouselSlider.builder(
          itemCount: imageCount,
          options: CarouselOptions(
            viewportFraction: 1.0,
            enableInfiniteScroll: imageCount > 1,
            height: 300,
            enlargeCenterPage: false,
            onPageChanged: (index, reason) => setState(() {
              _activeIndex = index;
            }),
          ),
          itemBuilder: (context, index, realIndex) {
            final resource = _post!.resources[index];
            final isVideo = PostService.isVideoUrl(resource.url);

            return GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(
                  FullScreenMediaView.routeName,
                  arguments: {
                    'resources': _post!.resources,
                    'initialIndex': index,
                    'postTitle': _post!.title,
                  },
                );
              },
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

        if (imageCount > 1) ...[
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                int newIndex =
                    _activeIndex > 0 ? _activeIndex - 1 : imageCount - 1;
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

          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                int newIndex =
                    _activeIndex < imageCount - 1 ? _activeIndex + 1 : 0;
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
        ],

        if (imageCount > 1)
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
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
                  isDestructive: true, // FIXED: Add destructive styling
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
}