import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:frontend/common/widgets/custom_container.dart';
import 'package:frontend/common/widgets/facility_item.dart';
import 'package:frontend/common/widgets/profile_header_widget.dart';
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

  // ... rest of the methods remain the same
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
