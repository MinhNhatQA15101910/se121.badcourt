import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DateTagPlayer extends StatelessWidget {
  final DateTime datetime;
  final bool isActived;
  final bool isDisabled;
  final VoidCallback onPressed;

  const DateTagPlayer({
    Key? key,
    required this.datetime,
    required this.isActived,
    required this.isDisabled,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dayName = DateFormat('EEE').format(datetime);
    final dayNumber = DateFormat('dd').format(datetime);
    final monthName = DateFormat('MMM').format(datetime);

    final bgColor = isActived
        ? GlobalVariables.green
        : isDisabled
            ? Colors.grey.shade200
            : Colors.white;

    final borderColor = isActived
        ? GlobalVariables.green
        : Colors.grey.shade300;

    final textColor = isDisabled
        ? Colors.grey.shade400
        : (isActived ? Colors.white : Colors.black);

    return Opacity(
      opacity: isDisabled ? 0.5 : 1,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: isDisabled ? null : onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dayName,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dayNumber,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  monthName,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
