import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_container.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/message/pages/message_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class UserMessageBox extends StatelessWidget {
  final String userName;
  final String lastMessage;
  final String timestamp;
  final String userImageUrl;
  final String role;
  final String userId; // Thay vì roomId, truyền userId

  const UserMessageBox({
    Key? key,
    required this.userName,
    required this.lastMessage,
    required this.timestamp,
    required this.userImageUrl,
    required this.role,
    required this.userId, // Thay đổi từ roomId sang userId
  }) : super(key: key);

  void _navigateToMessageScreen(BuildContext context, String userId) {
    Navigator.of(context).pushNamed(
      MessageDetailScreen.routeName,
      arguments: userId, // Truyền userId thay vì roomId
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToMessageScreen(context, userId),
      child: CustomContainer(
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(userImageUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _customText(
                          userName,
                          14,
                          FontWeight.w600,
                          GlobalVariables.blackGrey,
                          1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _customText(
                        role,
                        12,
                        FontWeight.w500,
                        GlobalVariables.green,
                        1,
                      ),
                    ],
                  ),
                  _customText(
                    timestamp,
                    10,
                    FontWeight.w400,
                    GlobalVariables.darkGrey,
                    1,
                  ),
                  _customText(
                    lastMessage,
                    12,
                    FontWeight.w400,
                    GlobalVariables.darkGrey,
                    1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customText(
      String text, double size, FontWeight weight, Color color, int maxLines) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: color,
        fontSize: size,
        fontWeight: weight,
      ),
    );
  }
}
