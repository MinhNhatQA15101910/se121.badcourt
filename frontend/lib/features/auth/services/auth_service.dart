import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/common/services/presence_service_hub.dart';
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
  final PresenceService _signalRService = PresenceService();

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
        Uri.parse('$uri/gateway/auth/validate-signup'),
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
        Uri.parse('$uri/gateway/auth/verify-pincode'),
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

  // Log in user with SignalR integration
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
      print('Starting login process...');

      http.Response response = await http.post(
        Uri.parse(
          '$uri/gateway/auth/login',
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
          print('Login API call successful');

          SharedPreferences prefs = await SharedPreferences.getInstance();
          final token = jsonDecode(response.body)['token'];
          await prefs.setString('Authorization', 'Bearer $token');

          userProvider.setUser(response.body);
          print('User data set in provider');

          // Connect to SignalR immediately after successful login
          try {
            print('Attempting to connect to SignalR...');
            String baseUrl = signalrUri;
            if (baseUrl.isNotEmpty && token != null) {
              await _signalRService.startConnection(token);
              print('SignalR connected successfully after login');
            } else {
              print('Missing baseUrl or token for SignalR connection');
            }
          } catch (signalRError) {
            print('Error connecting to SignalR: $signalRError');
            // Don't fail the login if SignalR connection fails
          }

          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final roles = (data['roles'] as List<dynamic>).cast<String>();

          if (roles.isNotEmpty && roles[0] == 'Player') {
            Navigator.of(context).pushNamedAndRemoveUntil(
              PlayerBottomBar.routeName,
              (route) => false,
            );
          } else if (roles.isNotEmpty && roles[0] == 'Manager') {
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
        print('Login failed with status code: ${response.statusCode}');
        return false;
      }

      return true;
    } catch (error) {
      print('Login error: $error');
      IconSnackBar.show(
        context,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );

      return false;
    }
  }

// Log in user with google and SignalR integration
  Future<bool> logInWithGoogle({
    required BuildContext context,
    required GoogleSignInAccount account,
  }) async {
    try {
      print('Starting Google login process...');

      http.Response response = await http.post(
        Uri.parse('$uri/gateway/login/google'),
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
          print('Google login API call successful');

          SharedPreferences prefs = await SharedPreferences.getInstance();
          final token = jsonDecode(response.body)['token'];
          await prefs.setString('x-auth-token', token);

          Provider.of<UserProvider>(context, listen: false)
              .setUser(response.body);

          // Connect to SignalR immediately after successful Google login
          try {
            print('Attempting to connect to SignalR after Google login...');
            String baseUrl = signalrUri;
            if (baseUrl.isNotEmpty && token != null) {
              await _signalRService.startConnection(token);
              print('SignalR connected successfully after Google login');
            }
          } catch (signalRError) {
            print('Error connecting to SignalR: $signalRError');
          }

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
        print('Google login failed with status code: ${response.statusCode}');
        return false;
      }

      return true;
    } catch (error) {
      print('Google login error: $error');
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
        Uri.parse('$uri/gateway/api/auth/email-exists'),
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
        Uri.parse('$uri/gateway/users/change-password'),
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

  // Get user data with SignalR auto-connect for existing sessions
  Future<void> getUserData(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');
      print(
          'Checking stored token: ${token != null ? 'Token exists' : 'No token'}');

      if (token == null) {
        await prefs.setString('x-auth-token', '');
        return;
      }

      var tokenRes = await http.post(
        Uri.parse('$uri/gateway/token-is-valid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      var isValidToken = jsonDecode(tokenRes.body);
      print('Token validation result: $isValidToken');

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

        print('User data loaded successfully');

        // Auto-connect to SignalR if user is already logged in
        try {
          String baseUrl = signalrUri;
          if (baseUrl.isNotEmpty && !_signalRService.isConnected) {
            String cleanToken =
                token.startsWith('Bearer ') ? token.substring(7) : token;
            await _signalRService.startConnection(cleanToken);
            print('SignalR auto-connected for existing user session');
          }
        } catch (signalRError) {
          print('Error auto-connecting to SignalR: $signalRError');
        }
      }
    } catch (error) {
      print('Error in getUserData: $error');
      IconSnackBar.show(
        context,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );
    }
  }

  // Add logout method with SignalR disconnect
  Future<void> logOutUser(BuildContext context) async {
    try {
      // Disconnect from SignalR
      await _signalRService.stopConnection();
      print('SignalR disconnected on logout');

      // Clear stored tokens
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('x-auth-token');
      await prefs.remove('Authorization');

      // Clear user data
      Provider.of<UserProvider>(context, listen: false).setUser('');

      // Navigate to auth screen
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/auth', // Replace with your auth route
        (route) => false,
      );

      IconSnackBar.show(
        context,
        label: 'Logged out successfully!',
        snackBarType: SnackBarType.success,
      );
    } catch (error) {
      print('Error during logout: $error');
      IconSnackBar.show(
        context,
        label: 'Error during logout: ${error.toString()}',
        snackBarType: SnackBarType.fail,
      );
    }
  }

  // Get SignalR service instance for external use
  PresenceService get signalRService => _signalRService;
}
