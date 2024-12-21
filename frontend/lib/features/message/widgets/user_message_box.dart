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

  const UserMessageBox({
    Key? key,
    required this.userName,
    required this.lastMessage,
    required this.timestamp,
    required this.userImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void _navigateToMessageScreen() {
      Navigator.of(context).pushNamed(MessageDetailScreen.routeName);
    }

    return GestureDetector(
      onTap: _navigateToMessageScreen,
      child: CustomContainer(
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
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
                      _customText(
                        userName,
                        16,
                        FontWeight.w600,
                        GlobalVariables.blackGrey,
                        1,
                      ),
                      _customText(
                        "  •  ",
                        16,
                        FontWeight.w600,
                        GlobalVariables.blackGrey,
                        1,
                      ),
                      _customText(
                        timestamp,
                        14,
                        FontWeight.w500,
                        GlobalVariables.blackGrey,
                        1,
                      ),
                    ],
                  ),
                  _customText(
                    "Sân cầu lông Nhật Duy",
                    14,
                    FontWeight.w500,
                    GlobalVariables.darkGrey,
                    1,
                  ),
                  Text(
                    lastMessage,
                    style: const TextStyle(color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(8), // Đảm bảo bán kính bo tròn ở đây
                child: Image.network(
                  'https://via.placeholder.com/150',
                  fit: BoxFit.cover,
                ),
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
