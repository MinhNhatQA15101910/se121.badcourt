import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/post/widgets/comment_child.dart';

class CommentWidget extends StatefulWidget {
  final String profileImageUrl;
  final String username;
  final String commentText;
  final String date;
  final int initialLikesCount;
  final int commentsCount;

  const CommentWidget({
    Key? key,
    required this.profileImageUrl,
    required this.username,
    required this.commentText,
    required this.date,
    required this.initialLikesCount,
    required this.commentsCount,
  }) : super(key: key);

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  bool _isLiked = false;
  int _likesCount = 0;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.initialLikesCount;
  }

  void _toggleLike() {
    setState(() {
      if (_isLiked) {
        _likesCount--;
      } else {
        _likesCount++;
      }
      _isLiked = !_isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User profile info (avatar + name + date in a row)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(widget.profileImageUrl),
              ),
              const SizedBox(width: 12), // Space between avatar and name

              // Name and date in a column
              Expanded(
                child: Text(
                  widget.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                widget.date,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          // Comment text
          Container(
            margin: EdgeInsets.only(
              left: 44,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: GlobalVariables.lightGreen, // Light green background
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.commentText,
              style: TextStyle(
                fontSize: 14,
                color: GlobalVariables.darkGrey,
              ),
            ),
          ),

          const SizedBox(height: 8), // Space between comment text and metadata

          // Post metadata (likes, comments)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: _toggleLike,
                    child: Row(
                      children: [
                        Icon(
                          _isLiked
                              ? Icons.thumb_up_alt
                              : Icons.thumb_up_alt_outlined,
                          size: 16,
                          color: _isLiked
                              ? GlobalVariables.green
                              : GlobalVariables.darkGrey,
                        ),
                        const SizedBox(width: 4),
                        Text('$_likesCount'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.comment_outlined,
                        size: 16,
                        color: GlobalVariables.darkGrey,
                      ),
                      const SizedBox(width: 4),
                      Text('${widget.commentsCount}'),
                    ],
                  ),
                ],
              ),
            ],
          ),
          CommentChild(
              profileImageUrl:
                  'https://images.unsplash.com/photo-1633332755192-727a05c4013d?q=80&w=1780&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
              username: 'Albert Flores',
              commentText:
                  'Take the multiple-choice quiz following each text, and youll get the results immediately.',
              date: 'Aug 19, 2021'),
          CommentChild(
              profileImageUrl:
                  'https://images.unsplash.com/photo-1633332755192-727a05c4013d?q=80&w=1780&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
              username: 'Albert Flores',
              commentText:
                  'Take the multiple-choice quiz following each text, and youll get the results immediately.',
              date: 'Aug 19, 2021'),
          CommentChild(
              profileImageUrl:
                  'https://images.unsplash.com/photo-1633332755192-727a05c4013d?q=80&w=1780&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
              username: 'Albert Flores',
              commentText:
                  'Take the multiple-choice quiz following each text, and youll get the results immediately.',
              date: 'Aug 19, 2021'),
        ],
      ),
    );
  }

}
