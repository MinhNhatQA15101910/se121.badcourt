import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:frontend/common/services/presence_service_hub.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/auth/screens/auth_options_screen.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/manager/add_facility/providers/address_provider.dart';
import 'package:frontend/features/manager/add_facility/providers/new_facility_provider.dart';
import 'package:frontend/features/manager/intro_manager/screens/intro_manager_screen.dart';
import 'package:frontend/features/player/player_bottom_bar.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/checkout_provider.dart';
import 'package:frontend/providers/court_hub_provider.dart';
import 'package:frontend/providers/filter_provider.dart';
import 'package:frontend/providers/group_provider.dart';
import 'package:frontend/providers/manager/current_facility_provider.dart';
import 'package:frontend/providers/message_hub_provider.dart';
import 'package:frontend/providers/online_users_provider.dart';
import 'package:frontend/providers/player/selected_court_provider.dart';
import 'package:frontend/providers/sort_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/router.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/providers/notification_provider.dart';

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
  ChangeNotifierProvider(
    create: (context) => SelectedCourtProvider(),
  ),
  ChangeNotifierProvider(create: (context) => GroupProvider()),
  ChangeNotifierProvider(create: (context) => MessageHubProvider()),
  ChangeNotifierProvider(create: (context) => OnlineUsersProvider()),
  ChangeNotifierProvider(create: (context) => NotificationProvider()),
  ChangeNotifierProvider(create: (context) => CourtHubProvider()),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  // Khởi tạo Stripe với error handling
  await _initializeStripe();
  
  runApp(const MyApp());
}

// Tách riêng function khởi tạo Stripe
Future<void> _initializeStripe() async {
  try {
    print('🔄 Initializing Stripe...');
    
    final stripeKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'];
    
    if (stripeKey == null || stripeKey.isEmpty) {
      print('⚠️ STRIPE_PUBLISHABLE_KEY not found in .env file');
      return;
    }
    
    Stripe.publishableKey = stripeKey;
    await Stripe.instance.applySettings();
    
    print('✅ Stripe initialized successfully');
  } catch (error) {
    print('❌ Error initializing Stripe: $error');
    // App vẫn tiếp tục chạy ngay cả khi Stripe init fail
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: const MyAppContent(),
    );
  }
}

class MyAppContent extends StatefulWidget {
  const MyAppContent({super.key});

  @override
  State<MyAppContent> createState() => _MyAppContentState();
}

class _MyAppContentState extends State<MyAppContent> with WidgetsBindingObserver {
  final _authService = AuthService();
  final _signalRService = PresenceService();
  
  // Thêm các biến để quản lý trạng thái
  bool _isInitializing = true;  // Đang khởi tạo app
  bool _isLoggedIn = false;     // Trạng thái đăng nhập
  bool _isFirstLaunch = true;   // Lần đầu mở app

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeSignalRListeners();
    
    // Khởi tạo app và kiểm tra trạng thái đăng nhập
    _initializeApp();
  }

  // Method khởi tạo app - QUAN TRỌNG
  Future<void> _initializeApp() async {
    try {
      print('🚀 Initializing app...');
      
      // 1. Kiểm tra first launch
      await _checkFirstLaunch();
      
      // 2. Kiểm tra trạng thái đăng nhập đã lưu
      await _checkSavedLoginState();
      
      // 3. Nếu có thông tin đăng nhập, thử tự động đăng nhập
      if (_isLoggedIn) {
        await _attemptAutoLogin();
      } else {
        setState(() {
          _isInitializing = false;
        });
      }
      
      // 4. Setup callbacks sau khi có context
      _setupGroupProviderCallbacks();
      
    } catch (error) {
      print('❌ Error initializing app: $error');
      setState(() {
        _isLoggedIn = false;
        _isInitializing = false;
      });
    }
  }

  // Kiểm tra first launch
  Future<void> _checkFirstLaunch() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? isFirstLaunch = prefs.getBool('is-first-launch');
      
      setState(() {
        _isFirstLaunch = isFirstLaunch ?? true;
      });
      
      print('📱 Is first launch: $_isFirstLaunch');
    } catch (error) {
      print('❌ Error checking first launch: $error');
    }
  }

  // Kiểm tra trạng thái đăng nhập đã lưu
  Future<void> _checkSavedLoginState() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      String? savedToken = prefs.getString('Authorization');
      bool? rememberLogin = prefs.getBool('remember-login');
      bool? isLoggedIn = prefs.getBool('is-logged-in');
      
      print('💾 Saved token exists: ${savedToken != null && savedToken.isNotEmpty}');
      print('💾 Remember login: ${rememberLogin ?? false}');
      print('💾 Is logged in: ${isLoggedIn ?? false}');
      
      // Chỉ coi như đã đăng nhập nếu có đầy đủ thông tin
      bool hasValidSavedState = (savedToken != null && savedToken.isNotEmpty) &&
                               (rememberLogin ?? false) &&
                               (isLoggedIn ?? false);
      
      setState(() {
        _isLoggedIn = hasValidSavedState;
      });
      
    } catch (error) {
      print('❌ Error checking saved login state: $error');
      setState(() {
        _isLoggedIn = false;
      });
    }
  }

  // Thử tự động đăng nhập
  Future<void> _attemptAutoLogin() async {
    try {
      print('🔄 Attempting auto login...');
      
      // Gọi getUserData và đợi kết quả
      await _authService.getUserData(context);
      
      // Kiểm tra xem user data có được load thành công không
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      bool loginSuccessful = userProvider.user.token.isNotEmpty;
      
      print('✅ Auto login successful: $loginSuccessful');
      
      if (loginSuccessful) {
        // Đánh dấu không còn first launch nếu đăng nhập thành công
        if (_isFirstLaunch) {
          await _markNotFirstLaunch();
        }
        
        // Connect SignalR services
        await _connectSignalRServices(userProvider.user.token);
      } else {
        // Auto login thất bại, clear saved data
        await _clearLoginData();
      }
      
      setState(() {
        _isLoggedIn = loginSuccessful;
        _isInitializing = false;
      });
      
    } catch (error) {
      print('❌ Auto login failed: $error');
      await _clearLoginData();
      setState(() {
        _isLoggedIn = false;
        _isInitializing = false;
      });
    }
  }

  // Connect SignalR services
  Future<void> _connectSignalRServices(String token) async {
    try {
      print('🔗 Connecting SignalR services...');
      await connectSignalRWithToken(token);
      
      // Connect GroupHub
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      if (!groupProvider.isConnected) {
        await groupProvider.initializeGroupHub(token);
        _setupGroupProviderCallbacks();
      }
      
      // Connect NotificationHub
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      if (!notificationProvider.isConnected) {
        await notificationProvider.initializeNotificationHub(token);
      }
      
      print('✅ SignalR services connected');
    } catch (error) {
      print('❌ Error connecting SignalR services: $error');
    }
  }

  // Đánh dấu không còn first launch
  Future<void> _markNotFirstLaunch() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is-first-launch', false);
      setState(() {
        _isFirstLaunch = false;
      });
      print('✅ Marked not first launch');
    } catch (error) {
      print('❌ Error marking not first launch: $error');
    }
  }

  // Clear login data
  Future<void> _clearLoginData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('Authorization');
      await prefs.remove('Authorization');
      await prefs.setBool('is-logged-in', false);
      await prefs.setBool('remember-login', false);
      print('🗑️ Login data cleared');
    } catch (error) {
      print('❌ Error clearing login data: $error');
    }
  }

  void _initializeSignalRListeners() {
    _signalRService.onUserOnline = (userId) {
      if (mounted) {
        print('User $userId came online');
        final onlineUsersProvider = Provider.of<OnlineUsersProvider>(context, listen: false);
        onlineUsersProvider.addOnlineUser(userId);
      }
    };

    _signalRService.onUserOffline = (userId) {
      if (mounted) {
        print('User $userId went offline');
        final onlineUsersProvider = Provider.of<OnlineUsersProvider>(context, listen: false);
        onlineUsersProvider.removeOnlineUser(userId);
      }
    };

    _signalRService.onOnlineUsersReceived = (users) {
      if (mounted) {
        print('Online users: $users');
        final onlineUsersProvider = Provider.of<OnlineUsersProvider>(context, listen: false);
        for (final user in users) {
          onlineUsersProvider.addOnlineUser(user);
        }
      }
    };
  }

  void _setupGroupProviderCallbacks() {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    groupProvider.onNewMessage = (message) {
      if (mounted) {
        print('[Main] New message received: ${message.content} from ${message.senderUsername}');
        _showNewMessageNotification(message.content, message.senderUsername ?? 'Unknown');
      }
    };

    if (userProvider.user.id.isNotEmpty) {
      groupProvider.setCurrentUserId(userProvider.user.id);
    }
  }

  void _showNewMessageNotification(String content, String senderName) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.message, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'New message from $senderName',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: GlobalVariables.green,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/messageScreen');
            },
          ),
        ),
      );
    }
  }

  Future<void> connectSignalRWithToken(String token) async {
    try {
      if (token.isNotEmpty && !_signalRService.isConnected) {
        print('Connecting to SignalR with token...');
        print('SignalR connected successfully');
        if (mounted) {
          _setupGroupProviderCallbacks();
        }
      }
    } catch (e) {
      print('Error connecting to SignalR: $e');
    }
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
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
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
          if (notificationProvider.isConnected) {
            print('App going to background - disconnecting NotificationHub');
            notificationProvider.disconnect();
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
            groupProvider.initializeGroupHub(userProvider.user.token).then((_) {
              if (mounted) {
                _setupGroupProviderCallbacks();
              }
            });
          }
          if (!notificationProvider.isConnected) {
            print('App resumed - reconnecting NotificationHub');
            notificationProvider.initializeNotificationHub(userProvider.user.token);
          }
        }
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Widget _getHomeScreen() {
    // Hiển thị loading trong khi đang khởi tạo
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: GlobalVariables.green,
              ),
              SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        bool isUserLoggedIn = userProvider.user.token.isNotEmpty;
        
        print('🏠 Building home screen - User logged in: $isUserLoggedIn');
        
        if (isUserLoggedIn) {
          // Phân biệt role để chuyển đến màn hình phù hợp
          if (userProvider.user.role == 'Manager') {
            return const IntroManagerScreen();
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
