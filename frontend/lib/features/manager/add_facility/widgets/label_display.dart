import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';

class LabelDisplay extends StatelessWidget {
  const LabelDisplay({
    super.key,
    required this.label,
    this.isRequired = false,
  });

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    if (isRequired) {
      return Padding(
        padding: const EdgeInsets.only(
          bottom: 8,
          top: 12,
        ),
        child: RichText(
          text: TextSpan(
            text: label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: GlobalVariables.darkGrey,
            ),
            children: [
              TextSpan(
                text: ' (*)',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
        top: 12,
      ),
      child: Text(
        '$label (optional)',
        style: GoogleFonts.inter(
          fontSize: 14,
          color: GlobalVariables.darkGrey,
        ),
      ),
    );
  }
}
