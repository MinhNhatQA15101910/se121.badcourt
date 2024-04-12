import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';

class FirstWelcome extends StatelessWidget {
  const FirstWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Welcome to',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: GlobalVariables.white,
          ),
        ),
        const SizedBox(height: 5),
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
        Image.asset(
          'assets/images/img-welcome-1.png',
          fit: BoxFit.cover,
        ),
      ],
    );
  }
}
