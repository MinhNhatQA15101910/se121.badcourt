import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_avatar.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/image_view/screens/full_screen_image_view.dart';
import 'package:frontend/features/post/services/post_service.dart';
import 'package:frontend/models/comment.dart';
import 'package:google_fonts/google_fonts.dart';

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

  @override
  void initState() {
    super.initState();
    _isLiked = widget.comment.isLiked;
    _likesCount = widget.comment.likesCount;
  }

  Future<void> _toggleLike() async {
    if (_isLikeLoading) return;

    setState(() {
      _isLikeLoading = true;
    });

    // Optimistic update
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
        // Revert changes if API call fails
        setState(() {
          _isLiked = previousLikedState;
          _likesCount = previousLikeCount;
        });
      }
    } catch (error) {
      // Revert changes if API call fails
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
    final hasImages = widget.comment.resources.isNotEmpty;
    
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
              // Avatar
              CustomAvatar(
                radius: 16,
                imageUrl: widget.comment.publisherImageUrl,
                userId: widget.comment.publisherId,
              ),
              const SizedBox(width: 8),
              
              // Username and date
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
              
              // Like button moved to top right
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
          
          // Comment images (if any)
          if (hasImages)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildCommentImages(context, widget.comment.resources),
            ),
        ],
      ),
    );
  }
  
  Widget _buildCommentImages(BuildContext context, List<dynamic> resources) {
    final imageUrls = resources
        .where((resource) => resource is Map<String, dynamic> && resource['url'] != null)
        .map<String>((resource) => resource['url'] as String)
        .toList();
    
    if (imageUrls.isEmpty) return const SizedBox();
    
    if (imageUrls.length == 1) {
      return GestureDetector(
        onTap: () => _openFullScreenImage(context, imageUrls, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 1.0, // Square aspect ratio
            child: Image.network(
              imageUrls[0],
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
      );
    }
    
    // Grid layout for multiple images
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: imageUrls.length == 2 ? 2 : 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1.0, // Square aspect ratio
      ),
      itemCount: imageUrls.length > 9 ? 9 : imageUrls.length,
      itemBuilder: (context, index) {
        if (index == 8 && imageUrls.length > 9) {
          // Show "more" overlay for the last image if there are more than 9
          return GestureDetector(
            onTap: () => _openFullScreenImage(context, imageUrls, index),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrls[index],
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '+${imageUrls.length - 8}',
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
          onTap: () => _openFullScreenImage(context, imageUrls, index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrls[index],
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
  
  void _openFullScreenImage(BuildContext context, List<String> imageUrls, int initialIndex) {
    Navigator.of(context).pushNamed(
      FullScreenImageView.routeName,
      arguments: {
        'imageUrls': imageUrls,
        'initialIndex': initialIndex,
      },
    );
  }
}
