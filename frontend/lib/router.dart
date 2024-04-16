import 'package:flutter/material.dart';
import 'package:frontend/features/auth/screens/auth_screen.dart';
import 'package:frontend/features/intro/screens/welcome_screen.dart';
import 'package:frontend/features/player/player_bottom_bar.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case WelcomeScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const WelcomeScreen(),
      );
    case AuthScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const AuthScreen(),
      );
    case PlayerBottomBar.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const PlayerBottomBar(),
      );
    default:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('Screen does not exist!'),
          ),
        ),
      );
  }
}
