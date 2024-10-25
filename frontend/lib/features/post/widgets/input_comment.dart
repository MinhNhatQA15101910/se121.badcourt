import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';

class InputCommentWidget extends StatefulWidget {
  const InputCommentWidget({Key? key}) : super(key: key);

  @override
  State<InputCommentWidget> createState() => _InputCommentWidgetState();
}

class _InputCommentWidgetState extends State<InputCommentWidget> {
  // TextEditingController to manage the comment input
  final TextEditingController _commentController = TextEditingController();

  // Method to handle comment submission
  void _submitComment() {
    String comment = _commentController.text.trim();
    if (comment.isNotEmpty) {
      // Handle the comment submission logic (e.g., send to backend or update UI)
      print('Comment submitted: $comment');

      // Clear the input after submission
      _commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar on the left
          Container(
            margin: EdgeInsets.only(
              top: 2,
            ),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.green,
                width: 1.0,
              ),
            ),
            child: CircleAvatar(
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
                    color:
                        GlobalVariables.darkGrey, // Green border when unfocused
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: GlobalVariables.green, // Green border when focused
                    width: 1,
                  ),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Container(
            margin: EdgeInsets.only(
              top: 4,
            ),
            child: GestureDetector(
              onTap: () {}, // Toggle the like state when tapped
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: GlobalVariables.green,
                ),
                child: Icon(
                  color: GlobalVariables.white,
                  Icons.send_rounded,
                  size: 20, // Icon size
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose(); // Clean up the controller
    super.dispose();
  }
}
