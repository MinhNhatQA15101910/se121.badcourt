import 'package:flutter/material.dart';
import 'package:frontend/features/auth/screens/auth_screen.dart';
import 'package:frontend/features/intro/screens/welcome_screen.dart';
import 'package:frontend/features/manager/add_facility/screens/facility_info_screen.dart';
import 'package:frontend/features/manager/add_facility/screens/map_screen.dart';
import 'package:frontend/features/manager/booking_details_manager/screens/booking_detail_manager_screen.dart';
import 'package:frontend/features/manager/court_management/screen/court_management_detail_screen.dart';
import 'package:frontend/features/manager/datetime_management/screens/datetime_management_screen.dart';
import 'package:frontend/features/manager/manager_bottom_bar.dart';
import 'package:frontend/features/player/booking_details/screens/booking_detail_screen.dart';
import 'package:frontend/features/player/booking_management/screens/booking_management_screen.dart';
import 'package:frontend/features/player/facility_detail/screens/court_detail_screen.dart';
import 'package:frontend/features/player/facility_detail/screens/facility_detail_screen.dart';
import 'package:frontend/features/player/player_bottom_bar.dart';
import 'package:frontend/features/player/search/screens/search_by_location_screen.dart';

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
    case SearchByLocationScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const SearchByLocationScreen(),
      );
    case FacilityDetailScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const FacilityDetailScreen(),
      );
    case CourtDetailScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const CourtDetailScreen(),
      );
    case BookingManagementScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const BookingManagementScreen(),
      );
    case BookingDetailScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const BookingDetailScreen(),
      );
    case ManagerBottomBar.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const ManagerBottomBar(),
      );
    case FacilityInfo.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const FacilityInfo(),
      );
    case MapScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const MapScreen(),
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
    case BookingDetailManagerScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const BookingDetailManagerScreen(),
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
