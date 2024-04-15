import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/intro/screens/intro_screen.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/providers/auth_form_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/router.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthFormProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const IntroScreen(),
    );
  }
}
