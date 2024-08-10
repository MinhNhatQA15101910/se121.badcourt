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
  const CourtManagementScreen({Key? key}) : super(key: key);

  @override
  State<CourtManagementScreen> createState() => _CourtManagementScreenState();
}

class _CourtManagementScreenState extends State<CourtManagementScreen> {
  final _courtManagementService = CourtManagementService();

  List<Court> _courts = [];
  List<int> _selectedDays = [];
  int _startHour = 7;
  int _startMinute = 30;
  int _endHour = 19;
  int _endMinute = 30;

  int _hourMinuteToMilliseconds(int hour, int minute) {
    DateTime baseDate = DateTime(2000, 1, 1);
    DateTime time = baseDate.add(Duration(hours: hour, minutes: minute));
    return time.millisecondsSinceEpoch;
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

  Future<void> _updateActiveSchedule() async {
    final currentFacilityProvider = Provider.of<CurrentFacilityProvider>(
      context,
      listen: false,
    );

    Map<String, dynamic> activeSchedule = {};
    _selectedDays.forEach((day) {
      String dayName = _getDayName(day); // Helper function to get day name
      activeSchedule[dayName] = {
        'hour_from': _hourMinuteToMilliseconds(_startHour, _startMinute),
        'hour_to': _hourMinuteToMilliseconds(_endHour, _endMinute),
      };
    });
    await _courtManagementService.updateActiveSchedule(
      context,
      currentFacilityProvider.currentFacility.id,
      activeSchedule,
    );
  }

  void _updateSuccessCallback(bool success) {
    if (success) {
      _fetchCourtByFacilityId();
    }
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

      _updateActiveSchedule();
    });
  }

  Future<void> _fetchCourtByFacilityId() async {
    final currentFacilityProvider = Provider.of<CurrentFacilityProvider>(
      context,
      listen: false,
    );

    _courts = await _courtManagementService.fetchCourtByFacilityId(
      context,
      currentFacilityProvider.currentFacility.id,
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: GlobalVariables.green,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'COURTS',
                  style: GoogleFonts.alfaSlabOne(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none,
                    color: GlobalVariables.white,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                iconSize: 24,
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: GlobalVariables.white,
                ),
              ),
              IconButton(
                onPressed: () {},
                iconSize: 24,
                icon: const Icon(
                  Icons.message_outlined,
                  color: GlobalVariables.white,
                ),
              ),
            ],
          ),
        ),
      ),
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
                              .currentFacility.imageUrls.first,
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
                        _InterRegular18(
                          currentFacilityProvider.currentFacility.name,
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
                    padding:
                        const EdgeInsets.only(top: 12, left: 16, right: 16),
                    child: _titleText('Number of courts'),
                  ),
                  ..._courts
                      .map((court) => ItemCourt(
                            court: court,
                            onUpdateSuccess: _updateSuccessCallback,
                          ))
                      .toList(),
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
                  onPressed: () {
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
                          child: AddUpdateCourtBottomSheet(
                            stateText: 'Add',
                            onUpdateSuccess: _updateSuccessCallback,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _InterRegular18(String text, Color color, int maxLines) {
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
