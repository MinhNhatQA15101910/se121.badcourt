import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';

class ThirdWelcome extends StatelessWidget {
  const ThirdWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/img-welcome-3.png',
          fit: BoxFit.cover,
        ),
        Text(
          'BadCourt make you feel',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: GlobalVariables.white,
          ),
        ),
        Text(
          'convenient',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: GlobalVariables.white,
          ),
        ),
        Text(
          'BadCourt provides comfort and',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: GlobalVariables.white,
          ),
        ),
        Text(
          'convenience, making you feel at ease.',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: GlobalVariables.white,
          ),
        ),
      ],
    );
  }
}
