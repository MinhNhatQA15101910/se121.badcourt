import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/booking_time.dart';
import 'package:frontend/models/court.dart';
import 'package:frontend/models/time_period.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/court_hub_provider.dart';

class BookingTimelineWidget extends StatefulWidget {
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
  State<BookingTimelineWidget> createState() => _BookingTimelineWidgetState();
}

class _BookingTimelineWidgetState extends State<BookingTimelineWidget> {
  CourtHubProvider? _courtHubProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupRealtimeListener();
    });
  }

  void _setupRealtimeListener() {
    _courtHubProvider = Provider.of<CourtHubProvider>(context, listen: false);
  }

  @override
  void dispose() {
    if (_courtHubProvider != null) {
      _courtHubProvider!.clearNewOrderPeriods(widget.court.id);
      _courtHubProvider!.clearCourtInactivePeriods(widget.court.id);
    }
    super.dispose();
  }

  // Helper function to convert time to minutes since midnight
  int _timeToMinutes(DateTime time) {
    return time.hour * 60 + time.minute;
  }

  // Chuyển đổi PeriodTime thành BookingTime
  BookingTime? _convertPeriodTimeToBookingTime(
      TimePeriod period, int virtualId) {
    try {
      // Xử lý nhiều định dạng có thể có
      DateTime? startDate;
      DateTime? endDate;

      // Thử parse trực tiếp nếu là ISO format
      try {
        if (period.hourFrom.toIso8601String().contains('T')) {
          startDate = period.hourFrom;
        }
      } catch (e) {
        // Bỏ qua lỗi
      }

      try {
        if (period.hourTo.toIso8601String().contains('T')) {
          endDate = period.hourTo;
        }
      } catch (e) {
        // Bỏ qua lỗi
      }

      // Nếu không phải ISO format, thử parse như HH:MM
      if (startDate == null) {
        try {
          final startParts =
              period.hourFrom.toIso8601String().split('T')[1].split(':');
          if (startParts.length >= 2) {
            final startHour = int.parse(startParts[0]);
            final startMinute = int.parse(startParts[1]);

            startDate = DateTime(
              widget.startTime.year,
              widget.startTime.month,
              widget.startTime.day,
              startHour,
              startMinute,
            );
          }
        } catch (e) {
          // Bỏ qua lỗi
        }
      }

      if (endDate == null) {
        try {
          final endParts = period.hourTo.toIso8601String().split('T')[1].split(':');

          if (endParts.length >= 2) {
            final endHour = int.parse(endParts[0]);
            final endMinute = int.parse(endParts[1]);

            endDate = DateTime(
              widget.startTime.year,
              widget.startTime.month,
              widget.startTime.day,
              endHour,
              endMinute,
            );
          }
        } catch (e) {
          // Bỏ qua lỗi
        }
      }

      // Nếu parse thành công cả hai
      if (startDate != null && endDate != null) {
        // CHỈ LẤY GIỜ VÀ PHÚT, BỎ QUA NGÀY
        final normalizedStartDate = DateTime(
          widget.startTime.year,
          widget.startTime.month,
          widget.startTime.day,
          startDate.hour,
          startDate.minute,
        );

        final normalizedEndDate = DateTime(
          widget.startTime.year,
          widget.startTime.month,
          widget.startTime.day,
          endDate.hour,
          endDate.minute,
        );

        // Tạo BookingTime giống existing booking
        final bookingTime = BookingTime(
          id: virtualId,
          startDate: normalizedStartDate,
          endDate: normalizedEndDate,
          status: 1, // Giống existing booking
        );

        return bookingTime;
      }
    } catch (e) {
      // Bỏ qua lỗi
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CourtHubProvider>(
      builder: (context, courtProvider, child) {
        // BẮT ĐẦU VỚI EXISTING BOOKINGS
        List<BookingTime> allBookings = List.from(widget.bookingTimeList);

        // Lấy realtime periods
        final newOrderPeriods =
            courtProvider.getNewOrderPeriods(widget.court.id);
        final inactivePeriods =
            courtProvider.getCourtInactivePeriods(widget.court.id);

        int virtualId = 10000;

        // CHUYỂN ĐỔI NEW ORDER PERIODS
        for (var period in newOrderPeriods) {
          final bookingTime =
              _convertPeriodTimeToBookingTime(period, virtualId++);
          if (bookingTime != null) {
            allBookings.add(bookingTime);
          }
        }

        // CHUYỂN ĐỔI INACTIVE PERIODS
        for (var period in inactivePeriods) {
          final bookingTime =
              _convertPeriodTimeToBookingTime(period, virtualId++);
          if (bookingTime != null) {
            allBookings.add(bookingTime);
          }
        }

        // XỬ LÝ TẤT CẢ BOOKING GIỐNG NHAU
        List<Widget> bookingOverlays = [];

        for (int i = 0; i < allBookings.length; i++) {
          try {
            var booking = allBookings[i];

            // Kiểm tra intersection
            if (_isBookingIntersectingTimeline(booking)) {
              Widget overlay = _createBookingOverlay(booking, i);
              bookingOverlays.add(overlay);
            }
          } catch (e) {
            // Bỏ qua lỗi
          }
        }

        List<Widget> timeContainer =
            generateTimeContainer(widget.startTime, widget.endTime);
        List<Widget> timeText =
            generateTimeText(widget.startTime, widget.endTime);

        // Tính tổng số booking để hiển thị
        int totalBookingsCount = widget.bookingTimeList.length +
            newOrderPeriods.length +
            inactivePeriods.length;

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
                        'Playtime ' +
                            calculateTimeDifference(
                                widget.startTime, widget.endTime),
                        GlobalVariables.green,
                        1),
                  ),
                  _InterBold14(widget.court.pricePerHour.toString() + ' đ/h',
                      GlobalVariables.green, 1),
                ],
              ),
              SizedBox(height: 12),
              Stack(
                children: [
                  // Base timeline container
                  Container(
                    padding: EdgeInsets.only(left: 40),
                    child: Column(
                      children: timeContainer,
                    ),
                  ),
                  // Time labels
                  Column(
                    children: timeText,
                  ),
                  // Booking overlays
                  ...bookingOverlays,
                ],
              ),
              SizedBox(height: 12),
              // Legend - chỉ hiển thị một dòng với tổng số booking
              Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: GlobalVariables.lightGreen,
                        border: Border.all(
                          color: GlobalVariables.green,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Existing bookings ($totalBookingsCount)',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: GlobalVariables.darkGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Kiểm tra booking có giao với timeline không
  bool _isBookingIntersectingTimeline(BookingTime booking) {
    int timelineStartMinutes = _timeToMinutes(widget.startTime);
    int timelineEndMinutes = _timeToMinutes(widget.endTime);
    int bookingStartMinutes = _timeToMinutes(booking.startDate);
    int bookingEndMinutes = _timeToMinutes(booking.endDate);

    bool intersects = bookingStartMinutes < timelineEndMinutes &&
        bookingEndMinutes > timelineStartMinutes;

    return intersects;
  }

  // Tạo overlay
  Widget _createBookingOverlay(BookingTime booking, int index) {
    // Tính toán vị trí effective
    int timelineStartMinutes = _timeToMinutes(widget.startTime);
    int timelineEndMinutes = _timeToMinutes(widget.endTime);
    int bookingStartMinutes = _timeToMinutes(booking.startDate);
    int bookingEndMinutes = _timeToMinutes(booking.endDate);

    // Effective intersection
    int effectiveStartMinutes = bookingStartMinutes < timelineStartMinutes
        ? timelineStartMinutes
        : bookingStartMinutes;
    int effectiveEndMinutes = bookingEndMinutes > timelineEndMinutes
        ? timelineEndMinutes
        : bookingEndMinutes;

    // Tạo DateTime cho effective range
    DateTime effectiveStart = DateTime(
      widget.startTime.year,
      widget.startTime.month,
      widget.startTime.day,
      effectiveStartMinutes ~/ 60,
      effectiveStartMinutes % 60,
    );

    DateTime effectiveEnd = DateTime(
      widget.startTime.year,
      widget.startTime.month,
      widget.startTime.day,
      effectiveEndMinutes ~/ 60,
      effectiveEndMinutes % 60,
    );

    double top = calculateMarginTop(widget.startTime, effectiveStart);
    double height = calculateHeight(effectiveStart, effectiveEnd);

    // Tính thời gian booking theo phút
    int durationInMinutes = effectiveEnd.difference(effectiveStart).inMinutes;
    bool isShortBooking = durationInMinutes <= 30;

    String timeRange =
        '${effectiveStart.hour.toString().padLeft(2, '0')}:${effectiveStart.minute.toString().padLeft(2, '0')} - ${effectiveEnd.hour.toString().padLeft(2, '0')}:${effectiveEnd.minute.toString().padLeft(2, '0')}';

    bool isFromSignalR = booking.id >= 10000;

    return Positioned(
      top: top,
      left: 40,
      right: 0,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: GlobalVariables.lightGreen,
          border: Border.all(
            color: GlobalVariables.green,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: GlobalVariables.green.withOpacity(0.1),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: isShortBooking
            ? Container() // Nếu booking ngắn, không hiển thị nội dung
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        timeRange,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: GlobalVariables.green,
                        ),
                      ),
                    ),
                    Icon(
                      isFromSignalR ? Icons.new_releases : Icons.lock,
                      size: 14,
                      color: GlobalVariables.green,
                    ),
                  ],
                ),
              ),
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

    int initialHour =
        startTime.minute > 0 ? startTime.hour + 1 : startTime.hour;

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

  double calculateMarginTop(DateTime startTime, DateTime bookingStartTime) {
    int minutesFromStart = bookingStartTime.difference(startTime).inMinutes;
    if (minutesFromStart < 0) minutesFromStart = 0;

    double result = 10.0 + (minutesFromStart / 60.0) * 40.0;
    return result;
  }

  double calculateHeight(DateTime startTime, DateTime endTime) {
    int durationInMinutes = endTime.difference(startTime).inMinutes;
    if (durationInMinutes <= 0) return 0;

    double result = (durationInMinutes / 60.0) * 40.0;
    return result;
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
