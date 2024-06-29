import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/error_handling.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/auth/widgets/forgot_password_form.dart';
import 'package:frontend/features/auth/widgets/login_form.dart';
import 'package:frontend/features/auth/widgets/pinput_form.dart';
import 'package:frontend/features/manager/intro_manager/screens/intro_manager_screen.dart';
import 'package:frontend/features/player/player_bottom_bar.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/providers/auth_provider.dart';
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
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    try {
      User user = User(
        id: '',
        username: username,
        email: email,
        password: password,
        imageUrl: '',
        role: authProvider.isPlayer ? 'player' : 'manager',
        token: '',
      );

      http.Response response = await http.post(
        Uri.parse('$uri/sign-up'),
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
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    try {
      http.Response response = await http.post(
        Uri.parse(
          '$uri/${authProvider.isPlayer ? 'login-as-player' : 'login-as-manager'}',
        ),
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

          userProvider.setUser(response.body);

          if (jsonDecode(response.body)['role'] == 'player') {
            Navigator.of(context).pushNamedAndRemoveUntil(
              PlayerBottomBar.routeName,
              (route) => false,
            );
          } else if (jsonDecode(response.body)['role'] == 'manager') {
            Navigator.of(context).pushNamedAndRemoveUntil(
              IntroManagerScreen.routeName,
              (route) => false,
            );
          }

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

  // Validate email
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
        final authProvider = Provider.of<AuthProvider>(
          context,
          listen: false,
        );

        authProvider.setResentEmail(
          email,
        );

        authProvider.setPreviousForm(
          ForgotPasswordForm(),
        );

        authProvider.setForm(
          PinputForm(
            isMoveBack: false,
            isValidateSignUpEmail: false,
          ),
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

  Future<bool> sendVerifyEmail({
    required BuildContext context,
    required String email,
    required String pincode,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$uri/send-email'),
        body: jsonEncode(
          {
            'email': email,
            'pincode': pincode,
          },
        ),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
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

  Future<bool> changePassword({
    required BuildContext context,
    required String email,
    required String newPassword,
  }) async {
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    try {
      http.Response response = await http.patch(
        Uri.parse('$uri/change-password'),
        body: jsonEncode(
          {
            'email': email,
            'role': authProvider.isPlayer ? 'player' : 'manager',
            'new_password': newPassword,
          },
        ),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );

          User user = userProvider.user.copyWith(
            password: jsonDecode(response.body)['password'],
          );
          userProvider.setUserFromModel(user);

          authProvider.setForm(LoginForm());
          authProvider.setResentEmail('');

          IconSnackBar.show(
            context,
            label: 'Change password successfully!',
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

  // Get user data
  void getUserData(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null) {
        await prefs.setString('x-auth-token', '');
        return;
      }

      var tokenRes = await http.post(
        Uri.parse('$uri/token-is-valid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      var isValidToken = jsonDecode(tokenRes.body);

      if (isValidToken) {
        http.Response userRes = await http.get(
          Uri.parse('$uri/user'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token,
          },
        );

        Provider.of<UserProvider>(
          context,
          listen: false,
        ).setUser(userRes.body);

        print('Token: $token');
      }
    } catch (error) {
      IconSnackBar.show(
        context,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );
    }
  }
}
