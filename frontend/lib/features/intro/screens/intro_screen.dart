import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/intro/screens/welcome_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  void navigateToWelcomeScreen(BuildContext context) {
    Navigator.of(context).pushNamed(WelcomeScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navigateToWelcomeScreen(context),
      child: Scaffold(
        backgroundColor: GlobalVariables.green,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/vectors/vector-shuttlecock.svg',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 12),
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
            ],
          ),
        ),
      ),
    );
  }
}
