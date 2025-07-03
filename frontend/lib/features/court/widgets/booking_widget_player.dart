import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/court/services/court_service.dart';
import 'package:frontend/features/player/checkout/screens/checkout_screen.dart';
import 'package:frontend/features/court/widgets/booking_timeline_widget.dart';
import 'package:frontend/features/court/widgets/time_selection_widget.dart';
import 'package:frontend/models/booking_time.dart';
import 'package:frontend/models/court.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/models/time_period.dart';
import 'package:frontend/providers/checkout_provider.dart';
import 'package:frontend/providers/player/selected_court_provider.dart';
import 'package:frontend/providers/court_hub_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BookingWidgetPlayer extends StatefulWidget {
  const BookingWidgetPlayer({super.key});

  @override
  State<BookingWidgetPlayer> createState() => _BookingWidgetPlayerState();
}

class _BookingWidgetPlayerState extends State<BookingWidgetPlayer> {
  // Services
  final _courtService = CourtService();

  // Facility time range
  DateTime _facilityStartTime = DateTime(2000, 1, 1, 6, 0);
  DateTime _facilityEndTime = DateTime(2000, 1, 1, 22, 0);

  // Existing bookings
  List<TimePeriod> _orderPeriods = [];
  List<BookingTime> _bookingTimeListDisable = [];

  // Selected time
  int _selectedStartHour = 8;
  int _selectedStartMinute = 0;
  int _selectedEndHour = 9;
  int _selectedEndMinute = 0;

  // Error message and validation state
  String? _timeErrorMessage;
  bool _isValidatingTime = false;
  bool _isTimeSlotValid = true;
  bool _isTimeSlotChecked = false;
  bool _hasCheckedTimeSlotOnce = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTimeConstraints();
    });
  }

  // MODIFIED: Check time slot availability
  Future<bool> _checkTimeSlotAvailability() async {
    print('🔍 [BookingWidget] Manual time slot check triggered');

    final selectedCourtProvider =
        Provider.of<SelectedCourtProvider>(context, listen: false);
    final courtHubProvider =
        Provider.of<CourtHubProvider>(context, listen: false);
    final originalCourt = selectedCourtProvider.selectedCourt;
    final selectedDate = selectedCourtProvider.selectedDate;

    if (originalCourt == null || selectedDate == null) {
      print('❌ [BookingWidget] Missing court or date data');
      return false;
    }

    final court = courtHubProvider.getCourt(originalCourt.id) ?? originalCourt;

    print('🔍 [BookingWidget] Checking court: ${court.id}');
    print('🔍 [BookingWidget] Selected date: $selectedDate');
    print(
        '🔍 [BookingWidget] Time: $_selectedStartHour:$_selectedStartMinute - $_selectedEndHour:$_selectedEndMinute');

    setState(() {
      _isValidatingTime = true;
      _timeErrorMessage = null;
    });

    try {
      final startDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        _selectedStartHour,
        _selectedStartMinute,
      );

      final endDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        _selectedEndHour,
        _selectedEndMinute,
      );

      final response = await _courtService.checkIntersect(
        context,
        court.id,
        startDateTime,
        endDateTime,
      );

      final isValid = response["success"] ?? false;

      setState(() {
        _isValidatingTime = false;
        _isTimeSlotValid = isValid;
        _isTimeSlotChecked = true;
        _timeErrorMessage = isValid ? null : response["errorMessage"];
      });

      return isValid;
    } catch (e) {
      print('❌ [BookingWidget] Error during server validation: $e');

      setState(() {
        _isValidatingTime = false;
        _isTimeSlotValid = false;
        _isTimeSlotChecked = true;
        _timeErrorMessage = "Unable to validate time slot. Please try again.";
      });

      return false;
    }
  }

  // MODIFIED: Update court inactive - now includes validation check
  void _updateCourtInactive() async {
    final selectedCourtProvider =
        Provider.of<SelectedCourtProvider>(context, listen: false);
    final courtHubProvider =
        Provider.of<CourtHubProvider>(context, listen: false);
    final originalCourt = selectedCourtProvider.selectedCourt;
    final selectedDate = selectedCourtProvider.selectedDate;

    if (originalCourt == null || selectedDate == null) return;

    final court = courtHubProvider.getCourt(originalCourt.id) ?? originalCourt;

    setState(() {
      _isValidatingTime = true;
    });

    // Combine selected date with selected time
    final startDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      _selectedStartHour,
      _selectedStartMinute,
    );

    final endDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      _selectedEndHour,
      _selectedEndMinute,
    );

    try {
      // Call the updateCourtInactive API
      await _courtService.updateCourtInactive(
        context,
        court.id,
        startDate,
        endDate,
      );

      setState(() {
        _isValidatingTime = false;
        // Reset validation state after successful update
        _isTimeSlotChecked = false;
        _isTimeSlotValid = true;
        _timeErrorMessage = null;
      });
    } catch (error) {
      setState(() {
        _isValidatingTime = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Error updating court inactive period: ${error.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _initializeTimeConstraints() {
    final selectedCourtProvider =
        Provider.of<SelectedCourtProvider>(context, listen: false);
    final facility = selectedCourtProvider.selectedFacility;
    final currentDateTime = selectedCourtProvider.selectedDate;

    if (facility != null && currentDateTime != null) {
      _getFacilityTimeRange(facility, currentDateTime);
      setState(() {
        _selectedStartHour = _facilityStartTime.hour;
        _selectedStartMinute = _facilityStartTime.minute;
        _selectedEndHour = _selectedStartHour + 1;
        _selectedEndMinute = _selectedStartMinute;
        _validateAndAdjustTimes();
      });
    }
  }

  void _getFacilityTimeRange(Facility facility, DateTime currentDateTime) {
    String day = DateFormat('EEEE').format(currentDateTime).toLowerCase();
    final schedule = facility.activeAt?.schedule;

    if (schedule != null && schedule.containsKey(day)) {
      final periodTime = schedule[day];
      if (periodTime != null) {
        setState(() {
          final dateFormat = DateFormat.Hm();
          _facilityStartTime = dateFormat.parse(periodTime.hourFrom);
          _facilityEndTime = dateFormat.parse(periodTime.hourTo);
        });
      }
    }
  }

  void _getOrderPeriodsByDate(Court court, DateTime currentDateTime) {
    DateTime date = currentDateTime;
    _orderPeriods = court.orderPeriods
        .where((period) =>
            period.hourFrom.year == date.year &&
            period.hourFrom.month == date.month &&
            period.hourFrom.day == date.day)
        .toList();

    List<BookingTime> bookingTimeListDisable = [];
    int index = 0;
    for (var period in _orderPeriods) {
      int startHour = period.hourFrom.hour;
      int startMinute = period.hourFrom.minute;
      int endHour = period.hourTo.hour;
      int endMinute = period.hourTo.minute;

      DateTime startDate = DateTime(2000, 1, 1, startHour, startMinute);
      DateTime endDate = DateTime(2000, 1, 1, endHour, endMinute);

      bookingTimeListDisable.add(
        BookingTime(
          id: index++,
          startDate: startDate,
          endDate: endDate,
          status: 0,
        ),
      );
    }

    _bookingTimeListDisable = bookingTimeListDisable;
  }

  void _handleRemoveBooking(int bookingId) {
    setState(() {
      _bookingTimeListDisable.removeWhere((booking) => booking.id == bookingId);
    });
  }

  void _validateAndAdjustTimes() {
    print('🔍 [BookingWidget] Starting local validation and adjustment...');

    setState(() {
      _timeErrorMessage = null;
      _isTimeSlotChecked = false; // Reset validation state when time changes

      // Local validation logic (same as before)
      if (_selectedStartHour < _facilityStartTime.hour ||
          (_selectedStartHour == _facilityStartTime.hour &&
              _selectedStartMinute < _facilityStartTime.minute)) {
        _selectedStartHour = _facilityStartTime.hour;
        _selectedStartMinute = _facilityStartTime.minute;
      }

      if (_selectedStartHour > _facilityEndTime.hour ||
          (_selectedStartHour == _facilityEndTime.hour &&
              _selectedStartMinute >= _facilityEndTime.minute)) {
        _selectedStartHour = _facilityEndTime.hour - 1;
        _selectedStartMinute = 0;
        _timeErrorMessage =
            "Start time cannot be at or after facility closing time";
      }

      if (_selectedEndHour < _selectedStartHour ||
          (_selectedEndHour == _selectedStartHour &&
              _selectedEndMinute <= _selectedStartMinute)) {
        _selectedEndHour = _selectedStartHour + 1;
        _selectedEndMinute = _selectedStartMinute;
      }

      if (_selectedEndHour > _facilityEndTime.hour ||
          (_selectedEndHour == _facilityEndTime.hour &&
              _selectedEndMinute > _facilityEndTime.minute)) {
        _selectedEndHour = _facilityEndTime.hour;
        _selectedEndMinute = _facilityEndTime.minute;
      }

      DateTime startTime =
          DateTime(2000, 1, 1, _selectedStartHour, _selectedStartMinute);
      DateTime endTime =
          DateTime(2000, 1, 1, _selectedEndHour, _selectedEndMinute);

      if (endTime.difference(startTime).inMinutes < 30) {
        _selectedEndHour = _selectedStartHour;
        _selectedEndMinute = _selectedStartMinute + 30;

        if (_selectedEndMinute >= 60) {
          _selectedEndHour += 1;
          _selectedEndMinute -= 60;
        }

        if (_selectedEndHour > _facilityEndTime.hour ||
            (_selectedEndHour == _facilityEndTime.hour &&
                _selectedEndMinute > _facilityEndTime.minute)) {
          _selectedEndHour = _facilityEndTime.hour;
          _selectedEndMinute = _facilityEndTime.minute;

          startTime = DateTime(2000, 1, 1, _selectedEndHour, _selectedEndMinute)
              .subtract(Duration(minutes: 30));
          _selectedStartHour = startTime.hour;
          _selectedStartMinute = startTime.minute;
        }
      }
    });
  }

  // MODIFIED: Book time slot - now includes final validation
  void _bookTimeSlot() async {
    final selectedCourtProvider =
        Provider.of<SelectedCourtProvider>(context, listen: false);
    final courtHubProvider =
        Provider.of<CourtHubProvider>(context, listen: false);
    final originalCourt = selectedCourtProvider.selectedCourt;
    final selectedDate = selectedCourtProvider.selectedDate;

    if (originalCourt == null || selectedDate == null) return;

    final court = courtHubProvider.getCourt(originalCourt.id) ?? originalCourt;

    setState(() {
      _isValidatingTime = true;
    });

    // Combine selected date with selected time
    final startDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      _selectedStartHour,
      _selectedStartMinute,
    );

    final endDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      _selectedEndHour,
      _selectedEndMinute,
    );

    try {
      // Final check before booking (double-check)
      final isAvailable = await _courtService.checkIntersect(
        context,
        court.id,
        startDate,
        endDate,
      );

      setState(() {
        _isValidatingTime = false;
      });

      if (isAvailable["success"]) {
        // Time slot is available, proceed with booking
        final checkoutProvider =
            Provider.of<CheckoutProvider>(context, listen: false);
        checkoutProvider.startDate = startDate;
        checkoutProvider.endDate = endDate;
        checkoutProvider.court = court;

        Navigator.of(context).pushNamed(CheckoutScreen.routeName);
      } else {
        // Reset validation state if booking failed
        setState(() {
          _isTimeSlotChecked = false;
          _isTimeSlotValid = false;
          _timeErrorMessage = "Time slot is no longer available";
        });

        IconSnackBar.show(
          context,
          label:
              'The time slot is no longer available. Please select a different time.',
          snackBarType: SnackBarType.alert,
        );
      }
    } catch (error) {
      setState(() {
        _isValidatingTime = false;
        _isTimeSlotChecked = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during booking: ${error.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Get allowed hours for start time
  List<int> _getAllowedStartHours() {
    List<int> allowedHours = [];
    for (int hour = _facilityStartTime.hour;
        hour < _facilityEndTime.hour;
        hour++) {
      allowedHours.add(hour);
    }
    return allowedHours;
  }

  List<int> _getAllowedStartMinutes(int hour) {
    List<int> baseMinutes = [0, 15, 30, 45];

    if (hour == _facilityStartTime.hour) {
      return baseMinutes
          .where((minute) => minute >= _facilityStartTime.minute)
          .toList();
    }

    if (hour == _facilityEndTime.hour) {
      return [];
    }

    return baseMinutes;
  }

  List<int> _getAllowedEndHours() {
    List<int> allowedHours = [];

    int minEndHour = _selectedStartHour;
    if (_selectedStartMinute > 0) minEndHour += 1;

    for (int hour = minEndHour; hour <= _facilityEndTime.hour; hour++) {
      allowedHours.add(hour);
    }
    return allowedHours;
  }

  List<int> _getAllowedEndMinutes(int hour) {
    List<int> baseMinutes = [0, 15, 30, 45];

    if (hour == _selectedStartHour) {
      return baseMinutes
          .where((minute) => minute > _selectedStartMinute)
          .toList();
    }

    if (hour == _facilityEndTime.hour) {
      return baseMinutes
          .where((minute) => minute <= _facilityEndTime.minute)
          .toList();
    }

    return baseMinutes;
  }

  void _onTimeChanged({
  int? startHour,
  int? startMinute,
  int? endHour,
  int? endMinute,
}) {
  print('🔍 [BookingWidget] Time changed - Start: ${startHour ?? _selectedStartHour}:${startMinute ?? _selectedStartMinute}, '
        'End: ${endHour ?? _selectedEndHour}:${endMinute ?? _selectedEndMinute}');

  setState(() {
    bool hasChanged = false;

    if (startHour != null && startHour != _selectedStartHour) {
      _selectedStartHour = startHour;
      hasChanged = true;
    }

    if (startMinute != null && startMinute != _selectedStartMinute) {
      _selectedStartMinute = startMinute;
      hasChanged = true;
    }

    if (endHour != null && endHour != _selectedEndHour) {
      _selectedEndHour = endHour;
      hasChanged = true;
    }

    if (endMinute != null && endMinute != _selectedEndMinute) {
      _selectedEndMinute = endMinute;
      hasChanged = true;
    }

    if (hasChanged) {
      _validateAndAdjustTimes();
    }
  });
}


  @override
  Widget build(BuildContext context) {
    return Consumer2<SelectedCourtProvider, CourtHubProvider>(
      builder: (context, selectedCourtProvider, courtHubProvider, child) {
        final facility = selectedCourtProvider.selectedFacility;
        final originalCourt = selectedCourtProvider.selectedCourt;
        final currentDateTime = selectedCourtProvider.selectedDate;

        if (facility == null ||
            originalCourt == null ||
            currentDateTime == null) {
          return Container(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                'No court selected',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: GlobalVariables.darkGrey,
                ),
              ),
            ),
          );
        }

        final court =
            courtHubProvider.getCourt(originalCourt.id) ?? originalCourt;
        courtHubProvider.isConnected(originalCourt.id);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _getFacilityTimeRange(facility, currentDateTime);
          _getOrderPeriodsByDate(court, currentDateTime);
        });

        return Column(
          children: [
            BookingTimelineWidget(
              startTime: _facilityStartTime,
              endTime: _facilityEndTime,
              bookingTimeList: _bookingTimeListDisable,
              court: court,
              onRemoveBooking: _handleRemoveBooking,
            ),
            SizedBox(height: 16),
            TimeSelectionWidget(
              selectedStartHour: _selectedStartHour,
              selectedStartMinute: _selectedStartMinute,
              selectedEndHour: _selectedEndHour,
              selectedEndMinute: _selectedEndMinute,
              facilityStartTime: _facilityStartTime,
              facilityEndTime: _facilityEndTime,
              getAllowedStartHours: _getAllowedStartHours,
              getAllowedStartMinutes: _getAllowedStartMinutes,
              getAllowedEndHours: _getAllowedEndHours,
              getAllowedEndMinutes: _getAllowedEndMinutes,
              onTimeChanged: _onTimeChanged,
              court: court,
              onUpdateInactivePressed: _updateCourtInactive,
              onBookPressed: _bookTimeSlot,
              onCheckTimeSlot: _checkTimeSlotAvailability,
              errorMessage: _timeErrorMessage,
              isValidating: _isValidatingTime,
              isTimeSlotValid: _isTimeSlotValid,
              isTimeSlotChecked: _isTimeSlotChecked,
            ),
          ],
        );
      },
    );
  }
}
