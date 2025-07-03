import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/court/widgets/time_picker_bottom_sheet.dart';
import 'package:frontend/models/court.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TimeSelectionWidget extends StatelessWidget {
  final int selectedStartHour;
  final int selectedStartMinute;
  final int selectedEndHour;
  final int selectedEndMinute;
  final DateTime facilityStartTime;
  final DateTime facilityEndTime;
  final List<int> Function() getAllowedStartHours;
  final List<int> Function(int hour) getAllowedStartMinutes;
  final List<int> Function() getAllowedEndHours;
  final List<int> Function(int hour) getAllowedEndMinutes;
  final Function(
      {int? startHour,
      int? startMinute,
      int? endHour,
      int? endMinute}) onTimeChanged;
  final Court court;
  final VoidCallback onBookPressed;
  final VoidCallback? onUpdateInactivePressed;
  final Future<bool> Function() onCheckTimeSlot;
  final String? errorMessage;
  final bool isValidating;
  final bool isTimeSlotValid;
  final bool isTimeSlotChecked;

  const TimeSelectionWidget({
    super.key,
    required this.selectedStartHour,
    required this.selectedStartMinute,
    required this.selectedEndHour,
    required this.selectedEndMinute,
    required this.facilityStartTime,
    required this.facilityEndTime,
    required this.getAllowedStartHours,
    required this.getAllowedStartMinutes,
    required this.getAllowedEndHours,
    required this.getAllowedEndMinutes,
    required this.onTimeChanged,
    required this.court,
    required this.onBookPressed,
    required this.onCheckTimeSlot,
    this.onUpdateInactivePressed,
    this.errorMessage,
    this.isValidating = false,
    this.isTimeSlotValid = true,
    this.isTimeSlotChecked = false,
  });

  void _showHourPicker(BuildContext context, {required bool isStartTime}) {
    final hours = isStartTime ? getAllowedStartHours() : getAllowedEndHours();

    if (hours.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No valid hours available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TimePickerBottomSheet(
          title: isStartTime ? 'Select Start Hour' : 'Select End Hour',
          values: hours,
          selectedValue: isStartTime ? selectedStartHour : selectedEndHour,
          onSelected: (value) {
            if (isStartTime) {
              onTimeChanged(startHour: value);
            } else {
              onTimeChanged(endHour: value);
            }
            Navigator.pop(context);
          },
          formatValue: (value) => value.toString().padLeft(2, '0'),
        );
      },
    );
  }

  void _showMinutePicker(BuildContext context, {required bool isStartTime}) {
    final selectedHour = isStartTime ? selectedStartHour : selectedEndHour;
    final minutes = isStartTime
        ? getAllowedStartMinutes(selectedHour)
        : getAllowedEndMinutes(selectedHour);

    if (minutes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No valid minutes available for the selected hour'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TimePickerBottomSheet(
          title: isStartTime ? 'Select Start Minute' : 'Select End Minute',
          values: minutes,
          selectedValue: isStartTime ? selectedStartMinute : selectedEndMinute,
          onSelected: (value) {
            if (isStartTime) {
              onTimeChanged(startMinute: value);
            } else {
              onTimeChanged(endMinute: value);
            }
            Navigator.pop(context);
          },
          formatValue: (value) => value.toString().padLeft(2, '0'),
        );
      },
    );
  }

  String _calculateDuration() {
    final startTime =
        DateTime(2000, 1, 1, selectedStartHour, selectedStartMinute);
    final endTime = DateTime(2000, 1, 1, selectedEndHour, selectedEndMinute);

    if (endTime.isBefore(startTime)) {
      return 'Invalid time';
    }

    final duration = endTime.difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return minutes > 0
          ? '$hours hour${hours > 1 ? 's' : ''} $minutes min'
          : '$hours hour${hours > 1 ? 's' : ''}';
    } else {
      return '$minutes min';
    }
  }

  String _calculatePrice(int pricePerHour) {
    final startTime =
        DateTime(2000, 1, 1, selectedStartHour, selectedStartMinute);
    final endTime = DateTime(2000, 1, 1, selectedEndHour, selectedEndMinute);

    if (endTime.isBefore(startTime)) {
      return '0 đ';
    }

    final duration = endTime.difference(startTime);
    final hours = duration.inMinutes / 60.0;
    final price = hours * pricePerHour;

    return '${price.toStringAsFixed(0)} đ';
  }

  // FIXED: Handle the integrated button press with context parameter
  void _handleMainButtonPress(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isManager = userProvider.user.roles.contains('Manager');

    if (!isTimeSlotChecked) {
      final isValid =
          await onCheckTimeSlot(); // Gọi API duy nhất khi chưa kiểm tra

      if (isValid) {
        if (isManager && onUpdateInactivePressed != null) {
          onUpdateInactivePressed!();
        } else {
          onBookPressed();
        }
      }
    } else if (isTimeSlotValid) {
      if (isManager && onUpdateInactivePressed != null) {
        onUpdateInactivePressed!();
      } else {
        onBookPressed();
      }
    }
  }

  // FIXED: Get button text based on current state with context parameter
  String _getButtonText(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isManager = userProvider.user.roles.contains('Manager');

    if (isValidating) {
      return !isTimeSlotChecked ? 'Checking Availability...' : 'Processing...';
    }

    if (!isTimeSlotChecked) {
      return isManager ? 'Check & Update Inactive' : 'Check & Book Now';
    }

    if (errorMessage != null || !isTimeSlotValid) {
      return 'Select Different Time';
    }

    return isManager ? 'Update Inactive' : 'Book Now';
  }

  // Get button color based on current state
  Color _getButtonColor() {
    if (isValidating) {
      return GlobalVariables.green.withOpacity(0.7);
    }

    if (!isTimeSlotChecked) {
      return GlobalVariables.green;
    }

    if (errorMessage != null || !isTimeSlotValid) {
      return GlobalVariables.darkGrey;
    }

    return GlobalVariables.green;
  }

  // Check if button should be enabled
  bool _isButtonEnabled() {
    if (isValidating) return false;

    // Always allow clicking if not checked yet or if there's an error (to re-check)
    if (!isTimeSlotChecked || errorMessage != null || !isTimeSlotValid) {
      return true;
    }

    // Allow proceeding if time slot is valid and checked
    return isTimeSlotValid && isTimeSlotChecked;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: GlobalVariables.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Time',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: GlobalVariables.blackGrey,
                ),
              ),
              Text(
                '${facilityStartTime.hour}:${facilityStartTime.minute.toString().padLeft(2, '0')} - ${facilityEndTime.hour}:${facilityEndTime.minute.toString().padLeft(2, '0')}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: GlobalVariables.darkGrey,
                ),
              ),
            ],
          ),

          // Validation status indicator
          if (isValidating)
            Container(
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    !isTimeSlotChecked
                        ? 'Checking time slot availability...'
                        : 'Processing...',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

          // Error message
          if (errorMessage != null)
            Container(
              margin: EdgeInsets.only(top: 8, bottom: 8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          errorMessage!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // Start time selection
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Time',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: GlobalVariables.darkGrey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        // Hour selector
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                _showHourPicker(context, isStartTime: true),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: GlobalVariables.grey),
                                borderRadius: BorderRadius.circular(8),
                                color: GlobalVariables.white,
                              ),
                              child: Center(
                                child: Text(
                                  selectedStartHour.toString().padLeft(2, '0'),
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          ':',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 8),
                        // Minute selector
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                _showMinutePicker(context, isStartTime: true),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: GlobalVariables.grey),
                                borderRadius: BorderRadius.circular(8),
                                color: GlobalVariables.white,
                              ),
                              child: Center(
                                child: Text(
                                  selectedStartMinute
                                      .toString()
                                      .padLeft(2, '0'),
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: 16),

              // End time selection
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'End Time',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: GlobalVariables.darkGrey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        // Hour selector
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                _showHourPicker(context, isStartTime: false),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: GlobalVariables.grey),
                                borderRadius: BorderRadius.circular(8),
                                color: GlobalVariables.white,
                              ),
                              child: Center(
                                child: Text(
                                  selectedEndHour.toString().padLeft(2, '0'),
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          ':',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 8),
                        // Minute selector
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                _showMinutePicker(context, isStartTime: false),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: GlobalVariables.grey),
                                borderRadius: BorderRadius.circular(8),
                                color: GlobalVariables.white,
                              ),
                              child: Center(
                                child: Text(
                                  selectedEndMinute.toString().padLeft(2, '0'),
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Quick time selection buttons
          Row(
            children: [
              Expanded(
                child: _QuickTimeButton(
                  label: '-30m',
                  onPressed: () {
                    final newEndMinute = selectedEndMinute - 30;
                    final newEndHour =
                        selectedEndHour + (newEndMinute < 0 ? -1 : 0);
                    final adjustedMinute =
                        newEndMinute < 0 ? newEndMinute + 60 : newEndMinute;

                    onTimeChanged(
                      endHour: newEndHour,
                      endMinute: adjustedMinute,
                    );
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _QuickTimeButton(
                  label: '+30m',
                  onPressed: () {
                    final newEndMinute = selectedEndMinute + 30;
                    final newEndHour =
                        selectedEndHour + (newEndMinute >= 60 ? 1 : 0);
                    final adjustedMinute =
                        newEndMinute >= 60 ? newEndMinute - 60 : newEndMinute;

                    onTimeChanged(
                      endHour: newEndHour,
                      endMinute: adjustedMinute,
                    );
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Duration and price calculation
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: GlobalVariables.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Duration',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: GlobalVariables.darkGrey,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _calculateDuration(),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: GlobalVariables.blackGrey,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Estimated Price',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: GlobalVariables.darkGrey,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _calculatePrice(court.pricePerHour),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: GlobalVariables.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // FIXED: Integrated Check & Book button with context passed to methods
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isButtonEnabled()
                  ? () => _handleMainButtonPress(context)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _getButtonColor(),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isValidating
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          _getButtonText(context),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getButtonText(context),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTimeButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _QuickTimeButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: GlobalVariables.green,
        side: BorderSide(color: GlobalVariables.green),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(label),
    );
  }
}
