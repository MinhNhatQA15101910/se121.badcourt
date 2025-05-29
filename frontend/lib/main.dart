import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/common/services/presence_service_hub.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/auth/screens/auth_options_screen.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: providers,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
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
    
    // Chỉ load user data, không auto-connect SignalR
    _authService.getUserData(context);
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
    bool isLoggedIn = userProvider.user.token.isNotEmpty;
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (isLoggedIn && _signalRService.isConnected) {
          print('App going to background - disconnecting SignalR');
          _signalRService.stopConnection();
        }
        break;
        
      case AppLifecycleState.resumed:
        if (isLoggedIn && !_signalRService.isConnected) {
          print('App resumed - reconnecting SignalR');
          connectSignalRWithToken(userProvider.user.token);
        }
        break;
        
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Widget _getHomeScreen() {
    final userProvider = Provider.of<UserProvider>(context);
    
    if (userProvider.user.token.isNotEmpty) {
      // User đã đăng nhập - connect SignalR nếu chưa connect
      WidgetsBinding.instance.addPostFrameCallback((_) {
        connectSignalRWithToken(userProvider.user.token);
      });
      
      if (userProvider.user.role == 'manager') {
        return AuthOptionsScreen(); // Replace with IntroManagerScreen
      } else {
        return AuthOptionsScreen(); // Replace with PlayerBottomBar
      }
    } else {
      return AuthOptionsScreen();
    }
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