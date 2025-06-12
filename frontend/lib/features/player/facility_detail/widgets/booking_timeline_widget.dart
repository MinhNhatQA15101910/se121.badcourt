import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/booking_time.dart';
import 'package:frontend/models/court.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingTimelineWidget extends StatelessWidget {
  final DateTime startTime;
  final DateTime endTime;
  final List<BookingTime> bookingTimeList;
  final Court court;
  final Function(int) onRemoveBooking;

  const BookingTimelineWidget({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.bookingTimeList,
    required this.court,
    required this.onRemoveBooking,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> timeContainer = generateTimeContainer(startTime, endTime);
    List<Widget> timeText = generateTimeText(startTime, endTime);
    List<Widget> timespanContainer = generateBookingTimeWidgets(
        bookingTimeList, startTime, endTime);

    return Container(
      padding: EdgeInsets.only(
        top: 12,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: GlobalVariables.white,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _InterMedium14(
                    'Playtime ' + calculateTimeDifference(startTime, endTime),
                    GlobalVariables.green,
                    1),
              ),
              _InterBold14(court.pricePerHour.toString() + ' đ/h',
                  GlobalVariables.green, 1),
            ],
          ),
          SizedBox(height: 12),
          Stack(
            children: [
              Container(
                padding: EdgeInsets.only(left: 40),
                child: Column(
                  children: timeContainer,
                ),
              ),
              Column(
                children: timeText,
              ),
              Stack(
                children: timespanContainer,
              )
            ],
          ),
          SizedBox(height: 12)
        ],
      ),
    );
  }

  List<Widget> generateTimeContainer(DateTime startTime, DateTime endTime) {
    List<Widget> children = [];

    children.add(Container(
      height: 10,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: GlobalVariables.grey),
        ),
      ),
    ));

    if (startTime.minute != 0) {
      double height = 20;
      children.add(Container(
        height: height,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: GlobalVariables.grey),
            left: BorderSide(color: GlobalVariables.grey),
            right: BorderSide(color: GlobalVariables.grey),
          ),
        ),
      ));
    }

    int totalMinutes = endTime.difference(startTime).inMinutes;
    int effectiveMinutes = totalMinutes - startTime.minute - endTime.minute;
    int hours = effectiveMinutes ~/ 60;

    DateTime currentTime = startTime.add(Duration(minutes: startTime.minute));

    for (int i = 0; i < hours; i++) {
      currentTime = currentTime.add(Duration(minutes: 60));
      children.add(Container(
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: GlobalVariables.grey),
            left: BorderSide(color: GlobalVariables.grey),
            right: BorderSide(color: GlobalVariables.grey),
          ),
        ),
      ));
    }

    if (endTime.minute != 0) {
      double height = 20;
      children.add(Container(
        height: height,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: GlobalVariables.grey),
            left: BorderSide(color: GlobalVariables.grey),
            right: BorderSide(color: GlobalVariables.grey),
          ),
        ),
      ));
    }

    children.add(SizedBox(height: 10));

    return children;
  }

  List<Widget> generateTimeText(DateTime startTime, DateTime endTime) {
    List<Widget> children = [];

    if (startTime.minute > 0) {
      children.add(Container(
        height: 20,
        child: Text(
          '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: GlobalVariables.darkGrey,
          ),
        ),
      ));
    }

    int initialHour = startTime.minute > 0 ? startTime.hour + 1 : startTime.hour;

    for (int i = initialHour; i <= endTime.hour; i++) {
      children.add(Container(
        height: 20,
        child: Text(
          '${i.toString().padLeft(2, '0')}:00',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: GlobalVariables.darkGrey,
          ),
        ),
      ));

      if (i < endTime.hour) {
        children.add(SizedBox(height: 20));
      }
    }

    if (endTime.minute > 0) {
      children.add(Container(
        height: 20,
        child: Text(
          '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: GlobalVariables.darkGrey,
          ),
        ),
      ));
    }

    return children;
  }

  List<Widget> generateBookingTimeWidgets(
      List<BookingTime> bookingTimeList, DateTime startTime, DateTime endTime) {
    List<Widget> widgets = [];

    for (var bookingTime in bookingTimeList) {
      double marginTop = calculateMarginTop(startTime, bookingTime.startDate);
      double height = calculateHeight(bookingTime.startDate, bookingTime.endDate);

      widgets.add(
        Positioned(
          top: marginTop,
          left: 40,
          right: 0,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              border: Border.all(color: Colors.red),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                'Booked',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  double calculateMarginTop(DateTime startTime, DateTime bookingStartTime) {
    int minutesFromStart = bookingStartTime.difference(startTime).inMinutes;
    if (minutesFromStart < 0) minutesFromStart = 0;
    return (minutesFromStart * 5 / 3) * 0.4;
  }

  double calculateHeight(DateTime startTime, DateTime endTime) {
    int durationInMinutes = endTime.difference(startTime).inMinutes;
    return (durationInMinutes * 5 / 3) * 0.4;
  }

  String calculateTimeDifference(DateTime startTime, DateTime endTime) {
    int startHour = startTime.hour;
    int startMinute = startTime.minute;
    int endHour = endTime.hour;
    int endMinute = endTime.minute;

    String start = '$startHour:${startMinute.toString().padLeft(2, '0')}';
    String end = '$endHour:${endMinute.toString().padLeft(2, '0')}';

    return '$start - $end';
  }

  Widget _InterBold14(String text, Color color, int maxLines) {
    return Container(
      padding: EdgeInsets.only(top: 4),
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

  Widget _InterMedium14(String text, Color color, int maxLines) {
    return Container(
      padding: EdgeInsets.only(top: 4),
      child: Text(
        text,
        textAlign: TextAlign.start,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
