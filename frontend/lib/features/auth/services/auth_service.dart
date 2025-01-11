import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/common/services/socket_service.dart';
import 'package:frontend/constants/error_handling.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/auth/widgets/forgot_password_form.dart';
import 'package:frontend/features/auth/widgets/login_form.dart';
import 'package:frontend/features/auth/widgets/pinput_form.dart';
import 'package:frontend/features/manager/intro_manager/screens/intro_manager_screen.dart';
import 'package:frontend/features/player/player_bottom_bar.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<bool> validateSignUp({
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
      http.Response response = await http.post(
        Uri.parse('$uri/api/auth/validate-signup'),
        body: jsonEncode(
          {
            'username': username,
            'email': email,
            'password': password,
            if (!authProvider.isPlayer) 'role': 'manager',
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

      final responseData = jsonDecode(response.body);
      if (responseData['token'] != null) {
        final String token = responseData['token'];

        authProvider.setAuthToken(token);

        return true;
      } else {
        IconSnackBar.show(
          context,
          label: 'Token not found in the response.',
          snackBarType: SnackBarType.fail,
        );
        return false;
      }
    } catch (error) {
      IconSnackBar.show(
        context,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );
      return false;
    }
  }

  Future<bool> verifyCode({
    required BuildContext context,
    required bool isSignUp,
    required String pincode,
  }) async {
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    try {
      http.Response response = await http.post(
        Uri.parse('$uri/api/auth/verify-pincode'),
        body: jsonEncode(
          {
            'pincode': pincode,
          },
        ),
        headers: {
          'Authorization': 'Bearer ${authProvider.authToken}',
          'Content-Type': 'application/json',
        },
      );

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          if (isSignUp) {
            IconSnackBar.show(
              context,
              label: 'Account created successfully!',
              snackBarType: SnackBarType.success,
            );
          } else {
            IconSnackBar.show(
              context,
              label: 'Change password successfully!',
              snackBarType: SnackBarType.success,
            );
          }
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
          '$uri/api/auth/login',
        ),
        body: jsonEncode(
          {
            'email': email,
            'password': password,
            if (!authProvider.isPlayer) 'role': 'manager',
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
          final socketService = SocketService();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              'x-auth-token', jsonDecode(response.body)['token']);

          userProvider.setUser(response.body);
          socketService.connect(jsonDecode(response.body)['token']);
          if (jsonDecode(response.body)['role'] == 'player') {
            Navigator.of(context).pushNamedAndRemoveUntil(
              PlayerBottomBar.routeName,
              //PostScreen.routeName,
              (route) => false,
            );
          } else if (jsonDecode(response.body)['role'] == 'manager') {
            Navigator.of(context).pushNamedAndRemoveUntil(
              IntroManagerScreen.routeName,
              //PostScreen.routeName,

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

  Future<bool> validateEmail({
    required BuildContext context,
    required String email,
  }) async {
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );
    try {
      http.Response response = await http.post(
        Uri.parse('$uri/api/auth/email-exists'),
        body: jsonEncode(
          {
            'email': email,
            'role': authProvider.isPlayer ? 'player' : 'manager',
          },
        ),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);

        if (responseBody['token'] != null) {
          authProvider.setAuthToken(responseBody['token']);

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

          return true;
        } else {
          IconSnackBar.show(
            context,
            label: 'Token not found in response.',
            snackBarType: SnackBarType.fail,
          );
          return false;
        }
      } else {
        IconSnackBar.show(
          context,
          label:
              'Failed to validate email. Status Code: ${response.statusCode}',
          snackBarType: SnackBarType.fail,
        );
        return false;
      }
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
        Uri.parse('$uri/api/users/change-password'),
        body: jsonEncode(
          {
            'currentPassword': email,
            'new_password': newPassword,
          },
        ),
        headers: {
          'Authorization': 'Bearer ${authProvider.authToken}',
          'Content-Type': 'application/json',
        },
      );

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );

          IconSnackBar.show(
            context,
            label: 'Change password successfully!',
            snackBarType: SnackBarType.success,
          );

          if (PinputForm.isUserChangePassword) {
            Navigator.of(context).pop();
            return;
          }

          authProvider.setForm(LoginForm());
          authProvider.setResentEmail('');
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
