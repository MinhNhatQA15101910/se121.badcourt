import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/features/auth/screens/auth_options_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountService {
  void logOut(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('x-auth-token', '');

      GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
      );
      await googleSignIn.signOut();

      Navigator.pushNamedAndRemoveUntil(
        context,
        AuthOptionsScreen.routeName,
        (route) => false,
      );

      IconSnackBar.show(
        context,
        label: 'Log out successfully!',
        snackBarType: SnackBarType.success,
      );
    } catch (error) {
      IconSnackBar.show(
        context,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );
    }
  }
}
