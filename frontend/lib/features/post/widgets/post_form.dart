import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_container.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/image_view/screens/full_screen_image_view.dart';
import 'package:frontend/features/post/widgets/comment.dart';
import 'package:frontend/features/post/widgets/input_comment.dart';
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
  int _activeIndex = 0;
  bool _isLiked = false;
  int _likeCount = 5;

  void _toggleLike() {
    setState(() {
      if (_isLiked) {
        _likeCount--;
      } else {
        _likeCount++;
      }
      _isLiked = !_isLiked;
    });
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
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  widget.currentPost.publisherImageUrl,
                ),
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
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            image: DecorationImage(
                              image: NetworkImage(
                                widget.currentPost.resources[index],
                              ),
                              fit: BoxFit.cover,
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
                DateFormat('MMM dd, yyyy').format(
                    DateTime.fromMillisecondsSinceEpoch(
                        widget.currentPost.createdAt)),
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
                              size: 20, // Icon size
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
                        size: 20,
                        color: GlobalVariables.darkGrey,
                      ),
                      SizedBox(width: 4),
                      _customText(
                        '4',
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
          InputCommentWidget(postId: widget.currentPost.id),
          CommentWidget(
              profileImageUrl:
                  'https://images.unsplash.com/photo-1701615004837-40d8573b6652?q=80&w=1780&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
              username: 'Mai Ling',
              commentText:
                  'Prepared by experienced English teachers, the texts, articles and conversations are brief and appropriate to your level of proficiency.',
              date: 'Aug 19, 2021',
              initialLikesCount: 6,
              commentsCount: 3),
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
