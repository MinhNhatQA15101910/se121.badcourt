import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/common/services/signalr_manager_service.dart';
import 'package:frontend/constants/error_handling.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/auth/screens/auth_options_screen.dart';
import 'package:frontend/features/auth/widgets/forgot_password_form.dart';
import 'package:frontend/features/auth/widgets/pinput_form.dart';
import 'package:frontend/features/manager/intro_manager/screens/intro_manager_screen.dart';
import 'package:frontend/features/player/player_bottom_bar.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/group_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Replace the individual service instances with SignalRManagerService
  final SignalRManagerService _signalRManager = SignalRManagerService();

  // Validate signup with enhanced error handling
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
            maxLines: 2,
            label: 'Validation successful! Please check your email.',
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
        authProvider.setResentEmail(email);
        return true;
      } else {
        IconSnackBar.show(
          context,
          maxLines: 2,
          label: 'Token not found in the response.',
          snackBarType: SnackBarType.fail,
        );
        return false;
      }
    } catch (error) {
      IconSnackBar.show(
        context,
        maxLines: 2,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );
      return false;
    }
  }

  // Enhanced verify code with proper state management
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
              maxLines: 2,
              label: 'Account created successfully!',
              snackBarType: SnackBarType.success,
            );
          } else {
            if (PinputForm.isUserChangePassword) {
              IconSnackBar.show(
                context,
                maxLines: 2,
                label: 'Identity verified! You can now change your password.',
                snackBarType: SnackBarType.success,
              );
            } else {
              IconSnackBar.show(
                context,
                maxLines: 2,
                label: 'Email verified! You can now reset your password.',
                snackBarType: SnackBarType.success,
              );
            }
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
        maxLines: 2,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );
      return false;
    }
  }

  // Enhanced login with proper state management
  Future<bool> logInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      print('Starting login process...');
      http.Response response = await http.post(
        Uri.parse('$uri/gateway/auth/login'),
        body: jsonEncode({
          'email': email,
          'password': password,
          if (!authProvider.isPlayer) 'role': 'Manager',
        }),
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

          // Save token and mark as logged in
          await prefs.setString('Authorization', token);
          await prefs.setBool('is-logged-in', true);
          await prefs.setBool('remember-login', true);

          userProvider.setUser(response.body);
          print('User data set in provider');

          // Reset auth state after successful login
          authProvider.resetAuthState();

          // Connect to all SignalR services
          try {
            print('Attempting to connect to all SignalR services...');
            if (token != null) {
              await _signalRManager.startAllConnections(token);
              
              // Initialize callbacks for GroupProvider
              final groupProvider =
                  Provider.of<GroupProvider>(context, listen: false);
              _signalRManager.initializeCallbacks(
                onReceiveGroups: groupProvider.groupHubService.onReceiveGroups,
                onNewMessage: groupProvider.groupHubService.onNewMessage,
                onGroupUpdated: groupProvider.groupHubService.onGroupUpdated,
                onNewMessageReceived:
                    groupProvider.groupHubService.onNewMessageReceived,
              );
              print('All SignalR services connected successfully after login');
            }
          } catch (signalRError) {
            print('Error connecting to SignalR services: $signalRError');
          }

          // Navigate based on role
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
            maxLines: 2,
            label: 'Login successfully!',
            snackBarType: SnackBarType.success,
          );
        },
      );

      return response.statusCode == 200;
    } catch (error) {
      print('Login error: $error');
      IconSnackBar.show(
        context,
        maxLines: 2,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );
      return false;
    }
  }

  // Enhanced Google login with proper state management
  Future<bool> logInWithGoogle({
    required BuildContext context,
    required GoogleSignInAccount account,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

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

          // Save token and mark as logged in
          await prefs.setString('Authorization', token);
          await prefs.setBool('is-logged-in', true);
          await prefs.setBool('remember-login', true);

          Provider.of<UserProvider>(context, listen: false)
              .setUser(response.body);

          // Reset auth state after successful login
          authProvider.resetAuthState();

          // Connect to SignalR services immediately after successful Google login
          try {
            print('Attempting to connect to SignalR services after Google login...');
            if (token != null) {
              await _signalRManager.startAllConnections(token);
              print('All SignalR services connected successfully after Google login');
            }
          } catch (signalRError) {
            print('Error connecting to SignalR services: $signalRError');
          }

          Navigator.of(context).pushNamedAndRemoveUntil(
            PlayerBottomBar.routeName,
            (route) => false,
          );

          IconSnackBar.show(
            context,
            maxLines: 2,
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
        maxLines: 2,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );
      return false;
    }
  }

  // Enhanced validate email with proper form navigation
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
        Uri.parse('$uri/gateway/auth/email-exists'),
        body: jsonEncode(
          {
            'email': email,
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
          authProvider.setResentEmail(email);
          authProvider.setPreviousForm(ForgotPasswordForm());
          
          // Use the enhanced setForm method
          authProvider.setForm(
            PinputForm(
              isMoveBack: false,
              isValidateSignUpEmail: false,
            ),
            fromChangePassword: false,
          );

          IconSnackBar.show(
            context,
            maxLines: 2,
            label: 'Verification code sent to your email!',
            snackBarType: SnackBarType.success,
          );

          return true;
        } else {
          IconSnackBar.show(
            context,
            maxLines: 2,
            label: 'Token not found in response.',
            snackBarType: SnackBarType.fail,
          );
          return false;
        }
      } else {
        IconSnackBar.show(
          context,
          maxLines: 2,
          label: 'Failed to validate email. Status Code: ${response.statusCode}',
          snackBarType: SnackBarType.fail,
        );
        return false;
      }
    } catch (error) {
      IconSnackBar.show(
        context,
        maxLines: 2,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );
      return false;
    }
  }

  // Enhanced change password method
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
          IconSnackBar.show(
            context,
            maxLines: 2,
            label: 'Password changed successfully!',
            snackBarType: SnackBarType.success,
          );

          if (PinputForm.isUserChangePassword) {
            // Reset the flag and pop the screen
            PinputForm.isUserChangePassword = false;
            Navigator.of(context).pop();
            return;
          }

          // Normal flow - reset to login
          authProvider.forceResetToLogin();
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
        maxLines: 2,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );
      return false;
    }
  }

  // New method to handle change password from profile
  Future<void> initiateChangePasswordFromProfile(BuildContext context, String email) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Set the static flag for change password flow
      PinputForm.isUserChangePassword = true;
      
      // Set email for resend functionality
      authProvider.setResentEmail(email);
      
      // Send verification email for change password
      http.Response response = await http.post(
        Uri.parse('$uri/gateway/auth/send-change-password-code'),
        body: jsonEncode({
          'email': email,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${authProvider.authToken}',
        },
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        
        if (responseBody['token'] != null) {
          authProvider.setAuthToken(responseBody['token']);
        }

        // Navigate to pinput form with change password context
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              backgroundColor: GlobalVariables.green,
              body: SafeArea(
                child: Center(
                  child: PinputForm(
                    isMoveBack: false,
                    isValidateSignUpEmail: false,
                  ),
                ),
              ),
            ),
          ),
        );

        IconSnackBar.show(
          context,
          maxLines: 2,
          label: 'Verification code sent to your email!',
          snackBarType: SnackBarType.success,
        );
      } else {
        PinputForm.isUserChangePassword = false; // Reset on failure
        IconSnackBar.show(
          context,
          maxLines: 2,
          label: 'Failed to send verification code.',
          snackBarType: SnackBarType.fail,
        );
      }
    } catch (error) {
      PinputForm.isUserChangePassword = false; // Reset on error
      IconSnackBar.show(
        context,
        maxLines: 2,
        label: 'Error: ${error.toString()}',
        snackBarType: SnackBarType.fail,
      );
    }
  }

  // Enhanced getUserData with proper state management
  Future<void> getUserData(BuildContext context) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('Authorization');
    bool? rememberLogin = prefs.getBool('remember-login');

    print('Checking stored token: ${token != null ? 'Token exists' : 'No token'}');
    print('Remember login: ${rememberLogin ?? false}');

    if (token == null || token.isEmpty || !(rememberLogin ?? false)) {
      await prefs.setString('Authorization', '');
      await prefs.setBool('is-logged-in', false);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.resetAuthState();
      return;
    }

    final tokenRes = await http.post(
      Uri.parse('$uri/gateway/auth/token-is-valid'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    print('Token validation status code: ${tokenRes.statusCode}');
      var isValidToken = jsonDecode(tokenRes.body);
    if (tokenRes.statusCode == 200 && isValidToken) {
      final userRes = await http.get(
        Uri.parse('$uri/gateway/users/me'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      Provider.of<UserProvider>(context, listen: false).setUser(userRes.body);
      print('User data loaded successfully');

      try {
        String cleanToken = token.startsWith('Bearer ') ? token.substring(7) : token;
        await _signalRManager.startAllConnections(cleanToken);
        print('All SignalR services auto-connected for existing user session');
      } catch (signalRError) {
        print('Error auto-connecting to SignalR services: $signalRError');
      }
    } else {
      await clearLoginData();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.resetAuthState();
    }
  } catch (error) {
    print('Error in getUserData: $error');
    await clearLoginData();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.resetAuthState();

    IconSnackBar.show(
      context,
      maxLines: 2,
      label: error.toString(),
      snackBarType: SnackBarType.fail,
    );
  }
}


  // Enhanced refresh token method
  Future<bool> refreshTokenIfNeeded() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('Authorization');
      bool? rememberLogin = prefs.getBool('remember-login');

      if (token == null || token.isEmpty || !(rememberLogin ?? false)) {
        return false;
      }

      // Check token validity
      var tokenRes = await http.post(
        Uri.parse('$uri/gateway/auth/token-is-valid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      var isValidToken = jsonDecode(tokenRes.body);
      if (!isValidToken) {
        await clearLoginData();
      }

      return isValidToken == true;
    } catch (error) {
      print('Error checking token validity: $error');
      await clearLoginData();
      return false;
    }
  }

  // Enhanced clear login data method
  Future<void> clearLoginData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('Authorization');
      await prefs.remove('Authorization');
      await prefs.setBool('is-logged-in', false);
      await prefs.setBool('remember-login', false);
      
      // Reset static variables
      PinputForm.isUserChangePassword = false;
      
      print('Login data cleared');
    } catch (error) {
      print('Error clearing login data: $error');
    }
  }

  // Enhanced check login status method
  Future<bool> isLoggedIn() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? isLoggedIn = prefs.getBool('is-logged-in');
      bool? rememberLogin = prefs.getBool('remember-login');
      String? token = prefs.getString('Authorization');

      return (isLoggedIn ?? false) &&
          (rememberLogin ?? false) &&
          (token != null && token.isNotEmpty);
    } catch (error) {
      print('Error checking login status: $error');
      return false;
    }
  }

  // Enhanced logout method with proper state cleanup
  Future<void> logOutUser(BuildContext context) async {
    try {
      // Disconnect from all SignalR services
      await _signalRManager.stopAllConnections();
      print('All SignalR services disconnected on logout');

      // Clear stored tokens and other data
      await clearLoginData();

      // Clear user data
      Provider.of<UserProvider>(context, listen: false).setUser('');

      // IMPORTANT: Reset auth provider state
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.resetAuthState(); // This will reset all form states

      // Clear navigation stack and go to auth options
      Navigator.of(context).pushNamedAndRemoveUntil(
        AuthOptionsScreen.routeName,
        (route) => false, // Remove all previous routes
      );

      IconSnackBar.show(
        context,
        maxLines: 2,
        label: 'Logged out successfully!',
        snackBarType: SnackBarType.success,
      );
    } catch (error) {
      print('Error during logout: $error');
      
      // Force reset even if there's an error
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.resetAuthState();
      
      Navigator.of(context).pushNamedAndRemoveUntil(
        AuthOptionsScreen.routeName,
        (route) => false,
      );
      
      IconSnackBar.show(
        context,
        maxLines: 2,
        label: 'Error during logout: ${error.toString()}',
        snackBarType: SnackBarType.fail,
      );
    }
  }

  // Enhanced silent logout method
  Future<void> silentLogout(BuildContext context) async {
    try {
      await _signalRManager.stopAllConnections();
      await clearLoginData();
      
      Provider.of<UserProvider>(context, listen: false).setUser('');
      
      // Reset auth state during silent logout
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.resetAuthState();
      
      Navigator.of(context).pushNamedAndRemoveUntil(
        AuthOptionsScreen.routeName,
        (route) => false,
      );
    } catch (error) {
      print('Error during silent logout: $error');
    }
  }

  // Resend signup verification email
  Future<bool> resendSignupVerification({
    required BuildContext context,
    required String email,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      http.Response response = await http.post(
        Uri.parse('$uri/gateway/auth/resend-signup-verification'),
        body: jsonEncode({
          'email': email,
          if (!authProvider.isPlayer) 'role': 'manager',
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          if (authProvider.authToken.isNotEmpty)
            'Authorization': 'Bearer ${authProvider.authToken}',
        },
      );

      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          IconSnackBar.show(
            context,
            maxLines: 2,
            label: 'Verification code sent successfully!',
            snackBarType: SnackBarType.success,
          );
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['token'] != null) {
          authProvider.setAuthToken(responseData['token']);
        }
        return true;
      }

      return false;
    } catch (error) {
      IconSnackBar.show(
        context,
        maxLines: 2,
        label: 'Failed to resend verification code: ${error.toString()}',
        snackBarType: SnackBarType.fail,
      );
      return false;
    }
  }

  // Resend forgot password email
  Future<bool> resendForgotPasswordEmail({
    required BuildContext context,
    required String email,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      http.Response response = await http.post(
        Uri.parse('$uri/gateway/auth/resend-forgot-password'),
        body: jsonEncode({
          'email': email,
          'role': authProvider.isPlayer ? 'player' : 'manager',
        }),
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
            maxLines: 2,
            label: 'Reset code sent successfully!',
            snackBarType: SnackBarType.success,
          );
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['token'] != null) {
          authProvider.setAuthToken(responseData['token']);
        }
        return true;
      }

      return false;
    } catch (error) {
      IconSnackBar.show(
        context,
        maxLines: 2,
        label: 'Failed to resend reset code: ${error.toString()}',
        snackBarType: SnackBarType.fail,
      );
      return false;
    }
  }

  // Check if email can receive verification code
  Future<bool> canResendToEmail({
    required BuildContext context,
    required String email,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$uri/gateway/auth/check-resend-eligibility'),
        body: jsonEncode({
          'email': email,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['canResend'] ?? false;
      }

      return true; // Default to true if endpoint doesn't exist
    } catch (error) {
      return true; // Default to true on error
    }
  }

  // Get SignalR manager service instance
  SignalRManagerService get signalRManager => _signalRManager;
}
