import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/common/widgets/custom_avatar.dart';
import 'package:frontend/common/widgets/custom_container.dart';
import 'package:frontend/common/widgets/loader.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/image_view/screens/full_screen_image_view.dart';
import 'package:frontend/features/post/services/post_service.dart';
import 'package:frontend/features/post/widgets/comment.dart';
import 'package:frontend/features/post/widgets/input_comment.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/models/post.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
// Assuming this is custom

class PostFormWidget extends StatefulWidget {
  final Post currentPost;
  const PostFormWidget({
    Key? key,
    required this.currentPost,
  }) : super(key: key);

  @override
  State<PostFormWidget> createState() => _PostFormWidgetState();
}

class _PostFormWidgetState extends State<PostFormWidget> {
  final _postService = PostService();
  int _activeIndex = 0;
  bool _isLiked = false;
  bool _isLoading = false;
  int _likeCount = 0;
  int _currentPage = 1;
  int _totalPages = 1;
  List<Comment> _commentList = [];

  Future<void> _fetchCommentByPostId() async {
    if (_isLoading || (_currentPage > _totalPages)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _postService.fetchCommentsByPostId(
        context: context,
        postId: widget.currentPost.id,
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
        _isLoading = false;
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

  Future<void> _toggleLike() async {
    try {
      await _postService.toggleLike(
        context: context,
        postId: widget.currentPost.id,
      );

      setState(() {
        if (_isLiked) {
          _likeCount--;
        } else {
          _likeCount++;
        }
        _isLiked = !_isLiked;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to toggle like. Please try again.')),
      );
    }
  }

  String formatDate(int createdAt) {
    DateTime commentDate = DateTime.fromMillisecondsSinceEpoch(createdAt);
    return DateFormat('MMM dd, yyyy').format(commentDate);
  }

  @override
  void initState() {
    super.initState();
    _fetchCommentByPostId();
    _likeCount = widget.currentPost.likesCount;
  }

  @override
  Widget build(BuildContext context) {
    final imageCount = widget.currentPost.resources.length;

    return CustomContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              CustomAvatar(
                radius: 20,
                imageUrl: widget.currentPost.publisherImageUrl,
                userId: widget.currentPost.publisherId,
              ),
              const SizedBox(width: 12),
              Text(
                widget.currentPost.publisherUsername,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _customText(
            widget.currentPost.title,
            15,
            FontWeight.w700,
            GlobalVariables.blackGrey,
            10,
          ),

          const SizedBox(height: 12),

          _customText(
            widget.currentPost.description,
            14,
            FontWeight.w400,
            GlobalVariables.blackGrey,
            10,
          ),

          const SizedBox(height: 12),
          // Post image
          if (widget.currentPost.resources.isNotEmpty)
            Container(
              child: Stack(
                children: [
                  CarouselSlider.builder(
                    itemCount: imageCount,
                    options: CarouselOptions(
                      viewportFraction: 1.0,
                      enableInfiniteScroll: imageCount > 1,
                      aspectRatio: 4 / 3,
                      onPageChanged: (index, reason) => setState(() {
                        _activeIndex = index;
                      }),
                    ),
                    itemBuilder: (context, index, realIndex) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            FullScreenImageView.routeName,
                            arguments: {
                              'imageUrls': widget.currentPost.resources,
                              'initialIndex': index,
                            },
                          );
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              widget.currentPost.resources[index],
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width,
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
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        imageCount,
                        (index) {
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            width: 8, // Kích thước hình tròn
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _activeIndex == index
                                  ? GlobalVariables.green
                                  : GlobalVariables.grey,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.3), // Màu shadow
                                  blurRadius: 4, // Độ mờ
                                  offset: Offset(0, 2), // Vị trí của shadow
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _customText(
                formatDate(widget.currentPost.createdAt),
                12,
                FontWeight.w400,
                GlobalVariables.darkGrey,
                1,
              ),
              Row(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _toggleLike, // Toggle the like state when tapped
                        child: Row(
                          children: [
                            Icon(
                              _isLiked
                                  ? Icons.thumb_up_alt // Filled like icon
                                  : Icons
                                      .thumb_up_alt_outlined, // Outlined like icon
                              color: _isLiked
                                  ? GlobalVariables
                                      .green // Change color when liked
                                  : GlobalVariables
                                      .darkGrey, // Default color when not liked
                              size: 18, // Icon size
                            ),
                            const SizedBox(width: 4),
                            _customText('$_likeCount', 14, FontWeight.w500,
                                GlobalVariables.darkGrey, 1),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Comment icon and count (static)
                  Row(
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        size: 18,
                        color: GlobalVariables.darkGrey,
                      ),
                      SizedBox(width: 4),
                      _customText(
                        widget.currentPost.commentsCount.toString(),
                        14,
                        FontWeight.w500,
                        GlobalVariables.darkGrey,
                        1,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 16,
          ),
          InputCommentWidget(
              postId: widget.currentPost.id,
              onCommentCreated: _refreshComments),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _commentList.length,
            itemBuilder: (context, index) {
              final comment = _commentList[index];
              return CommentWidget(
                profileImageUrl: comment.publisherImageUrl,
                username: comment.publisherUsername,
                userId: comment.publisherId,
                commentText: comment.content,
                date: formatDate(comment.createdAt),
                initialLikesCount: 0,
                commentsCount: 0,
              );
            },
          ),
          if (_currentPage <= _totalPages)
            _isLoading
                ? const Loader()
                : GestureDetector(
                    onTap: _fetchCommentByPostId,
                    child: _customText(
                      "View more",
                      14,
                      FontWeight.w500,
                      GlobalVariables.green,
                      1,
                    ),
                  ),
        ],
      ),
    );
  }

  Widget _customText(
      String text, double size, FontWeight weight, Color color, int maxLine) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: maxLine,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: color,
        fontSize: size,
        fontWeight: weight,
      ),
    );
  }
}
