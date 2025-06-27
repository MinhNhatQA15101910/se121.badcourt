import 'package:flutter/material.dart';
import 'package:frontend/Enums/facility_state.dart';
import 'package:google_fonts/google_fonts.dart';

class StateBadge extends StatelessWidget {
  final FacilityState state;
  final double? fontSize;
  final EdgeInsets? padding;

  const StateBadge({
    Key? key,
    required this.state,
    this.fontSize = 12,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: state.badgeColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        state.displayName,
        style: GoogleFonts.inter(
          color: state.textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}