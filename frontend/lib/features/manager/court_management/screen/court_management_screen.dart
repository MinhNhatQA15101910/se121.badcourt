import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/court_management/services/court_management_service.dart';
import 'package:frontend/features/manager/court_management/widget/add_update_court_btm_sheet.dart';
import 'package:frontend/features/manager/court_management/widget/day_picker.dart';
import 'package:frontend/features/manager/court_management/widget/item_court.dart';
import 'package:frontend/features/manager/court_management/widget/facility_header_widget.dart';
import 'package:frontend/features/manager/court_management/widget/schedule_management_widget.dart';
import 'package:frontend/models/court.dart';
import 'package:frontend/providers/manager/current_facility_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CourtManagementScreen extends StatefulWidget {
  const CourtManagementScreen({super.key});

  @override
  State<CourtManagementScreen> createState() => _CourtManagementScreenState();
}

class _CourtManagementScreenState extends State<CourtManagementScreen> {
  final _courtManagementService = CourtManagementService();

  List<Court> _courts = [];
  
  // Original values (from server)
  List<int> _originalSelectedDays = [];
  int _originalStartHour = 7;
  int _originalStartMinute = 0;
  int _originalEndHour = 23;
  int _originalEndMinute = 0;
  
  // Current editing values (local state)
  List<int> _selectedDays = [];
  int _startHour = 7;
  int _startMinute = 0;
  int _endHour = 23;
  int _endMinute = 0;
  
  bool _isUpdatingSchedule = false;
  bool _hasUnsavedChanges = false;

  void _addCourt() async {
    Court? newCourt = await showModalBottomSheet<Court>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: AddUpdateCourtBottomSheet(),
        );
      },
    );

    if (newCourt != null) {
      _courts.add(newCourt);
      _updateFacilityProvider(newCourt);
      setState(() {});
    }
  }

  void _updateFacilityProvider(Court newCourt) {
    final currentFacilityProvider = context.read<CurrentFacilityProvider>();
    final currentFacility = currentFacilityProvider.currentFacility;
    
    if (currentFacilityProvider.currentFacility.courtsAmount == 0) {
      currentFacilityProvider.setFacility(
        currentFacility.copyWith(
          courtsAmount: 1,
          minPrice: newCourt.pricePerHour,
          maxPrice: newCourt.pricePerHour,
        ),
      );
    } else {
      currentFacilityProvider.setFacility(
        currentFacility.copyWith(
          courtsAmount: currentFacility.courtsAmount + 1,
          minPrice: newCourt.pricePerHour < currentFacility.minPrice
              ? newCourt.pricePerHour
              : currentFacility.minPrice,
          maxPrice: newCourt.pricePerHour > currentFacility.maxPrice
              ? newCourt.pricePerHour
              : currentFacility.maxPrice,
        ),
      );
    }
  }

  String _timeString(int hour, int minute) {
    final formattedHour = hour.toString().padLeft(2, '0');
    final formattedMinute = minute.toString().padLeft(2, '0');
    return '$formattedHour:$formattedMinute';
  }

  String _getDayName(int day) {
    switch (day) {
      case 1: return 'sunday';
      case 2: return 'monday';
      case 3: return 'tuesday';
      case 4: return 'wednesday';
      case 5: return 'thursday';
      case 6: return 'friday';
      case 7: return 'saturday';
      default: return '';
    }
  }

  // Check if there are unsaved changes
  void _checkForUnsavedChanges() {
    final hasChanges = !_listsEqual(_selectedDays, _originalSelectedDays) ||
        _startHour != _originalStartHour ||
        _startMinute != _originalStartMinute ||
        _endHour != _originalEndHour ||
        _endMinute != _originalEndMinute;
    
    if (hasChanges != _hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = hasChanges;
      });
    }
  }

  bool _listsEqual(List<int> list1, List<int> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (!list2.contains(list1[i])) return false;
    }
    return true;
  }

  // Save changes to server
  Future<void> _saveScheduleChanges() async {
    setState(() {
      _isUpdatingSchedule = true;
    });

    final currentFacilityProvider = context.read<CurrentFacilityProvider>();
    final facilityId = currentFacilityProvider.currentFacility.id;

    Map<String, dynamic> activeSchedule = {};
    for (int day in _selectedDays) {
      String dayName = _getDayName(day);
      activeSchedule[dayName] = {
        'hourFrom': _timeString(_startHour, _startMinute),
        'hourTo': _timeString(_endHour, _endMinute),
      };
    }

    try {
      await _courtManagementService.updateActiveSchedule(
        context,
        facilityId,
        activeSchedule,
      );

      // Fetch updated facility
      final updatedFacility = await _courtManagementService.fetchFacilityById(
        context: context,
        facilityId: facilityId,
      );

      if (updatedFacility != null) {
        currentFacilityProvider.setFacility(updatedFacility);
      }

      // Update original values to match current values
      setState(() {
        _originalSelectedDays = List.from(_selectedDays);
        _originalStartHour = _startHour;
        _originalStartMinute = _startMinute;
        _originalEndHour = _endHour;
        _originalEndMinute = _endMinute;
        _hasUnsavedChanges = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Schedule updated successfully'),
          backgroundColor: GlobalVariables.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update schedule: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() {
        _isUpdatingSchedule = false;
      });
    }
  }

  // Cancel changes and revert to original values
  void _cancelScheduleChanges() {
    setState(() {
      _selectedDays = List.from(_originalSelectedDays);
      _startHour = _originalStartHour;
      _startMinute = _originalStartMinute;
      _endHour = _originalEndHour;
      _endMinute = _originalEndMinute;
      _hasUnsavedChanges = false;
    });
  }

  void _updateSelectedDays(List<int> days) {
    setState(() {
      _selectedDays = days;
    });
    _checkForUnsavedChanges();
  }

  void _updateSelectedTime({
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
  }) {
    setState(() {
      if (startHour != null) _startHour = startHour;
      if (startMinute != null) _startMinute = startMinute;
      if (endHour != null) _endHour = endHour;
      if (endMinute != null) _endMinute = endMinute;
    });
    _checkForUnsavedChanges();
  }

  void _deleteCourt(int index) async {
    final currentFacilityProvider = context.watch<CurrentFacilityProvider>();

    final currentFacility = await _courtManagementService.fetchFacilityById(
      context: context,
      facilityId: currentFacilityProvider.currentFacility.id,
    );

    if (currentFacility != null) {
      currentFacilityProvider.setFacility(currentFacility);
    }

    _courts.removeAt(index);
    setState(() {});
  }

  void _updateCourt(int index, Court court) {
    _courts[index] = court;

    final currentFacilityProvider = Provider.of<CurrentFacilityProvider>(
      context,
      listen: false,
    );
    final currentFacility = currentFacilityProvider.currentFacility;
    currentFacilityProvider.setFacility(
      currentFacility.copyWith(
        minPrice: court.pricePerHour < currentFacility.minPrice
            ? court.pricePerHour
            : currentFacility.minPrice,
        maxPrice: court.pricePerHour > currentFacility.maxPrice
            ? court.pricePerHour
            : currentFacility.maxPrice,
      ),
    );

    setState(() {});
  }

  void _fetchCourtByFacilityId() async {
    final currentFacilityProvider = context.watch<CurrentFacilityProvider>();

    final currentFacility = currentFacilityProvider.currentFacility;
    final schedule = currentFacility.activeAt?.schedule;

    if (schedule != null && schedule.isNotEmpty) {
      final firstDaySchedule = schedule.values.first;
      final startTime = firstDaySchedule.hourFrom;
      final endTime = firstDaySchedule.hourTo;

      List<String> startTimeParts = startTime.split(':');
      List<String> endTimeParts = endTime.split(':');

      final startHour = int.parse(startTimeParts[0]);
      final startMinute = int.parse(startTimeParts[1]);
      final endHour = int.parse(endTimeParts[0]);
      final endMinute = int.parse(endTimeParts[1]);

      // Get selected days from schedule
      final scheduleKeys = schedule.keys;
      final selectedDays = scheduleKeys.map(_getDayNumber).whereType<int>().toList();

      setState(() {
        // Set both original and current values
        _originalStartHour = startHour;
        _originalStartMinute = startMinute;
        _originalEndHour = endHour;
        _originalEndMinute = endMinute;
        _originalSelectedDays = List.from(selectedDays);
        
        _startHour = startHour;
        _startMinute = startMinute;
        _endHour = endHour;
        _endMinute = endMinute;
        _selectedDays = List.from(selectedDays);
        
        _hasUnsavedChanges = false;
      });
    } else {
      setState(() {
        _originalStartHour = 7;
        _originalStartMinute = 0;
        _originalEndHour = 23;
        _originalEndMinute = 0;
        _originalSelectedDays = [];
        
        _startHour = 7;
        _startMinute = 0;
        _endHour = 23;
        _endMinute = 0;
        _selectedDays = [];
        
        _hasUnsavedChanges = false;
      });
    }

    _courts = await _courtManagementService.fetchCourtByFacilityId(
      context,
      currentFacility.id,
    );

    setState(() {});
  }

  int? _getDayNumber(String dayName) {
    switch (dayName.toLowerCase()) {
      case 'sunday': return 1;
      case 'monday': return 2;
      case 'tuesday': return 3;
      case 'wednesday': return 4;
      case 'thursday': return 5;
      case 'friday': return 6;
      case 'saturday': return 7;
      default: return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCourtByFacilityId();
  }

  @override
  Widget build(BuildContext context) {
    final currentFacilityProvider = context.watch<CurrentFacilityProvider>();
    
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.maxFinite,
            color: GlobalVariables.defaultColor,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Facility Header
                  FacilityHeaderWidget(
                    facility: currentFacilityProvider.currentFacility,
                  ),
                  
                  Container(height: 1, color: GlobalVariables.grey),
                  
                  // Day Picker
                  DayPicker(
                    selectedDays: _selectedDays,
                    onDaysSelected: _updateSelectedDays,
                  ),
                  
                  // Schedule Management
                  ScheduleManagementWidget(
                    startHour: _startHour,
                    startMinute: _startMinute,
                    endHour: _endHour,
                    endMinute: _endMinute,
                    hasUnsavedChanges: _hasUnsavedChanges,
                    isUpdatingSchedule: _isUpdatingSchedule,
                    onTimeChanged: _updateSelectedTime,
                    onSaveChanges: _saveScheduleChanges,
                    onCancelChanges: _cancelScheduleChanges,
                  ),
                  
                  Container(height: 1, color: GlobalVariables.grey),
                  
                  // Courts Section
                  Padding(
                    padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
                    child: Text(
                      'Number of courts',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ItemCourt(
                        court: _courts[index],
                        updateCourt: (court) => _updateCourt(index, court),
                        deleteCourt: () => _deleteCourt(index),
                      );
                    },
                    itemCount: _courts.length,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: _addCourt,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GlobalVariables.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Add Court',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                                    const SizedBox(height: 12),

                ],
              ),
            ),
          ),
        
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchCourtByFacilityId();
  }
}
