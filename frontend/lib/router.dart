import 'package:flutter/material.dart';
import 'package:frontend/features/auth/screens/auth_options_screen.dart';
import 'package:frontend/features/auth/screens/auth_screen.dart';
import 'package:frontend/features/intro/screens/welcome_screen.dart';
import 'package:frontend/features/manager/account/screen/manager_account_screen.dart';
import 'package:frontend/features/manager/add_facility/screens/contracts_screen.dart';
import 'package:frontend/features/manager/add_facility/screens/facility_info_screen.dart';
import 'package:frontend/features/manager/add_facility/screens/manager_info_screen.dart';
import 'package:frontend/features/manager/add_facility/screens/map_screen.dart';
import 'package:frontend/features/manager/booking_details_manager/screens/booking_detail_manager_screen.dart';
import 'package:frontend/features/manager/court_management/screen/court_management_detail_screen.dart';
import 'package:frontend/features/manager/datetime_management/screens/datetime_management_screen.dart';
import 'package:frontend/features/manager/intro_manager/screens/intro_manager_screen.dart';
import 'package:frontend/features/manager/manager_bottom_bar.dart';
import 'package:frontend/features/player/booking_details/screens/booking_detail_screen.dart';
import 'package:frontend/features/player/booking_management/screens/booking_management_screen.dart';
import 'package:frontend/features/player/checkout/screens/checkout_screen.dart';
import 'package:frontend/features/player/facility_detail/screens/court_detail_screen.dart';
import 'package:frontend/features/player/facility_detail/screens/facility_detail_screen.dart';
import 'package:frontend/features/player/facility_detail/screens/player_map_screen.dart';

import 'package:frontend/features/player/player_bottom_bar.dart';
import 'package:frontend/features/player/search/screens/search_by_location_screen.dart';
import 'package:frontend/features/post/screens/post_screen.dart';

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
        builder: (_) => AuthScreen(),
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
    case IntroManagerScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const IntroManagerScreen(),
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
    case ManagerInfoScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const ManagerInfoScreen(),
      );
    case ManagerAccountScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const ManagerAccountScreen(),
      );
    case ContractScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const ContractScreen(),
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
    case CheckoutScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const CheckoutScreen(),
      );
    case PlayerMapScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const PlayerMapScreen(),
      );
    case PostScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const PostScreen(),
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
