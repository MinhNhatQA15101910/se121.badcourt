import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/message/pages/message_screen.dart';

class MessageButton extends StatelessWidget {
  final String userId;

  const MessageButton({
    Key? key,
    required this.userId,
  }) : super(key: key);

  void _navigateToMessageScreen(BuildContext context) {
    Navigator.of(context).pushNamed(
      MessageScreen.routeName,
      arguments: userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        _navigateToMessageScreen(context);
      },
      iconSize: 24,
      icon: const Icon(
        Icons.message_outlined,
        color: GlobalVariables.white,
      ),
    );
  }
}
