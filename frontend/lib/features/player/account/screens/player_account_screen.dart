import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/common/widgets/custom_container.dart';
import 'package:frontend/common/widgets/profile_header_widget.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/auth/screens/auth_screen.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/auth/widgets/pinput_form.dart';
import 'package:frontend/features/message/screens/message_detail_screen.dart';
import 'package:frontend/features/order/screens/order_screen.dart';
import 'package:frontend/features/player/account/services/player_account_service.dart';
import 'package:frontend/features/player/favorite/screens/favorite_screen.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PlayerAccountScreen extends StatelessWidget {
  PlayerAccountScreen({super.key});

  final PlayerAccountService playerAccountService = PlayerAccountService();

  Future<void> _navigateToDetailMessageScreen(BuildContext context) async {
    final adminId = await playerAccountService.getAdminUserId(context);

    if (adminId != null) {
      Navigator.of(context).pushNamed(
        MessageDetailScreen.routeName,
        arguments: adminId,
      );
    } else {
      IconSnackBar.show(
        context,
        label: 'Failed to retrieve admin ID.',
        snackBarType: SnackBarType.fail,
      );
    }
  }

  void navigateToPinputForm(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    PinputForm.isUserChangePassword = true;
    authProvider.setForm(PinputForm(
      isMoveBack: false,
      isValidateSignUpEmail: false,
    ));
    authProvider.setPreviousForm(null);
    authProvider.setResentEmail(userProvider.user.email);

    Navigator.of(context).pushNamed(AuthScreen.routeName);
  }

  void navigateToBookingManagementScreen(BuildContext context) {
    Navigator.of(context).pushNamed(OrderScreen.routeName);
  }

  void navigateToFavouriteScreen(BuildContext context) {
    Navigator.of(context).pushNamed(FavoriteScreen.routeName);
  }

  void logOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            'Log out',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: GoogleFonts.inter(),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: GlobalVariables.darkGrey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final authService = AuthService();
                authService.logOutUser(context);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GlobalVariables.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Log out',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileHeaderWidget(
              username: userProvider.user.username,
              photoUrl: userProvider.user.photoUrl,
              userId: userProvider.user.id,
              photos: userProvider.user.photos,
              showEditButton: true,
              onEditPressed: () {
                // Edit profile functionality
              },
            ),
            const SizedBox(height: 16),
            _buildBookingSection(context),
            const SizedBox(height: 16),
            _buildAccountOptions(context),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ... rest of the methods remain the same
  Widget _buildBookingSection(BuildContext context) {
    return CustomContainer(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Bookings',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: GlobalVariables.blackGrey,
                ),
              ),
              GestureDetector(
                onTap: () => navigateToBookingManagementScreen(context),
                child: Row(
                  children: [
                    Text(
                      'View all',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: GlobalVariables.green,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: GlobalVariables.green,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBookingStatusItem(
                  Icons.pending_actions_rounded,
                  'Pending',
                  () {
                    navigateToBookingManagementScreen(context);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBookingStatusItem(
                  Icons.check_circle_outline_rounded,
                  'Played',
                  () {
                    navigateToBookingManagementScreen(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingStatusItem(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: GlobalVariables.green.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: GlobalVariables.green.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: GlobalVariables.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: GlobalVariables.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: GlobalVariables.blackGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountOptions(BuildContext context) {
    return Column(
      children: [
        _buildAccountOptionItem(
          'Favorites',
          'View your favorite facilities',
          Icons.favorite_border_rounded,
          () => navigateToFavouriteScreen(context),
        ),
        const SizedBox(height: 16),
        _buildAccountOptionItem(
          'Support',
          'Get help with your account',
          Icons.headset_mic_outlined,
          () => _navigateToDetailMessageScreen(context),
        ),
        const SizedBox(height: 16),
        _buildAccountOptionItem(
          'Change Password',
          'Update your password',
          Icons.lock_outline_rounded,
          () => navigateToPinputForm(context),
        ),
        const SizedBox(height: 16),
        _buildAccountOptionItem(
          'Log Out',
          'Sign out of your account',
          Icons.logout_rounded,
          () => logOut(context),
          isLogout: true,
        ),
      ],
    );
  }

  Widget _buildAccountOptionItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isLogout
                ? Colors.red.withOpacity(0.1)
                : GlobalVariables.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isLogout ? Colors.red : GlobalVariables.green,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isLogout ? Colors.red : GlobalVariables.blackGrey,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: GlobalVariables.darkGrey,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: isLogout ? Colors.red : GlobalVariables.darkGrey,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              // Open terms and conditions
            },
            child: Text(
              'Terms and Conditions',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: GlobalVariables.green,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Version 1.0.0',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: GlobalVariables.darkGrey,
            ),
          ),
        ],
      ),
    );
  }
}
