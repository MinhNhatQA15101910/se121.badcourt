import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/booking.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingWidget extends StatefulWidget {
  const BookingWidget({
    super.key,
  });

  @override
  _BookingWidgetState createState() => _BookingWidgetState();
}

class _BookingWidgetState extends State<BookingWidget> {
  DateTime _startTime = DateTime(2000, 1, 1, 6, 30);
  DateTime _endTime = DateTime(2000, 1, 1, 12, 00);
  List<BookingTime> bookingTimeList = [
    BookingTime(
      id: 1,
      startDate: DateTime(2000, 1, 1, 7, 30),
      endDate: DateTime(2000, 1, 1, 8, 30),
      status: 1,
    ),
    BookingTime(
      id: 2,
      startDate: DateTime(2000, 1, 1, 8, 30),
      endDate: DateTime(2000, 1, 1, 10, 00),
      status: 1,
    ),
    BookingTime(
      id: 3,
      startDate: DateTime(2000, 1, 1, 10, 30),
      endDate: DateTime(2000, 1, 1, 12, 00),
      status: 1,
    ),
  ];

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

      // SizedBox dưới cùng
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
          // Thêm một SizedBox
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
    List<Widget> children =
        generateBookingTimeWidgets(bookingTimeList, _startTime, _endTime);

    return Container(
      padding: EdgeInsets.only(
        top: 12,
        left: 16,
        right: 16,
      ),
      color: GlobalVariables.white,
      child: Column(
        children: [
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
                children: children,
              )
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> generateBookingTimeWidgets(
      List<BookingTime> bookingTimes, DateTime startTime, DateTime endTime) {
    return bookingTimes.map((bookingTime) {
      Duration bookingTimeDifference =
          bookingTime.endDate.difference(bookingTime.startDate);
      double currentHeight = (bookingTimeDifference.inMinutes * 5 / 3) * 0.4;
      Duration marginStartTimediff =
          bookingTime.startDate.difference(startTime);
      double marginTopStartTime = (marginStartTimediff.inMinutes * 5 / 3) * 0.4;
      return Container(
        margin: EdgeInsets.only(left: 40, top: marginTopStartTime + 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: GlobalVariables.white,
          border: Border.all(
            color: GlobalVariables.green,
            width: 1,
          ),
        ),
        height: currentHeight,
      );
    }).toList();
  }
}
