import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/court/widgets/time_picker_bottom_sheet.dart';
import 'package:google_fonts/google_fonts.dart';

class ScheduleManagementWidget extends StatelessWidget {
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final bool hasUnsavedChanges;
  final bool isUpdatingSchedule;
  final Function({int? startHour, int? startMinute, int? endHour, int? endMinute}) onTimeChanged;
  final VoidCallback onSaveChanges;
  final VoidCallback onCancelChanges;

  const ScheduleManagementWidget({
    super.key,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.hasUnsavedChanges,
    required this.isUpdatingSchedule,
    required this.onTimeChanged,
    required this.onSaveChanges,
    required this.onCancelChanges,
  });

  // Time validation constants
  static const int MIN_HOUR = 4;
  static const int MAX_HOUR = 23;
  static const int MIN_DURATION_HOURS = 1;

  List<int> _getAllowedStartHours() {
    // Start hours from 7 to 22 (to allow at least 1 hour duration)
    return List.generate(MAX_HOUR - MIN_HOUR, (index) => MIN_HOUR + index);
  }

  List<int> _getAllowedEndHours() {
    // End hours must be at least 1 hour after start time
    final minEndHour = startHour + MIN_DURATION_HOURS;
    final maxEndHour = MAX_HOUR;
    
    if (minEndHour > maxEndHour) {
      return []; // No valid end hours
    }
    
    return List.generate(
      maxEndHour - minEndHour + 1, 
      (index) => minEndHour + index
    );
  }

  List<int> _getAllowedStartMinutes(int hour) {
    return List.generate(12, (index) => index * 5);
  }

  List<int> _getAllowedEndMinutes(int hour) {
    // If end hour is exactly 1 hour after start hour, 
    // end minute must be greater than start minute
    if (hour == startHour + MIN_DURATION_HOURS) {
      final minutes = List.generate(12, (index) => index * 5);
      return minutes.where((minute) => minute > startMinute).toList();
    }
    return List.generate(12, (index) => index * 5);
  }

  bool _isTimeRangeValid() {
    final startTime = DateTime(2000, 1, 1, startHour, startMinute);
    final endTime = DateTime(2000, 1, 1, endHour, endMinute);
    final duration = endTime.difference(startTime);
    
    return duration.inMinutes >= 60; // At least 1 hour
  }

  String? _getTimeValidationError() {
    if (startHour < MIN_HOUR || startHour > MAX_HOUR - 1) {
      return 'Start time must be between ${MIN_HOUR}:00 and ${MAX_HOUR - 1}:00';
    }
    
    if (endHour < MIN_HOUR + 1 || endHour > MAX_HOUR) {
      return 'End time must be between ${MIN_HOUR + 1}:00 and ${MAX_HOUR}:00';
    }
    
    if (!_isTimeRangeValid()) {
      return 'Duration must be at least $MIN_DURATION_HOURS hour';
    }
    
    return null;
  }

  void _showHourPicker(BuildContext context, {required bool isStartTime}) {
    final hours = isStartTime ? _getAllowedStartHours() : _getAllowedEndHours();
    
    if (hours.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No valid hours available for current selection'),
          backgroundColor: GlobalVariables.red,
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
          selectedValue: isStartTime ? startHour : endHour,
          onSelected: (value) {
            if (isStartTime) {
              onTimeChanged(startHour: value);
              // Auto-adjust end time if it becomes invalid
              final minEndHour = value + MIN_DURATION_HOURS;
              if (endHour < minEndHour) {
                onTimeChanged(endHour: minEndHour, endMinute: startMinute);
              }
            } else {
              onTimeChanged(endHour: value);
              // Auto-adjust end minute if it becomes invalid
              if (value == startHour + MIN_DURATION_HOURS && endMinute <= startMinute) {
                final validMinutes = _getAllowedEndMinutes(value);
                if (validMinutes.isNotEmpty) {
                  onTimeChanged(endMinute: validMinutes.first);
                }
              }
            }
            Navigator.pop(context);
          },
          formatValue: (value) => value.toString().padLeft(2, '0'),
        );
      },
    );
  }

  void _showMinutePicker(BuildContext context, {required bool isStartTime}) {
    final selectedHour = isStartTime ? startHour : endHour;
    final minutes = isStartTime 
        ? _getAllowedStartMinutes(selectedHour)
        : _getAllowedEndMinutes(selectedHour);
    
    if (minutes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No valid minutes available for the selected hour'),
          backgroundColor: GlobalVariables.red,
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
          selectedValue: isStartTime ? startMinute : endMinute,
          onSelected: (value) {
            if (isStartTime) {
              onTimeChanged(startMinute: value);
              // Auto-adjust end time if it becomes invalid
              if (endHour == startHour + MIN_DURATION_HOURS && endMinute <= value) {
                final validEndMinutes = _getAllowedEndMinutes(endHour);
                if (validEndMinutes.isNotEmpty) {
                  onTimeChanged(endMinute: validEndMinutes.first);
                }
              }
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
    final startTime = DateTime(2000, 1, 1, startHour, startMinute);
    final endTime = DateTime(2000, 1, 1, endHour, endMinute);
      
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

  String _timeString(int hour, int minute) {
    final formattedHour = hour.toString().padLeft(2, '0');
    final formattedMinute = minute.toString().padLeft(2, '0');
    return '$formattedHour:$formattedMinute';
  }

  @override
  Widget build(BuildContext context) {
    final validationError = _getTimeValidationError();
    final isValid = validationError == null;
    
    return Container(
      color: GlobalVariables.white,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Operating Hours',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: GlobalVariables.blackGrey,
                ),
              ),
              if (hasUnsavedChanges)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: GlobalVariables.darkGrey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Unsaved changes',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: GlobalVariables.darkGrey,
                    ),
                  ),
                ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Validation Error
          if (!isValid)
            Container(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: GlobalVariables.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: GlobalVariables.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: GlobalVariables.red, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      validationError,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: GlobalVariables.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Time Selection
          TimeSelectionRow(
            startHour: startHour,
            startMinute: startMinute,
            endHour: endHour,
            endMinute: endMinute,
            hasUnsavedChanges: hasUnsavedChanges,
            onShowHourPicker: _showHourPicker,
            onShowMinutePicker: _showMinutePicker,
          ),
          
          SizedBox(height: 16),
          
          // Quick Time Adjustment
          QuickTimeAdjustmentRow(
            startHour: startHour,
            startMinute: startMinute,
            endHour: endHour,
            endMinute: endMinute,
            onTimeChanged: onTimeChanged,
          ),
          
          SizedBox(height: 16),
          
          // Duration Display
          DurationDisplayWidget(
            duration: _calculateDuration(),
            timeRange: '${_timeString(startHour, startMinute)} - ${_timeString(endHour, endMinute)}',
            hasUnsavedChanges: hasUnsavedChanges,
          ),
          
          // Save/Cancel Buttons
          if (hasUnsavedChanges) ...[
            SizedBox(height: 16),
            SaveCancelButtonsRow(
              isUpdatingSchedule: isUpdatingSchedule,
              isValid: isValid,
              onSave: onSaveChanges,
              onCancel: onCancelChanges,
            ),
          ],
        ],
      ),
    );
  }
}

class TimeSelectionRow extends StatelessWidget {
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final bool hasUnsavedChanges;
  final Function(BuildContext, {required bool isStartTime}) onShowHourPicker;
  final Function(BuildContext, {required bool isStartTime}) onShowMinutePicker;

  const TimeSelectionRow({
    super.key,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.hasUnsavedChanges,
    required this.onShowHourPicker,
    required this.onShowMinutePicker,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Start Time
        Expanded(
          child: TimeInputColumn(
            label: 'Start Time',
            hour: startHour,
            minute: startMinute,
            hasUnsavedChanges: hasUnsavedChanges,
            onHourTap: () => onShowHourPicker(context, isStartTime: true),
            onMinuteTap: () => onShowMinutePicker(context, isStartTime: true),
          ),
        ),
        
        SizedBox(width: 16),
        
        // End Time
        Expanded(
          child: TimeInputColumn(
            label: 'End Time',
            hour: endHour,
            minute: endMinute,
            hasUnsavedChanges: hasUnsavedChanges,
            onHourTap: () => onShowHourPicker(context, isStartTime: false),
            onMinuteTap: () => onShowMinutePicker(context, isStartTime: false),
          ),
        ),
      ],
    );
  }
}

class TimeInputColumn extends StatelessWidget {
  final String label;
  final int hour;
  final int minute;
  final bool hasUnsavedChanges;
  final VoidCallback onHourTap;
  final VoidCallback onMinuteTap;

  const TimeInputColumn({
    super.key,
    required this.label,
    required this.hour,
    required this.minute,
    required this.hasUnsavedChanges,
    required this.onHourTap,
    required this.onMinuteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
                onTap: onHourTap,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: GlobalVariables.grey
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: GlobalVariables.white,
                  ),
                  child: Center(
                    child: Text(
                      hour.toString().padLeft(2, '0'),
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
                onTap: onMinuteTap,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: GlobalVariables.grey
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: GlobalVariables.white,
                  ),
                  child: Center(
                    child: Text(
                      minute.toString().padLeft(2, '0'),
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
    );
  }
}

class QuickTimeAdjustmentRow extends StatelessWidget {
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final Function({int? startHour, int? startMinute, int? endHour, int? endMinute}) onTimeChanged;

  const QuickTimeAdjustmentRow({
    super.key,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.onTimeChanged,
  });

  bool _canAdjustTime(int hourDelta, int minuteDelta) {
    final newEndMinute = endMinute + minuteDelta;
    final newEndHour = endHour + hourDelta + (newEndMinute < 0 ? -1 : newEndMinute >= 60 ? 1 : 0);
    final adjustedMinute = newEndMinute < 0 ? newEndMinute + 60 : newEndMinute >= 60 ? newEndMinute - 60 : newEndMinute;
    
    // Check bounds
    if (newEndHour < ScheduleManagementWidget.MIN_HOUR + 1 || newEndHour > ScheduleManagementWidget.MAX_HOUR) {
      return false;
    }
    
    // Check minimum duration
    final startTime = DateTime(2000, 1, 1, startHour, startMinute);
    final endTime = DateTime(2000, 1, 1, newEndHour, adjustedMinute);
    return endTime.difference(startTime).inMinutes >= 60;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickTimeButton(
            label: '-1h',
            enabled: _canAdjustTime(-1, 0),
            onPressed: () {
              if (_canAdjustTime(-1, 0)) {
                onTimeChanged(endHour: endHour - 1);
              }
            },
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _QuickTimeButton(
            label: '-30m',
            enabled: _canAdjustTime(0, -30),
            onPressed: () {
              if (_canAdjustTime(0, -30)) {
                final newEndMinute = endMinute - 30;
                final newEndHour = endHour + (newEndMinute < 0 ? -1 : 0);
                final adjustedMinute = newEndMinute < 0 ? newEndMinute + 60 : newEndMinute;
                
                onTimeChanged(
                  endHour: newEndHour,
                  endMinute: adjustedMinute,
                );
              }
            },
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _QuickTimeButton(
            label: '+30m',
            enabled: _canAdjustTime(0, 30),
            onPressed: () {
              if (_canAdjustTime(0, 30)) {
                final newEndMinute = endMinute + 30;
                final newEndHour = endHour + (newEndMinute >= 60 ? 1 : 0);
                final adjustedMinute = newEndMinute >= 60 ? newEndMinute - 60 : newEndMinute;
                
                onTimeChanged(
                  endHour: newEndHour,
                  endMinute: adjustedMinute,
                );
              }
            },
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _QuickTimeButton(
            label: '+1h',
            enabled: _canAdjustTime(1, 0),
            onPressed: () {
              if (_canAdjustTime(1, 0)) {
                onTimeChanged(endHour: endHour + 1);
              }
            },
          ),
        ),
      ],
    );
  }
}

class _QuickTimeButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  const _QuickTimeButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: enabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: enabled ? GlobalVariables.green : GlobalVariables.grey,
        side: BorderSide(color: enabled ? GlobalVariables.green : GlobalVariables.grey),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(vertical: 8),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class DurationDisplayWidget extends StatelessWidget {
  final String duration;
  final String timeRange;
  final bool hasUnsavedChanges;

  const DurationDisplayWidget({
    super.key,
    required this.duration,
    required this.timeRange,
    required this.hasUnsavedChanges,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasUnsavedChanges 
            ? GlobalVariables.darkGrey.withOpacity(0.1)
            : GlobalVariables.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Operating Duration',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: GlobalVariables.darkGrey,
                ),
              ),
              SizedBox(height: 4),
              Text(
                duration,
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
                'Time Range',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: GlobalVariables.darkGrey,
                ),
              ),
              SizedBox(height: 4),
              Text(
                timeRange,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: hasUnsavedChanges 
                      ? GlobalVariables.darkGrey 
                      : GlobalVariables.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SaveCancelButtonsRow extends StatelessWidget {
  final bool isUpdatingSchedule;
  final bool isValid;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const SaveCancelButtonsRow({
    super.key,
    required this.isUpdatingSchedule,
    required this.isValid,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isUpdatingSchedule ? null : onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: GlobalVariables.darkGrey,
              side: BorderSide(color: GlobalVariables.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: (isUpdatingSchedule || !isValid) ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: isValid ? GlobalVariables.green : GlobalVariables.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            child: isUpdatingSchedule
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Saving...',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Save Changes',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
