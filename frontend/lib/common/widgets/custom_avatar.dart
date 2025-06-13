import 'package:flutter/material.dart';
import 'package:frontend/features/message/pages/message_detail_screen.dart';
import 'package:frontend/providers/group_provider.dart';
import 'package:frontend/providers/message_hub_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:provider/provider.dart';

class CustomAvatar extends StatelessWidget {
  final double radius;
  final String? imageUrl;
  final String userId;

  const CustomAvatar({
    Key? key,
    required this.radius,
    this.imageUrl,
    required this.userId,
  }) : super(key: key);

  Future<void> _createGroupAndNavigate(
      BuildContext context, String userId) async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final messageHubProvider =
        Provider.of<MessageHubProvider>(context, listen: false);

    try {
      // Connect to MessageHub for this specific user to start conversation
      await messageHubProvider.connectToUser(
        context,
        userId,
      );

      if (messageHubProvider.isConnectedToUser(userId)) {
        // Refresh groups in GroupProvider to include any new groups
        await groupProvider.requestGroups();

        // Navigate to message detail screen
        Navigator.of(context).pushNamed(
          MessageDetailScreen.routeName,
          arguments: userId,
        );
      } else {
        throw Exception('Failed to connect to user');
      }
    } catch (e) {
      // Hide loading indicator if still showing
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start chat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToDetailMessageScreen(BuildContext context, String userId) {
    _createGroupAndNavigate(context, userId);
  }

  void _showMenu(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    if (userId != userProvider.user.id) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with user info
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey.shade200,
                        child: ClipOval(
                          child: imageUrl != null && imageUrl!.isNotEmpty
                              ? Image.network(
                                  imageUrl!,
                                  fit: BoxFit.cover,
                                  width: 50,
                                  height: 50,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      size: 30,
                                      color: Colors.grey,
                                    );
                                  },
                                )
                              : Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Colors.grey,
                                ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'User Actions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Choose an action',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),

                // Action items
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.blue,
                    ),
                  ),
                  title: const Text('Start Chat'),
                  subtitle: const Text('Create a new conversation'),
                  onTap: () {
                    Navigator.of(context).pop(); // Close bottom sheet
                    _navigateToDetailMessageScreen(context, userId);
                  },
                ),

                // Show connection status if already connected
                Consumer<MessageHubProvider>(
                  builder: (context, messageHubProvider, _) {
                    final isConnected =
                        messageHubProvider.isConnectedToUser(userId);
                    if (isConnected) {
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.chat,
                            color: Colors.orange,
                          ),
                        ),
                        title: const Text('Continue Chat'),
                        subtitle: const Text('Already connected'),
                        onTap: () {
                          Navigator.of(context).pop(); // Close bottom sheet
                          Navigator.of(context).pushNamed(
                            MessageDetailScreen.routeName,
                            arguments: userId,
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color: Colors.green,
                    ),
                  ),
                  title: const Text('View Profile'),
                  subtitle: const Text('See user details'),
                  onTap: () {
                    Navigator.of(context).pop(); // Close bottom sheet
                    // TODO: Navigate to user profile screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile view coming soon!'),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),
              ],
            ),
          );
        },
      );
    }
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
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade200,
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
                        size: radius * 1.5,
                        color: Colors.grey,
                      );
                    },
                  )
                : Icon(
                    Icons.person,
                    size: radius * 1.5,
                    color: Colors.grey,
                  ),
          ),
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          '$title Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
