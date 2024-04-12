import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/providers/auth_form_provider.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  static const String routeName = '/auth';
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    final authForm = context.watch<AuthFormProvider>().authForm;

    return Scaffold(
      backgroundColor: GlobalVariables.green,
      body: Center(
        child: SafeArea(
          child: authForm,
        ),
      ),
    );
  }
}
