import 'package:flutter/material.dart';
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
        _commentController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 8),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _createComment,
            child: Icon(
              Icons.send_rounded,
              color: GlobalVariables.green,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}
