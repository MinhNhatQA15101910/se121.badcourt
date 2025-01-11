import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';

class NotificationButton extends StatelessWidget {
  final String userId;

  const NotificationButton({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {},
      iconSize: 24,
      icon: const Icon(
        Icons.notifications_outlined,
        color: GlobalVariables.white,
      ),
    );
  }
}
