import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/user_dto.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageAppBar extends StatelessWidget {
  final UserDto? otherUser;
  final bool isConnected;

  const MessageAppBar({
    Key? key,
    this.otherUser,
    required this.isConnected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: GlobalVariables.green,
      title: Row(
        children: [
          if (otherUser != null)
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: GlobalVariables.lightGreen,
                  backgroundImage: otherUser?.photoUrl != null && otherUser!.photoUrl!.isNotEmpty
                      ? NetworkImage(otherUser!.photoUrl!)
                      : null,
                  child: otherUser?.photoUrl == null || otherUser!.photoUrl!.isEmpty
                      ? Text(
                          otherUser?.username.substring(0, 1).toUpperCase() ?? '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  otherUser?.username ?? 'Chat',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          else
            Text(
              'Message',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.none,
                color: GlobalVariables.white,
              ),
            ),
          const Spacer(),
          // Connection status indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isConnected ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isConnected ? Icons.circle : Icons.circle_outlined,
                  color: Colors.white,
                  size: 12,
                ),
                SizedBox(width: 4),
                Text(
                  isConnected ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
