import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/common/services/presence_service_hub.dart';
import 'package:frontend/features/auth/screens/auth_options_screen.dart';
import 'package:frontend/features/auth/widgets/login_form.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountService {
  final PresenceService _signalRService = PresenceService();

  void logOut(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    try {
      // 1. Ngắt kết nối SignalR trước khi logout
      if (_signalRService.isConnected) {
        print('Disconnecting SignalR before logout...');
        await _signalRService.stopConnection();
        print('SignalR disconnected successfully');
      }

      // 2. Xóa token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('x-auth-token', '');
      await prefs.remove('Authorization'); // Xóa cả Authorization token nếu có

      // 3. Đăng xuất Google
      GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
      );
      await googleSignIn.signOut();

      // 4. Reset form và user data
      authProvider.setForm(new LoginForm());
      
      // 5. Xóa user data nếu có UserProvider
      try {
        Provider.of<UserProvider>(context, listen: false).setUser('');
      } catch (e) {
        // Bỏ qua nếu không có UserProvider
      }

      // 6. Chuyển về màn hình đăng nhập
      Navigator.of(context).pushNamedAndRemoveUntil(
        AuthOptionsScreen.routeName,
        (route) => false,
      );

      // 7. Hiển thị thông báo thành công
      IconSnackBar.show(
        context,
        label: 'Log out successfully!',
        snackBarType: SnackBarType.success,
      );
    } catch (error) {
      print('Error during logout: $error');
      IconSnackBar.show(
        context,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );
    }
  }
}