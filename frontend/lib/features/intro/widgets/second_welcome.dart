import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';

class SecondWelcome extends StatelessWidget {
  const SecondWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/img-welcome-2.png',
          fit: BoxFit.cover,
        ),
        Text(
          'Let\'s start journey with',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: GlobalVariables.white,
          ),
        ),
        Text(
          'BadCourt',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: GlobalVariables.white,
          ),
        ),
        Text(
          'BadCourt provides a variety of',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: GlobalVariables.white,
          ),
        ),
        Text(
          'badminton training court options.',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: GlobalVariables.white,
          ),
        ),
      ],
    );
  }
}
