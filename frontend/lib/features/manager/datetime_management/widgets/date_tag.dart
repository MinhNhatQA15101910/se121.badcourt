import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DateTag extends StatelessWidget {
  final DateTime datetime;
  final bool isActived;
  final void Function() onPressed;

  const DateTag({
    super.key,
    required this.datetime,
    required this.isActived,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    String getDay(DateTime date) {
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime inputDate = DateTime(date.year, date.month, date.day);

      if (inputDate == today) {
        return "Today";
      } else {
        return DateFormat('EEE').format(date);
      }
    }

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 62,
        margin: EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isActived ? GlobalVariables.green : GlobalVariables.lightGreen,
          border: Border.all(
            color: isActived ? GlobalVariables.green : GlobalVariables.grey,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                color: GlobalVariables.white,
                border: isActived
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: GlobalVariables.grey,
                          width: 1,
                        ),
                      ),
              ),
              child: Center(
                child: _InterRegular12(
                  getDay(datetime),
                  isActived ? GlobalVariables.green : GlobalVariables.darkGrey,
                  1,
                ),
              ),
            ),
            Container(
              height: 40,
              child: Center(
                child: _InterMedium18(
                  datetime.day.toString(),
                  isActived ? GlobalVariables.white : GlobalVariables.green,
                  1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _InterRegular12(String text, Color color, int maxLines) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _InterMedium18(String text, Color color, int maxLines) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: color,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
