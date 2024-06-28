import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/auth/screens/auth_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthOptionsScreen extends StatelessWidget {
  static const String routeName = '/auth-options';
  const AuthOptionsScreen({super.key});

  void navigateToAuthScreen(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AuthScreen.routeName,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalVariables.green,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App icon
            SvgPicture.asset(
              'assets/vectors/vector-shuttlecock.svg',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 12),

            // BADCOURT text
            RichText(
              text: TextSpan(
                text: 'BAD',
                style: GoogleFonts.alfaSlabOne(
                  color: GlobalVariables.yellow,
                  fontSize: 24,
                ),
                children: [
                  TextSpan(
                    text: 'COURT',
                    style: GoogleFonts.alfaSlabOne(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Continue as manager button
            SizedBox(
              width: 240,
              height: 40,
              child: ElevatedButton(
                onPressed: () => navigateToAuthScreen(context),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                ),
                child: Text(
                  'Continue as manager',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: GlobalVariables.green,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Continue as player button
            SizedBox(
              width: 240,
              height: 40,
              child: ElevatedButton(
                onPressed: () => navigateToAuthScreen(context),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                ),
                child: Text(
                  'Continue as player',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: GlobalVariables.green,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
