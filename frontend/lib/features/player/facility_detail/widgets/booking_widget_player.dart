import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/player/facility_detail/widgets/timespan_player_container.dart';
import 'package:frontend/models/booking.dart';
import 'package:frontend/models/court.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/models/order_period.dart';
import 'package:frontend/models/period_time.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BookingWidgetPlayer extends StatefulWidget {
  final Facility facility;
  final Court court;
  final DateTime currentDateTime;

  const BookingWidgetPlayer({
    super.key,
    required this.facility,
    required this.court,
    required this.currentDateTime,
  });

  @override
  State<BookingWidgetPlayer> createState() => _BookingWidgetPlayerState();
}

class _BookingWidgetPlayerState extends State<BookingWidgetPlayer> {
  DateTime _startTime = DateTime(2000, 1, 1, 6, 30);
  DateTime _endTime = DateTime(2000, 1, 1, 12, 00);
  List<OrderPeriod> _orderPeriods = [];
  List<BookingTime> _bookingTimeListDisable = [];

  void _getTime() {
    String day =
        DateFormat('EEEE').format(widget.currentDateTime).toLowerCase();

    if (widget.facility.activeAt.schedule.containsKey(day)) {
      PeriodTime periodTime = widget.facility.activeAt.schedule[day]!;
      int startTime = periodTime.hourFrom;
      int endTime = periodTime.hourTo;
      setState(() {
        _startTime = DateTime.fromMillisecondsSinceEpoch(startTime);
        _endTime = DateTime.fromMillisecondsSinceEpoch(endTime);
      });
    }
  }

  void _getOrderPeriodsByDate() {
    _orderPeriods = widget.court.getOrderPeriodsByDate(widget.currentDateTime);

    List<BookingTime> bookingTimeListDisable = [];
    int index = 0;
    for (var period in _orderPeriods) {
      // Extract hours and minutes from period.hourFrom and period.hourTo
      int startHour = period.hourFrom.hour;
      int startMinute = period.hourFrom.minute;
      int endHour = period.hourTo.hour;
      int endMinute = period.hourTo.minute;

      // Create DateTime objects for startDate and endDate with fixed date January 1, 2000
      DateTime startDate = DateTime(2000, 1, 1, startHour, startMinute);
      DateTime endDate = DateTime(2000, 1, 1, endHour, endMinute);

      // Add BookingTime to bookingTimeListDisable
      bookingTimeListDisable.add(
        BookingTime(
          id: index++,
          startDate: startDate,
          endDate: endDate,
          status: 0,
        ),
      );
    }
    // Set _bookingTimeListDisable to the generated list
    _bookingTimeListDisable = bookingTimeListDisable;
  }

  @override
  void initState() {
    super.initState();
    _getTime();
    _getOrderPeriodsByDate();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> generateTimeContainer(DateTime startTime, DateTime endTime) {
      List<Widget> children = [];

      // Container trên cùng
      children.add(Container(
        height: 10,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: GlobalVariables.grey),
          ),
        ),
      ));

      // Thêm container cho phút bắt đầu nếu khác 0
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

      // Tạo container cho mỗi giờ
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

      // Thêm container cho phút kết thúc nếu khác 0
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

      children.add(SizedBox(
        height: 10,
      ));

      return children;
    }

    List<Widget> generateTimeText(DateTime startTime, DateTime endTime) {
      List<Widget> children = [];

      // Thêm text cho thời gian bắt đầu
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

      // Tạo vòng lặp cho các giờ chẵn
      int initialHour =
          startTime.minute > 0 ? startTime.hour + 1 : startTime.hour;

      for (int i = initialHour; i <= endTime.hour; i++) {
        // Thêm container cho mỗi giờ
        children.add(Container(
          height: 20,
          child: Text(
            '${i.toString().padLeft(2, '0')}:00', // Giờ
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: GlobalVariables.darkGrey,
            ),
          ),
        ));

        // Kiểm tra nếu không phải là thời gian cuối cùng
        if (i < endTime.hour) {
          children.add(SizedBox(height: 20));
        }
      }

      // Thêm text cho thời gian kết thúc
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

    List<Widget> timeContainer = generateTimeContainer(_startTime, _endTime);
    List<Widget> timeText = generateTimeText(_startTime, _endTime);
    List<Widget> timespanContainer = generateBookingTimeWidgets(
        _bookingTimeListDisable, _startTime, _endTime);

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
                    'Playtime ' + calculateTimeDifference(_startTime, _endTime),
                    GlobalVariables.green,
                    1),
              ),
              _InterBold14(widget.court.pricePerHour.toString() + ' đ/h',
                  GlobalVariables.green, 1),
            ],
          ),
          SizedBox(
            height: 12,
          ),
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
          SizedBox(
            height: 12,
          )
        ],
      ),
    );
  }

  Widget _InterBold14(String text, Color color, int maxLines) {
    return Container(
      padding: EdgeInsets.only(
        top: 4,
      ),
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
      padding: EdgeInsets.only(
        top: 4,
      ),
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

  List<Widget> generateBookingTimeWidgets(
      List<BookingTime> bookingTimeList, DateTime startTime, DateTime endTime) {
    List<Widget> widgets = [];

    for (var bookingTime in bookingTimeList) {
      double marginTop = calculateMarginTop(startTime, bookingTime.startDate);
      double height =
          calculateHeight(bookingTime.startDate, bookingTime.endDate);

      widgets.add(
        TimespanPlayerContainer(
          bookingTime: bookingTime,
          marginTop: marginTop,
          height: height,
          onUnlockPress: () {},
        ),
      );
    }

    return widgets;
  }

  double calculateMarginTop(DateTime startTime, DateTime bookingStartTime) {
    int minutesFromStart =
        (bookingStartTime.difference(startTime).inMinutes).abs();

    // Return the margin top based on your scaling logic
    return (minutesFromStart * 5 / 3) *
        0.4; // Adjust multiplier and scale as needed
  }

  double calculateHeight(DateTime startTime, DateTime endTime) {
    int durationInMinutes = endTime.difference(startTime).inMinutes;
    return (durationInMinutes * 5 / 3) *
        0.4; // Adjust multiplier and scale as needed
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
}
