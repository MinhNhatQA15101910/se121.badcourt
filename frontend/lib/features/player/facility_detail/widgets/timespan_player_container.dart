import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/booking.dart';
import 'package:google_fonts/google_fonts.dart';

class TimespanPlayerContainer extends StatelessWidget {
  final BookingTime bookingTime;
  final double marginTop;
  final double height;
  final void Function() onUnlockPress;

  const TimespanPlayerContainer({
    Key? key,
    this.marginTop = 0.0,
    this.height = 100.0,
    required this.bookingTime,
    required this.onUnlockPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 40, top: marginTop + 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color:
            isValid(bookingTime) ? GlobalVariables.green : GlobalVariables.grey,
        border: Border.all(
          color: isValid(bookingTime)
              ? GlobalVariables.green
              : GlobalVariables.darkGrey,
          width: 1,
        ),
      ),
      height: height,
      width: double.maxFinite,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: !isValid(bookingTime)
            ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InterMedium12(
                      calculateTimeDifference(
                          bookingTime.startDate, bookingTime.endDate),
                      GlobalVariables.darkGrey,
                      1,
                    ),
                    _InterMedium12(
                      calculateTimeDifference(
                          bookingTime.startDate, bookingTime.endDate),
                      GlobalVariables.darkGrey,
                      1,
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  SingleChildScrollView(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InterMedium12(
                            calculateTimeDifference(
                                bookingTime.startDate, bookingTime.endDate),
                            GlobalVariables.white,
                            1,
                          ),
                          _InterMedium12(
                            'Your playtime',
                            GlobalVariables.white,
                            1,
                          )
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {},
                      child: Icon(
                        Icons.clear,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  bool isValid(BookingTime bookingTime) {
    return bookingTime.status == 1;
  }

  String calculateTimeDifference(DateTime startTime, DateTime endTime) {
    String start =
        '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}';
    String end = '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  Widget _InterMedium12(String text, Color color, int maxLines) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
