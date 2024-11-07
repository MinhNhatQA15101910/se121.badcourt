import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_container.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/post/widgets/comment.dart';
import 'package:frontend/features/post/widgets/input_comment.dart';
import 'package:google_fonts/google_fonts.dart'; // Assuming this is custom

class PostFormWidget extends StatefulWidget {
  const PostFormWidget({
    super.key,
  });

  @override
  State<PostFormWidget> createState() => _PostFormWidgetState();
}

class _PostFormWidgetState extends State<PostFormWidget> {
  bool _isLiked = false; // Tracks whether the post is liked or not
  int _likeCount = 5; // Initial like count, you can adjust this dynamically

  void _toggleLike() {
    setState(() {
      if (_isLiked) {
        _likeCount--;
      } else {
        _likeCount++;
      }
      _isLiked = !_isLiked; // Toggle the liked state
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User profile info (avatar + name in a single row)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1633332755192-727a05c4013d?q=80&w=1780&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D', // Replace with actual profile image URL
                ),
              ),
              const SizedBox(width: 12), // Space between avatar and name
              // Name in the same row as avatar
              Text(
                'Albert Flores', // Replace with dynamic username
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Space between row and post text

          // Post text
          Text(
            'In mauris porttitor tincidunt mauris massa sit lorem sed scelerisque. Fringilla pharetra vel massa enim sollicitudin cras.',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),

          const SizedBox(height: 12), // Space between text and image

          // Post image
          Container(
            height: 200, // Height of the image
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1617696618050-b0fef0c666af?q=80&w=1770&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D', // Replace with post image URL
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Aug 19, 2021', // Replace with dynamic date
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
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
                                GlobalVariables.darkGrey),
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
                          '4', 14, FontWeight.w500, GlobalVariables.darkGrey),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 16,
          ),
          InputCommentWidget(),
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

  Widget _customText(String text, double size, FontWeight weight, Color color) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: color,
        fontSize: size,
        fontWeight: weight,
      ),
    );
  }
}
