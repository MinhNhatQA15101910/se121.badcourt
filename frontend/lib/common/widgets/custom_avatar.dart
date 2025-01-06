import 'package:flutter/material.dart';
import 'package:frontend/features/message/pages/message_detail_screen.dart';

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

  void _navigateToDetailMessageScreen(BuildContext context, String userId) {
    Navigator.of(context).pushNamed(
      MessageDetailScreen.routeName,
      arguments: userId,
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Chat with User'),
              onTap: () {
                _navigateToDetailMessageScreen(context, userId);
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('View Profile'),
              onTap: () {},
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMenu(context),
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
