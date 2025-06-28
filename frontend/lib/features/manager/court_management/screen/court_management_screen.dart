import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/court_management/services/court_management_service.dart';
import 'package:frontend/features/manager/court_management/widget/add_update_court_btm_sheet.dart';
import 'package:frontend/features/manager/court_management/widget/day_picker.dart';
import 'package:frontend/features/manager/court_management/widget/item_court.dart';
import 'package:frontend/features/manager/court_management/widget/time_slot_btm_sheet.dart';
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
  List<int> _selectedDays = [];
  int _startHour = 1;
  int _startMinute = 1;
  int _endHour = 11;
  int _endMinute = 11;

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

      final currentFacilityProvider = context.watch<CurrentFacilityProvider>();
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

      setState(() {});
    }
  }

  String _timeString(int hour, int minute) {
    final formattedHour = hour.toString().padLeft(2, '0');
    final formattedMinute = minute.toString().padLeft(2, '0');
    return '$formattedHour:$formattedMinute';
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return 'sunday';
      case 2:
        return 'monday';
      case 3:
        return 'tuesday';
      case 4:
        return 'wednesday';
      case 5:
        return 'thursday';
      case 6:
        return 'friday';
      case 7:
        return 'saturday';
      default:
        return '';
    }
  }

  void _updateActiveSchedule() async {
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

    await _courtManagementService.updateActiveSchedule(
      context,
      facilityId,
      activeSchedule,
    );

    // 👉 Fetch lại facility sau khi cập nhật lịch
    final updatedFacility = await _courtManagementService.fetchFacilityById(
      context: context,
      facilityId: facilityId,
    );

    if (updatedFacility != null) {
      currentFacilityProvider.setFacility(updatedFacility);
    }
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

  void _updateSelectedDays(List<int> days) {
    setState(() {
      _selectedDays = days;
      _updateActiveSchedule();
    });
  }

  void _updateSelectedTime(
    int startHour,
    int startMinute,
    int endHour,
    int endMinute,
  ) {
    setState(() {
      _startHour = startHour;
      _startMinute = startMinute;
      _endHour = endHour;
      _endMinute = endMinute;
    });
    _updateActiveSchedule();
  }

  void _fetchCourtByFacilityId() async {
    final currentFacilityProvider = context.watch<CurrentFacilityProvider>();

    final currentFacility = currentFacilityProvider.currentFacility;
    final schedule = currentFacility.activeAt?.schedule;

    if (schedule != null && schedule.isNotEmpty) {
      final firstDaySchedule = schedule.values.first;

      final startTime = firstDaySchedule.hourFrom;
      final endTime = firstDaySchedule.hourTo;

      setState(() {
        List<String> startTimeParts = startTime.split(':');
        List<String> endTimeParts = endTime.split(':');

        _startHour = int.parse(startTimeParts[0]);
        _startMinute = int.parse(startTimeParts[1]);
        _endHour = int.parse(endTimeParts[0]);
        _endMinute = int.parse(endTimeParts[1]);
      });
    } else {
      setState(() {
        _startHour = 0;
        _startMinute = 0;
        _endHour = 0;
        _endMinute = 0;
      });
    }

    _courts = await _courtManagementService.fetchCourtByFacilityId(
      context,
      currentFacility.id,
    );

    setState(() {});
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
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          currentFacilityProvider
                              .currentFacility.facilityImages.first.url,
                        ),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: AspectRatio(
                      aspectRatio: 2 / 1,
                    ),
                  ),
                  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.only(
                      bottom: 12,
                      left: 16,
                      right: 16,
                    ),
                    color: GlobalVariables.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _interRegular18(
                          currentFacilityProvider.currentFacility.facilityName,
                          GlobalVariables.blackGrey,
                          1,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 1,
                    color: GlobalVariables.grey,
                  ),
                  DayPicker(
                    onDaysSelected: _updateSelectedDays,
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet<dynamic>(
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
                            child: TimeSlotBottomSheet(
                              onTimeRangeSelected: _updateSelectedTime,
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      color: GlobalVariables.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: _semiBoldSizeText('Time range:'),
                          ),
                          _boldSizeText(
                            '$_startHour:${_startMinute.toString().padLeft(2, '0')} to $_endHour:${_endMinute.toString().padLeft(2, '0')}',
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 12,
                      left: 16,
                      right: 16,
                    ),
                    child: _titleText('Number of courts'),
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ItemCourt(
                        court: _courts[index],
                        updateCourt: (court) {
                          _updateCourt(index, court);
                        },
                        deleteCourt: () => _deleteCourt(index),
                      );
                    },
                    itemCount: _courts.length,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: GlobalVariables.green,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.library_add_outlined,
                    color: GlobalVariables.white,
                    size: 24,
                  ),
                  onPressed: _addCourt,
                ),
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

  Widget _interRegular18(String text, Color color, int maxLines) {
    return Container(
      padding: const EdgeInsets.only(
        top: 12,
      ),
      child: Text(
        text,
        textAlign: TextAlign.start,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _semiBoldSizeText(String text) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _boldSizeText(String text) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _titleText(String text) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
