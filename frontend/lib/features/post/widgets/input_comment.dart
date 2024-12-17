import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/post/services/post_service.dart';

class InputCommentWidget extends StatefulWidget {
  final String postId;

  const InputCommentWidget({
    Key? key,
    required this.postId,
  }) : super(key: key);

  @override
  State<InputCommentWidget> createState() => _InputCommentWidgetState();
}

class _InputCommentWidgetState extends State<InputCommentWidget> {
  final TextEditingController _commentController = TextEditingController();
  final _postService = PostService();
  bool _isLoading = false;

  Future<void> _createComment() async {
    if (_commentController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _postService.createComment(
        context,
        widget.postId,
        _commentController.text,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.green,
                width: 1.0,
              ),
            ),
            child: const CircleAvatar(
              backgroundImage: NetworkImage(
                'https://plus.unsplash.com/premium_photo-1683121366070-5ceb7e007a97?q=80&w=1770&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
              ),
              radius: 25,
            ),
          ),
          const SizedBox(width: 8), // Spacing between avatar and input
          Expanded(
            child: TextField(
              controller: _commentController,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: GlobalVariables.blackGrey,
              ),
              maxLines: null,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Leave a comment',
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: GlobalVariables.darkGrey,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: GlobalVariables.darkGrey,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: GlobalVariables.green,
                    width: 1,
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _createComment,
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              child: GestureDetector(
                onTap: _createComment,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: GlobalVariables.green,
                  ),
                  child: Icon(
                    Icons.send_rounded,
                    color: GlobalVariables.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
