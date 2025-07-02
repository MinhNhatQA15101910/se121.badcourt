import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/message/screens/message_detail_screen.dart';
import 'package:frontend/features/post/screens/user_profile_screen.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CustomAvatar extends StatelessWidget {
  final double radius;
  final String? imageUrl;
  final String userId;
  final String? userName;
  final String? userEmail;

  const CustomAvatar({
    Key? key,
    required this.radius,
    this.imageUrl,
    required this.userId,
    this.userName,
    this.userEmail,
  }) : super(key: key);

  void _navigateToDetailMessageScreen(BuildContext context, String userId) {
    Navigator.of(context).pushNamed(
      MessageDetailScreen.routeName,
      arguments: userId,
    );
  }

  void _navigateToUserProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(
          userId: userId,
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    if (userId != userProvider.user.id) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header with user info
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Row(
                    children: [
                      // User Avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: GlobalVariables.green.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey.shade100,
                          child: ClipOval(
                            child: imageUrl != null && imageUrl!.isNotEmpty
                                ? Image.network(
                                    imageUrl!,
                                    fit: BoxFit.cover,
                                    width: 56,
                                    height: 56,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.person,
                                        size: 32,
                                        color: GlobalVariables.green,
                                      );
                                    },
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 32,
                                    color: GlobalVariables.green,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName ?? 'User',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: GlobalVariables.darkGrey,
                              ),
                            ),
                            if (userEmail != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                userEmail!,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: GlobalVariables.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Available',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: GlobalVariables.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.grey.shade200,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // Action items
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildActionTile(
                        context: context,
                        icon: Icons.chat_bubble_outline_rounded,
                        iconColor: GlobalVariables.green,
                        iconBgColor: GlobalVariables.green.withOpacity(0.1),
                        title: 'Start Chat',
                        subtitle: 'Send a message to this user',
                        onTap: () {
                          Navigator.of(context).pop();
                          _navigateToDetailMessageScreen(context, userId);
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildActionTile(
                        context: context,
                        icon: Icons.person_outline_rounded,
                        iconColor: Colors.blue,
                        iconBgColor: Colors.blue.withOpacity(0.1),
                        title: 'View Profile',
                        subtitle: 'See posts and user information',
                        onTap: () {
                          Navigator.of(context).pop();
                          _navigateToUserProfile(context);
                        },
                      ),
                    ],
                  ),
                ),

                // Bottom padding
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: GlobalVariables.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMenu(context),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade100,
          child: ClipOval(
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    width: radius * 2,
                    height: radius * 2,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        size: radius * 1.2,
                        color: GlobalVariables.green,
                      );
                    },
                  )
                : Icon(
                    Icons.person,
                    size: radius * 1.2,
                    color: GlobalVariables.green,
                  ),
          ),
        ),
      ),
    );
  }
}
