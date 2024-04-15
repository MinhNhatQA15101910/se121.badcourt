import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/player/home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User currentUser = Provider.of<UserProvider>(
      context,
      listen: false,
    ).user;

    return Scaffold(
      body: Center(
        child: Text(
          "${currentUser.username} - ${currentUser.role}",
        ),
      ),
    );
  }
}
