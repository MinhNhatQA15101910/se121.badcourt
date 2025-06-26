import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/notification/screens/notification_screen.dart';

class NotificationButton extends StatelessWidget {
  final String userId;

  const NotificationButton({
    Key? key,
    required this.userId,
  }) : super(key: key);

  void _navigateToNotificationScreen(BuildContext context) {
    Navigator.of(context).pushNamed(NotificationScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        _navigateToNotificationScreen(context);
      },
      iconSize: 28,
      icon: const Icon(
        Icons.notifications_outlined,
        color: GlobalVariables.white,
      ),
    );
  }
}
