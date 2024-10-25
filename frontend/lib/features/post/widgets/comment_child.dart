import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';

class CommentChild extends StatelessWidget {
  final String profileImageUrl;
  final String username;
  final String commentText;
  final String date;

  const CommentChild({
    Key? key,
    required this.profileImageUrl,
    required this.username,
    required this.commentText,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 44),
      child: Padding(
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
                  backgroundImage: NetworkImage(profileImageUrl),
                ),
                const SizedBox(width: 12), // Space between avatar and name

                // Name and date in a column
                Expanded(
                  child: Text(
                    username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            // Comment text
            Container(
              margin: const EdgeInsets.only(
                left: 44,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: GlobalVariables.lightGreen, // Light green background
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                commentText,
                style: TextStyle(
                  fontSize: 14,
                  color: GlobalVariables.darkGrey,
                ),
              ),
            ),
          ],
        ),
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
