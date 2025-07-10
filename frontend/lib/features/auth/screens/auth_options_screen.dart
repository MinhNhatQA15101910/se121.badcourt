import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/auth/screens/auth_screen.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AuthOptionsScreen extends StatelessWidget {
  static const String routeName = '/-auth-options';
  const AuthOptionsScreen({super.key});

  void navigateToAuthScreen(BuildContext context, bool isPlayer) {
    Provider.of<AuthProvider>(context, listen: false).setIsPlayer(isPlayer);
    Navigator.of(context).pushNamed(AuthScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: GlobalVariables.green,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              // Header section with logo
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App icon with animation
                      TweenAnimationBuilder(
                        duration: Duration(milliseconds: 800),
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: value,
                            child: SvgPicture.asset(
                              'assets/vectors/vector-shuttlecock.svg',
                              width: 120,
                              height: 120,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // BADCOURT text with fade animation
                      TweenAnimationBuilder(
                        duration: Duration(milliseconds: 1000),
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: RichText(
                              text: TextSpan(
                                text: 'BAD',
                                style: GoogleFonts.alfaSlabOne(
                                  color: GlobalVariables.yellow,
                                  fontSize: 28,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'COURT',
                                    style: GoogleFonts.alfaSlabOne(
                                      color: Colors.white,
                                      fontSize: 28,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Subtitle
                      Text(
                        'Choose your role to continue',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Options section
              Expanded(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Manager option card
                      _buildRoleCard(
                        context: context,
                        title: 'Manager',
                        subtitle: 'Manage courts, bookings and players',
                        icon: Icons.admin_panel_settings,
                        onTap: () => navigateToAuthScreen(context, false),
                        delay: 200,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Player option card
                      _buildRoleCard(
                        context: context,
                        title: 'Player',
                        subtitle: 'Book courts and join games',
                        icon: Icons.sports_tennis,
                        onTap: () => navigateToAuthScreen(context, true),
                        delay: 400,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Footer
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'By continuing, you agree to our Terms & Privacy Policy',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required int delay,
  }) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: GlobalVariables.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            icon,
                            color: GlobalVariables.green,
                            size: 24,
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Text content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: GlobalVariables.darkGreen,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: GlobalVariables.blackGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Arrow icon
                        Icon(
                          Icons.arrow_forward_ios,
                          color: GlobalVariables.green,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
