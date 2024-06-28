import 'package:flutter/material.dart';
import 'package:frontend/features/auth/screens/auth_options_screen.dart';
import 'package:frontend/features/auth/screens/auth_screen.dart';
import 'package:frontend/features/intro/screens/welcome_screen.dart';
import 'package:frontend/features/manager/court_management/screen/court_management_detail_screen.dart';
import 'package:frontend/features/manager/datetime_management/screens/datetime_management_screen.dart';
import 'package:frontend/features/manager/manager_bottom_bar.dart';
import 'package:frontend/features/player/player_bottom_bar.dart';
import 'package:frontend/features/player/search/screens/search_by_location_screen.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case WelcomeScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const WelcomeScreen(),
      );
    case AuthOptionsScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const AuthOptionsScreen(),
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
    case SearchByLocationScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const SearchByLocationScreen(),
      );
    case ManagerBottomBar.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const ManagerBottomBar(),
      );
    case DatetimeManagementScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const DatetimeManagementScreen(),
      );
    case CourtManagementDetailScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const CourtManagementDetailScreen(),
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
