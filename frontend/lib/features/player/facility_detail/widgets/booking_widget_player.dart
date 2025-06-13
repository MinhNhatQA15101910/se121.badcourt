import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/player/checkout/screens/checkout_screen.dart';
import 'package:frontend/features/player/facility_detail/widgets/booking_timeline_widget.dart';
import 'package:frontend/features/player/facility_detail/widgets/time_selection_widget.dart';
import 'package:frontend/features/player/facility_detail/services/facility_detail_service.dart';
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
  final _facilityDetailService = FacilityDetailService();

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTimeConstraints();
    });
  }

  void _initializeTimeConstraints() {
    final selectedCourtProvider =
        Provider.of<SelectedCourtProvider>(context, listen: false);
    final facility = selectedCourtProvider.selectedFacility;
    final currentDateTime = selectedCourtProvider.selectedDate;

    if (facility != null && currentDateTime != null) {
      _getFacilityTimeRange(facility, currentDateTime);

      // Set constraints based on facility hours
      setState(() {

        // Set default start time to facility start time
        _selectedStartHour = _facilityStartTime.hour;
        _selectedStartMinute = _facilityStartTime.minute;

        // Set default end time to 1 hour after start time
        _selectedEndHour = _selectedStartHour + 1;
        _selectedEndMinute = _selectedStartMinute;

        // Validate and adjust if needed
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

  // Server-side validation using checkIntersect API
  Future<void> _validateTimeSlotWithServer() async {
    print('🔍 [BookingWidget] Starting server validation...');

    final selectedCourtProvider =
        Provider.of<SelectedCourtProvider>(context, listen: false);
    final courtHubProvider =
        Provider.of<CourtHubProvider>(context, listen: false);
    final originalCourt = selectedCourtProvider.selectedCourt;
    final selectedDate = selectedCourtProvider.selectedDate;

    if (originalCourt == null || selectedDate == null) {
      print('❌ [BookingWidget] Missing court or date data');
      return;
    }

    final court = courtHubProvider.getCourt(originalCourt.id) ?? originalCourt;

    print('🔍 [BookingWidget] Validating court: ${court.id}');
    print('🔍 [BookingWidget] Selected date: $selectedDate');
    print(
        '🔍 [BookingWidget] Time: $_selectedStartHour:$_selectedStartMinute - $_selectedEndHour:$_selectedEndMinute');

    setState(() {
      _isValidatingTime = true;
      _timeErrorMessage = null;
    });

    try {
      // Create DateTime objects for the selected time slot
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

      print('🔍 [BookingWidget] Calling checkIntersect API...');

      // Check with server
      final isValid = await _facilityDetailService.checkIntersect(
        context,
        court.id,
        startDateTime,
        endDateTime,
      );

      print('🔍 [BookingWidget] Server validation result: $isValid');

      setState(() {
        _isValidatingTime = false;
        _isTimeSlotValid = isValid;
        if (!isValid) {
          _timeErrorMessage =
              "This time slot conflicts with an existing booking";
        }
      });
    } catch (e) {
      print('❌ [BookingWidget] Error during server validation: $e');
      setState(() {
        _isValidatingTime = false;
        _isTimeSlotValid = false;
        _timeErrorMessage = "Unable to validate time slot. Please try again.";
      });
    }
  }

  void _validateAndAdjustTimes() {
    print('🔍 [BookingWidget] Starting validation and adjustment...');

    setState(() {
      _timeErrorMessage = null;

      // STEP 1: Ensure start time is within facility hours
      if (_selectedStartHour < _facilityStartTime.hour ||
          (_selectedStartHour == _facilityStartTime.hour &&
              _selectedStartMinute < _facilityStartTime.minute)) {
        _selectedStartHour = _facilityStartTime.hour;
        _selectedStartMinute = _facilityStartTime.minute;
      }

      // STEP 2: Ensure start time is not beyond facility end time
      if (_selectedStartHour > _facilityEndTime.hour ||
          (_selectedStartHour == _facilityEndTime.hour &&
              _selectedStartMinute >= _facilityEndTime.minute)) {
        // This is an invalid state - start time can't be at or after facility end time
        _selectedStartHour = _facilityEndTime.hour - 1;
        _selectedStartMinute = 0;
        _timeErrorMessage =
            "Start time cannot be at or after facility closing time";
      }

      // STEP 3: Ensure end time is after start time
      if (_selectedEndHour < _selectedStartHour ||
          (_selectedEndHour == _selectedStartHour &&
              _selectedEndMinute <= _selectedStartMinute)) {
        _selectedEndHour = _selectedStartHour + 1;
        _selectedEndMinute = _selectedStartMinute;
      }

      // STEP 4: Ensure end time is within facility hours
      if (_selectedEndHour > _facilityEndTime.hour ||
          (_selectedEndHour == _facilityEndTime.hour &&
              _selectedEndMinute > _facilityEndTime.minute)) {
        _selectedEndHour = _facilityEndTime.hour;
        _selectedEndMinute = _facilityEndTime.minute;
      }

      // STEP 5: Check for booking conflicts (local validation)
      if (_isTimeSlotOverlapping()) {
        _timeErrorMessage = "Selected time overlaps with an existing booking";
      }

      // STEP 6: Ensure minimum booking duration (e.g., 30 minutes)
      DateTime startTime =
          DateTime(2000, 1, 1, _selectedStartHour, _selectedStartMinute);
      DateTime endTime =
          DateTime(2000, 1, 1, _selectedEndHour, _selectedEndMinute);

      if (endTime.difference(startTime).inMinutes < 30) {
        _selectedEndHour = _selectedStartHour;
        _selectedEndMinute = _selectedStartMinute + 30;

        // Handle minute overflow
        if (_selectedEndMinute >= 60) {
          _selectedEndHour += 1;
          _selectedEndMinute -= 60;
        }

        // If this pushes end time beyond facility hours, adjust start time instead
        if (_selectedEndHour > _facilityEndTime.hour ||
            (_selectedEndHour == _facilityEndTime.hour &&
                _selectedEndMinute > _facilityEndTime.minute)) {
          _selectedEndHour = _facilityEndTime.hour;
          _selectedEndMinute = _facilityEndTime.minute;

          // Adjust start time to be 30 minutes before end time
          startTime = DateTime(2000, 1, 1, _selectedEndHour, _selectedEndMinute)
              .subtract(Duration(minutes: 30));
          _selectedStartHour = startTime.hour;
          _selectedStartMinute = startTime.minute;
        }

      }
    });

    // Always call server validation, regardless of local validation result
    print('🔍 [BookingWidget] Calling server validation...');
    _validateTimeSlotWithServer();
  }

  bool _isTimeSlotOverlapping() {
    DateTime selectedStart =
        DateTime(2000, 1, 1, _selectedStartHour, _selectedStartMinute);
    DateTime selectedEnd =
        DateTime(2000, 1, 1, _selectedEndHour, _selectedEndMinute);

    for (var booking in _bookingTimeListDisable) {
      if ((selectedStart.isBefore(booking.endDate)) &&
          (selectedEnd.isAfter(booking.startDate))) {
        return true;
      }
    }

    return false;
  }


  void _bookTimeSlot() async {
    final selectedCourtProvider =
        Provider.of<SelectedCourtProvider>(context, listen: false);
    final courtHubProvider =
        Provider.of<CourtHubProvider>(context, listen: false);
    final originalCourt = selectedCourtProvider.selectedCourt;
    final selectedDate = selectedCourtProvider.selectedDate;

    if (originalCourt == null || selectedDate == null) return;

    // Use real-time court data for booking validation
    final court = courtHubProvider.getCourt(originalCourt.id) ?? originalCourt;

    // Show loading indicator
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
      // Call checkIntersect API directly when booking
      final isAvailable = await _facilityDetailService.checkIntersect(
        context,
        court.id,
        startDate,
        endDate,
      );

      setState(() {
        _isValidatingTime = false;
      });

      if (isAvailable) {
        // Time slot is available, proceed with booking
        final checkoutProvider =
            Provider.of<CheckoutProvider>(context, listen: false);

        checkoutProvider.startDate = startDate;
        checkoutProvider.endDate = endDate;
        checkoutProvider.court = court; // Use real-time court data

        Navigator.of(context).pushNamed(CheckoutScreen.routeName);
      } else {
        IconSnackBar.show(
          context,
          label: 'The time has overlapped.',
          snackBarType: SnackBarType.alert,
        );
      }
    } catch (error) {
      setState(() {
        _isValidatingTime = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi kiểm tra thời gian: ${error.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Get allowed hours for start time
  List<int> _getAllowedStartHours() {
    List<int> allowedHours = [];
    // Start hours should be from facility start to one hour before facility end
    for (int hour = _facilityStartTime.hour;
        hour < _facilityEndTime.hour;
        hour++) {
      allowedHours.add(hour);
    }
    return allowedHours;
  }

  // Get allowed minutes for start time based on selected hour
  List<int> _getAllowedStartMinutes(int hour) {
    List<int> baseMinutes = [0, 15, 30, 45];

    // If at facility start hour, filter minutes
    if (hour == _facilityStartTime.hour) {
      return baseMinutes
          .where((minute) => minute >= _facilityStartTime.minute)
          .toList();
    }

    // If at facility end hour, no valid start minutes (should not happen with proper hour filtering)
    if (hour == _facilityEndTime.hour) {
      return [];
    }

    return baseMinutes;
  }

  // Get allowed hours for end time based on selected start time
  List<int> _getAllowedEndHours() {
    List<int> allowedHours = [];

    // End hours should be from start hour to facility end hour
    int minEndHour = _selectedStartHour;
    if (_selectedStartMinute > 0)
      minEndHour +=
          1; // If start has minutes, end hour must be at least start+1

    for (int hour = minEndHour; hour <= _facilityEndTime.hour; hour++) {
      allowedHours.add(hour);
    }

    return allowedHours;
  }

  // Get allowed minutes for end time based on selected hour
  List<int> _getAllowedEndMinutes(int hour) {
    List<int> baseMinutes = [0, 15, 30, 45];

    // If at start hour, filter minutes to be after start minute
    if (hour == _selectedStartHour) {
      return baseMinutes
          .where((minute) => minute > _selectedStartMinute)
          .toList();
    }

    // If at facility end hour, filter minutes to be at or before facility end minute
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
    print(
        '🔍 [BookingWidget] Time changed - Start: ${startHour ?? _selectedStartHour}:${startMinute ?? _selectedStartMinute}, End: ${endHour ?? _selectedEndHour}:${endMinute ?? _selectedEndMinute}');

    setState(() {
      bool needsValidation = false;

      // Update start hour if provided
      if (startHour != null && startHour != _selectedStartHour) {
        _selectedStartHour = startHour;
        needsValidation = true;
      }

      // Update start minute if provided
      if (startMinute != null && startMinute != _selectedStartMinute) {
        _selectedStartMinute = startMinute;
        needsValidation = true;
      }

      // Update end hour if provided
      if (endHour != null && endHour != _selectedEndHour) {
        _selectedEndHour = endHour;
        needsValidation = true;
      }

      // Update end minute if provided
      if (endMinute != null && endMinute != _selectedEndMinute) {
        _selectedEndMinute = endMinute;
        needsValidation = true;
      }

      // Always validate when time changes
      if (needsValidation) {
        print('🔍 [BookingWidget] Time changed, triggering validation...');
        // Reset validation state immediately
        _isTimeSlotValid = true;
        _timeErrorMessage = null;
      }
    });

    // Call validation after setState
    if (startHour != null ||
        startMinute != null ||
        endHour != null ||
        endMinute != null) {
      // Add a small delay to avoid too many rapid API calls
      Future.delayed(Duration(milliseconds: 500), () {
        _validateAndAdjustTimes();
      });
    }
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

        // Use real-time court data if available, otherwise use original court
        final court =
            courtHubProvider.getCourt(originalCourt.id) ?? originalCourt;
        courtHubProvider.isConnected(originalCourt.id);

        // Update data when court changes (real-time updates)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _getFacilityTimeRange(facility, currentDateTime);
          _getOrderPeriodsByDate(
              court, currentDateTime); // Use real-time court data
        });

        return Column(
          children: [
            // Booking timeline visualization
            BookingTimelineWidget(
              startTime: _facilityStartTime,
              endTime: _facilityEndTime,
              bookingTimeList: _bookingTimeListDisable,
              court: court, // Use real-time court data
              onRemoveBooking: _handleRemoveBooking,
            ),

            SizedBox(height: 16),

            // Time selection section
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
              court: court, // Use real-time court data
              onBookPressed: _bookTimeSlot,
              errorMessage: _timeErrorMessage,
              isValidating: _isValidatingTime,
              isTimeSlotValid: _isTimeSlotValid,
            ),
          ],
        );
      },
    );
  }
}
