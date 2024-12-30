import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/auth/screens/auth_options_screen.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/intro/screens/intro_screen.dart';
import 'package:frontend/features/manager/intro_manager/screens/intro_manager_screen.dart';
import 'package:frontend/features/player/player_bottom_bar.dart';
import 'package:frontend/features/post/screens/create_post_screen.dart';
import 'package:frontend/features/post/screens/post_screen.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
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

class _MyAppState extends State<MyApp> {
  final _authService = AuthService();

  bool _isFirstLaunch = false;

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

  @override
  void initState() {
    super.initState();
    getFirstLaunch();
    _authService.getUserData(context);
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
        home: AuthOptionsScreen()
        // home: _isFirstLaunch
        //     ? IntroScreen()
        //     : Provider.of<UserProvider>(context).user.token.isNotEmpty
        //         ? Provider.of<UserProvider>(context).user.role == 'manager'
        //             ? IntroManagerScreen()
        //             : PlayerBottomBar()
        //         : AuthOptionsScreen(),
        );
  }
}
