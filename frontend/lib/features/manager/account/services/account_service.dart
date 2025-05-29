import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/common/services/presence_service_hub.dart';
import 'package:frontend/features/auth/screens/auth_options_screen.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountService {
  final PresenceService _signalRService = PresenceService();

  void logOut(BuildContext context) async {
    try {
      print('🔄 Starting logout process...');

      // 1. Disconnect SignalR first (user goes offline)
      try {
        if (_signalRService.isConnected) {
          print('🔄 Disconnecting SignalR...');
          await _signalRService.stopConnection();
          print('✅ SignalR disconnected successfully');
        } else {
          print('ℹ️ SignalR was not connected');
        }
      } catch (signalRError) {
        print('❌ Error disconnecting SignalR: $signalRError');
        // Continue with logout even if SignalR disconnect fails
      }

      // 2. Clear stored tokens
      print('🔄 Clearing stored tokens...');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('x-auth-token', '');
      await prefs.remove('Authorization'); // Also remove Authorization if exists
      print('✅ Tokens cleared');

      // 3. Sign out from Google
      print('🔄 Signing out from Google...');
      GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
      );
      await googleSignIn.signOut();
      print('✅ Google sign out completed');

      // 4. Clear user data from provider
      print('🔄 Clearing user data...');
      Provider.of<UserProvider>(context, listen: false).setUser('');
      print('✅ User data cleared');

      // 5. Navigate to auth screen
      print('🔄 Navigating to auth screen...');
      Navigator.pushNamedAndRemoveUntil(
        context,
        AuthOptionsScreen.routeName,
        (route) => false,
      );

      // 6. Show success message
      IconSnackBar.show(
        context,
        label: 'Log out successfully!',
        snackBarType: SnackBarType.success,
      );

      print('✅ Logout completed successfully');
    } catch (error) {
      print('❌ Error during logout: $error');
      IconSnackBar.show(
        context,
        label: 'Error during logout: ${error.toString()}',
        snackBarType: SnackBarType.fail,
      );
    }
  }

  // Method to check SignalR connection status
  bool isSignalRConnected() {
    return _signalRService.isConnected;
  }

  // Method to get SignalR connection state for debugging
  String getSignalRConnectionState() {
    return _signalRService.connectionState;
  }

  // Method to manually disconnect SignalR (for testing)
  Future<void> disconnectSignalR() async {
    try {
      await _signalRService.stopConnection();
      print('SignalR manually disconnected');
    } catch (e) {
      print('Error manually disconnecting SignalR: $e');
    }
  }
}