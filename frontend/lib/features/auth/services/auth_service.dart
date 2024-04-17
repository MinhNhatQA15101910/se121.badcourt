import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/error_handling.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/auth/widgets/forgot_password_form.dart';
import 'package:frontend/features/auth/widgets/pinput_form.dart';
import 'package:frontend/features/player/player_bottom_bar.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/providers/auth_form_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Sign up user
  Future<bool> signUpUser({
    required BuildContext context,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      User user = User(
        id: '',
        username: username,
        email: email,
        password: password,
        imageUrl: '',
        role: '',
        token: '',
      );

      http.Response response = await http.post(
        Uri.parse('$uri/user/signup'),
        body: user.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          IconSnackBar.show(
            context,
            label: 'Account created successfully!',
            snackBarType: SnackBarType.success,
          );
        },
      );

      if (response.statusCode != 200) {
        return false;
      }

      return true;
    } catch (error) {
      IconSnackBar.show(
        context,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );

      return false;
    }
  }

  // Log in user
  Future<bool> logInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$uri/login'),
        body: jsonEncode(
          {
            'email': email,
            'password': password,
          },
        ),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              'x-auth-token', jsonDecode(response.body)['token']);

          Provider.of<UserProvider>(context, listen: false)
              .setUser(response.body);

          Navigator.of(context).pushNamedAndRemoveUntil(
            PlayerBottomBar.routeName,
            (route) => false,
          );

          IconSnackBar.show(
            context,
            label: 'Login successfully!',
            snackBarType: SnackBarType.success,
          );
        },
      );

      if (response.statusCode != 200) {
        return false;
      }

      return true;
    } catch (error) {
      IconSnackBar.show(
        context,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );

      return false;
    }
  }

  // Log in user with google
  Future<bool> logInWithGoogle({
    required BuildContext context,
    required GoogleSignInAccount account,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$uri/login/google'),
        body: jsonEncode(
          {
            'email': account.email,
            'password': account.id,
            'username': account.displayName,
            'imageUrl': account.photoUrl,
          },
        ),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              'x-auth-token', jsonDecode(response.body)['token']);

          Provider.of<UserProvider>(context, listen: false)
              .setUser(response.body);

          Navigator.of(context).pushNamedAndRemoveUntil(
            PlayerBottomBar.routeName,
            (route) => false,
          );

          IconSnackBar.show(
            context,
            label: 'Login successfully!',
            snackBarType: SnackBarType.success,
          );
        },
      );

      if (response.statusCode != 200) {
        return false;
      }

      return true;
    } catch (error) {
      IconSnackBar.show(
        context,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );

      return false;
    }
  }

  Future<bool> validateEmail({
    required BuildContext context,
    required String email,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$uri/email-exists'),
        body: jsonEncode(
          {
            'email': email,
          },
        ),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      var isExistingEmail = jsonDecode(response.body);

      if (isExistingEmail) {
        final authFormProvider = Provider.of<AuthFormProvider>(
          context,
          listen: false,
        );

        authFormProvider.setResentEmail(
          email,
        );

        authFormProvider.setPreviousForm(
          ForgotPasswordForm(),
        );

        authFormProvider.setForm(
          PinputForm(),
        );
      } else {
        IconSnackBar.show(
          context,
          label: 'Email not found.',
          snackBarType: SnackBarType.fail,
        );
      }

      if (response.statusCode != 200) {
        return false;
      }

      return true;
    } catch (error) {
      IconSnackBar.show(
        context,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );

      return false;
    }
  }
}
