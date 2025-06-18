import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/user_dto.dart';
import 'package:frontend/providers/online_users_provider.dart';
import 'package:provider/provider.dart';

class MessageAppBar extends StatelessWidget {
  final User? otherUser;
  final bool isConnected;

  const MessageAppBar({
    Key? key,
    required this.otherUser,
    required this.isConnected,
  }) : super(key: key);

  String _getLastSeenText() {
    // Giả lập thời gian offline - trong thực tế sẽ lấy từ API
    final now = DateTime.now();
    final lastSeen = now.subtract(const Duration(hours: 2, minutes: 30));
    final difference = now.difference(lastSeen);
    

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final onlineUsersProvider = Provider.of<OnlineUsersProvider>(context);
    
    final bool isOnline = otherUser != null && onlineUsersProvider.isUserOnline(otherUser!.id);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leadingWidth: 40,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              Hero(
                tag: 'avatar-${otherUser?.id ?? "unknown"}',
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: otherUser?.photoUrl != null 
                      ? NetworkImage(otherUser!.photoUrl!) 
                      : null,
                  child: otherUser?.photoUrl == null 
                      ? Icon(Icons.person, color: Colors.grey[600], size: 24)
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isOnline ? GlobalVariables.green : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherUser?.username ?? 'Unknown User',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  isOnline ? 'Online' : _getLastSeenText(),
                  style: TextStyle(
                    color: isOnline ? GlobalVariables.green : Colors.grey[600],
                    fontSize: 12,
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
