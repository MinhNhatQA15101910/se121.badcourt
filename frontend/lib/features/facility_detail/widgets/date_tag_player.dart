import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DateTagPlayer extends StatelessWidget {
  final DateTime datetime;
  final bool isActived;
  final VoidCallback onPressed;

  const DateTagPlayer({
    Key? key,
    required this.datetime,
    required this.isActived,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dayName = DateFormat('EEE').format(datetime);
    final dayNumber = DateFormat('dd').format(datetime);
    final monthName = DateFormat('MMM').format(datetime);

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActived ? GlobalVariables.green : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActived ? GlobalVariables.green : Colors.grey.shade300,
              width: 1,
            ),
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
                  color: isActived ? Colors.white : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dayNumber,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isActived ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                monthName,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: isActived ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
