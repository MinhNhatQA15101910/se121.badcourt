import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/separator.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/player/booking_details/screens/booking_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingInfoItem extends StatefulWidget {
  const BookingInfoItem({super.key});

  @override
  State<BookingInfoItem> createState() => _BookingInfoItemState();
}

class _BookingInfoItemState extends State<BookingInfoItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InterBold14(
            'Court 1',
            GlobalVariables.blackGrey,
            1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InterRegular14(
                '13:30 - 14:30',
                GlobalVariables.blackGrey,
                1,
              ),
              _InterSemiBold14(
                '\$20',
                GlobalVariables.blackGrey,
                1,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InterRegular14(
                '14:30 - 15:30',
                GlobalVariables.blackGrey,
                1,
              ),
              _InterSemiBold14(
                '\$20',
                GlobalVariables.blackGrey,
                1,
              )
            ],
          ),
          Separator(color: GlobalVariables.darkGrey),
        ],
      ),
    );
  }

  Widget _InterRegular14(String text, Color color, int maxLines) {
    return Container(
      child: Text(
        text,
        textAlign: TextAlign.start,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _InterSemiBold14(String text, Color color, int maxLines) {
    return Container(
      child: Text(
        text,
        textAlign: TextAlign.start,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _InterBold14(String text, Color color, int maxLines) {
    return Container(
      child: Text(
        text,
        textAlign: TextAlign.start,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
