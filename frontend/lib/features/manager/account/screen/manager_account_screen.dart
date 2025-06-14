import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:frontend/common/widgets/custom_container.dart';
import 'package:frontend/common/widgets/facility_item.dart';
import 'package:frontend/common/widgets/separator.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/providers/manager/current_facility_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ManagerAccountScreen extends StatelessWidget {
  static const String routeName = '/manager/account';
  const ManagerAccountScreen({super.key});

  void logOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            'Log out confirm',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Are you sure to log out the app?',
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
                'No',
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
                'Yes',
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
    final currentFacilityProvider = context.watch<CurrentFacilityProvider>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(userProvider.user.username),
            const SizedBox(height: 16),
            _buildFacilityRatingSection(currentFacilityProvider),
            const SizedBox(height: 16),
            _buildFacilitySection(currentFacilityProvider),
            const SizedBox(height: 16),
            _buildAccountOptions(context),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String username) {
    return Container(
      height: 240,
      child: Stack(
        children: [
          // Background image with gradient overlay
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    GlobalVariables.green,
                    GlobalVariables.green.withOpacity(0.8),
                  ],
                  stops: const [0.1, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.srcATop,
              child: Image.asset(
                'assets/images/img_account_background.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Profile content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
            ),
          ),
          
          // Profile image
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/img_account.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          
          // Username
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                username,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: GlobalVariables.blackGrey,
                ),
              ),
            ),
          ),
          
          // Edit profile button
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: GlobalVariables.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: GlobalVariables.green,
                ),
                onPressed: () {
                  // Edit profile functionality
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityRatingSection(CurrentFacilityProvider currentFacilityProvider) {
    return CustomContainer(
      child: Column(
        children: [
          Row(
            children: [
              _interMedium14('5.0', GlobalVariables.blackGrey, 1),
              const SizedBox(width: 8),
              Expanded(
                child: RatingBar.builder(
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  ignoreGestures: true,
                  itemCount: 5,
                  itemSize: 16,
                  unratedColor: GlobalVariables.lightYellow,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: GlobalVariables.yellow,
                  ),
                  onRatingUpdate: (rating) {
                    print(rating);
                  },
                ),
              ),
              _interRegular14(
                '(50 Ratings)',
                GlobalVariables.green,
                1,
              ),
            ],
          ),
          Separator(color: GlobalVariables.darkGrey),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _interMedium14(
                'Response rate (24h recent)',
                GlobalVariables.blackGrey,
                1,
              ),
              _interBold14(
                '97%',
                GlobalVariables.blackGrey,
                1,
              ),
            ],
          ),
          Separator(color: GlobalVariables.darkGrey),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: GlobalVariables.green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _interBold14(
                  currentFacilityProvider.currentFacility.detailAddress,
                  GlobalVariables.blackGrey,
                  4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitySection(CurrentFacilityProvider currentFacilityProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(
            top: 0,
            left: 16,
            right: 16,
            bottom: 8,
          ),
          child: Text(
            'Badminton facility list',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: GlobalVariables.blackGrey,
            ),
          ),
        ),
        FacilityItem(
          facility: currentFacilityProvider.currentFacility,
        ),
      ],
    );
  }

  Widget _buildAccountOptions(BuildContext context) {
    return Column(
      children: [
        _buildAccountOptionItem(
          'Settings',
          'Manage facility settings',
          Icons.settings_outlined,
          () {
            // Settings functionality
          },
        ),
        const SizedBox(height: 16),
        _buildAccountOptionItem(
          'Support',
          'Get help with your account',
          Icons.headset_mic_outlined,
          () {
            // Support functionality
          },
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
            'Manager Version 1.0.0',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: GlobalVariables.darkGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _interRegular14(String text, Color color, int maxLines) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: color,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _interMedium14(String text, Color color, int maxLines) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: color,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _interBold14(String text, Color color, int maxLines) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: color,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
