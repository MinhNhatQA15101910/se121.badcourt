import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/common/services/presence_service_hub.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/auth/screens/auth_options_screen.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/manager/add_facility/providers/address_provider.dart';
import 'package:frontend/features/manager/add_facility/providers/new_facility_provider.dart';
import 'package:frontend/features/manager/manager_bottom_bar.dart';
import 'package:frontend/features/player/player_bottom_bar.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/checkout_provider.dart';
import 'package:frontend/providers/filter_provider.dart';
import 'package:frontend/providers/group_provider.dart';
import 'package:frontend/providers/manager/current_facility_provider.dart';
import 'package:frontend/providers/message_hub_provider.dart';
import 'package:frontend/providers/online_users_provider.dart';
import 'package:frontend/providers/sort_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/router.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Danh sách providers
List<SingleChildWidget> providers = [
  ChangeNotifierProvider(
    create: (context) => AuthProvider(),
  ),
  ChangeNotifierProvider(
    create: (context) => UserProvider(),
  ),
  ChangeNotifierProvider(
    create: (context) => FilterProvider(),
  ),
  ChangeNotifierProvider(
    create: (context) => SortProvider(),
  ),
  ChangeNotifierProvider(
    create: (context) => CheckoutProvider(),
  ),
  ChangeNotifierProvider(
    create: (context) => NewFacilityProvider(),
  ),
  ChangeNotifierProvider(
    create: (context) => CurrentFacilityProvider(),
  ),
  ChangeNotifierProvider(
    create: (context) => AddressProvider(),
  ),
  ChangeNotifierProvider(create: (context) => GroupProvider()),
  ChangeNotifierProvider(create: (context) => MessageHubProvider()),
  ChangeNotifierProvider(create: (context) => OnlineUsersProvider()),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers, // Sửa lỗi thiếu dấu phẩy
      child: const MyAppContent(),
    );
  }
}

class MyAppContent extends StatefulWidget {
  const MyAppContent({super.key});

  @override
  State<MyAppContent> createState() => _MyAppContentState();
}

class _MyAppContentState extends State<MyAppContent>
    with WidgetsBindingObserver {
  final _authService = AuthService();
  final _signalRService = PresenceService();
  bool _isFirstLaunch = true;

  void getFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstLaunch = prefs.getBool('is-first-launch');

    if (isFirstLaunch == null || isFirstLaunch) {
      setState(() {
        _isFirstLaunch = true;
      });
    } else {
      setState(() {
        _isFirstLaunch = false;
      });
    }
  }

  void _initializeSignalRListeners() {
    // Set up SignalR event listeners
    _signalRService.onUserOnline = (userId) {
      if (mounted) {
        print('User $userId came online');
      }
    };

    _signalRService.onUserOffline = (userId) {
      if (mounted) {
        print('User $userId went offline');
      }
    };

    _signalRService.onOnlineUsersReceived = (users) {
      if (mounted) {
        print('Online users: $users');
      }
    };
  }

  // Method để connect SignalR khi có token
  Future<void> connectSignalRWithToken(String token) async {
    try {
      if (token.isNotEmpty && !_signalRService.isConnected) {
        print('Connecting to SignalR with token...');
        await _signalRService.startConnection(token);
        print('SignalR connected successfully');
      }
    } catch (e) {
      print('Error connecting to SignalR: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getFirstLaunch();
    _initializeSignalRListeners();

    // Load user data sau khi widget đã được build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authService.getUserData(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _signalRService.stopConnection();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    bool isLoggedIn = userProvider.user.token.isNotEmpty;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (isLoggedIn) {
          if (_signalRService.isConnected) {
            print('App going to background - disconnecting PresenceHub');
            _signalRService.stopConnection();
          }
          if (groupProvider.isConnected) {
            print('App going to background - disconnecting GroupHub');
            groupProvider.disconnectGroupHub();
          }
        }
        break;

      case AppLifecycleState.resumed:
        if (isLoggedIn) {
          if (!_signalRService.isConnected) {
            print('App resumed - reconnecting PresenceHub');
            connectSignalRWithToken(userProvider.user.token);
          }
          if (!groupProvider.isConnected) {
            print('App resumed - reconnecting GroupHub');
            groupProvider.initializeGroupHub(
              userProvider.user.token,
            );
          }
        }
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Widget _getHomeScreen() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.user.token.isNotEmpty) {
          // User đã đăng nhập - connect SignalR nếu chưa connect
          WidgetsBinding.instance.addPostFrameCallback((_) {
            connectSignalRWithToken(userProvider.user.token);

            // Kết nối GroupHub
            final groupProvider =
                Provider.of<GroupProvider>(context, listen: false);
            if (!groupProvider.isConnected) {
              groupProvider.initializeGroupHub(userProvider.user.token);
            }
          });

          // Phân biệt role để chuyển đến màn hình phù hợp
          if (userProvider.user.role == 'manager') {
            return const ManagerBottomBar();
          } else {
            return const PlayerBottomBar();
          }
        } else {
          return const AuthOptionsScreen();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BadCourt',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: GlobalVariables.green,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          color: GlobalVariables.green,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
      ),
      onGenerateRoute: (routeSettings) => generateRoute(routeSettings),
      home: _getHomeScreen(),
    );
  }
}
