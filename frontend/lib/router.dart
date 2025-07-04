import 'package:flutter/material.dart';
import 'package:frontend/features/auth/screens/auth_options_screen.dart';
import 'package:frontend/features/auth/screens/auth_screen.dart';
import 'package:frontend/features/facility_detail/screens/facility_ratings_screen.dart';
import 'package:frontend/features/image_view/screens/full_screen_image_view.dart';
import 'package:frontend/features/intro/screens/welcome_screen.dart';
import 'package:frontend/features/manager/account/screen/manager_account_screen.dart';
import 'package:frontend/features/manager/add_facility/screens/facility_registration_screen.dart';
import 'package:frontend/features/manager/add_facility/screens/map_screen.dart';
import 'package:frontend/features/manager/intro_manager/screens/intro_manager_screen.dart';
import 'package:frontend/features/manager/manager_bottom_bar.dart';
import 'package:frontend/features/manager/statistic/screens/statistic_screen.dart';
import 'package:frontend/features/message/screens/message_detail_screen.dart';
import 'package:frontend/features/message/screens/message_screen.dart';
import 'package:frontend/features/notification/screens/notification_screen.dart';
import 'package:frontend/features/order/screens/order_detail_screen.dart';
import 'package:frontend/features/order/screens/order_screen.dart';
import 'package:frontend/features/player/checkout/screens/checkout_screen.dart';
import 'package:frontend/features/court/screens/court_screen.dart';
import 'package:frontend/features/facility_detail/screens/facility_detail_screen.dart';
import 'package:frontend/features/facility_detail/screens/player_map_screen.dart';
import 'package:frontend/features/court/screens/court_detail_screen.dart';
import 'package:frontend/features/player/favorite/screens/favorite_screen.dart';

import 'package:frontend/features/player/player_bottom_bar.dart';
import 'package:frontend/features/player/rating/screens/rating_detail_screen.dart';
import 'package:frontend/features/player/rating/screens/rating_screen.dart';
import 'package:frontend/features/player/search/screens/search_by_location_screen.dart';
import 'package:frontend/features/post/screens/create_post_screen.dart';
import 'package:frontend/common/screens/full_screen_media_view.dart';
import 'package:frontend/features/post/screens/post_detail_screen.dart';
import 'package:frontend/features/post/screens/post_screen.dart';
import 'package:frontend/features/post/screens/user_profile_screen.dart';

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
    case FavoriteScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const FavoriteScreen(),
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
    case CourtScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const CourtScreen(),
      );
    case OrderScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const OrderScreen(),
      );
    case OrderDetailScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const OrderDetailScreen(),
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
    case FacilityRegistrationScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const FacilityRegistrationScreen(),
      );
    case ManagerAccountScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const ManagerAccountScreen(),
      );
    case MapScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const MapScreen(),
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
    case CreatePostScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const CreatePostScreen(),
      );
    case FullScreenImageView.routeName:
      final args = routeSettings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => FullScreenImageView(
          imageUrls: args['imageUrls'] as List<String>,
          initialIndex: args['initialIndex'] as int,
        ),
      );
    case MessageScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const MessageScreen(),
      );
    case MessageDetailScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => MessageDetailScreen(),
      );
    case NotificationScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => NotificationScreen(),
      );
    case CourtDetailScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const CourtDetailScreen(),
      );
    case PostDetailScreen.routeName:
      final postId = routeSettings.arguments as String;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => PostDetailScreen(postId: postId),
      );
    case UserProfileScreen.routeName:
      final userId = routeSettings.arguments as String;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => UserProfileScreen(
          userId: userId,
        ),
      );
    case FullScreenMediaView.routeName:
      final args = routeSettings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => FullScreenMediaView(
          resources: args['resources'],
          initialIndex: args['initialIndex'],
        ),
      );
    case RatingScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const RatingScreen(),
      );
    case RatingDetailScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const RatingDetailScreen(),
      );
    case FacilityRatingsScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const FacilityRatingsScreen(),
      );
    case StatisticScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const StatisticScreen(),
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
