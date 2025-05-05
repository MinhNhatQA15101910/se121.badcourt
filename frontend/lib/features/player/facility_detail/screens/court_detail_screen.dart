import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/common/widgets/custom_button.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/player/facility_detail/services/facility_detail_service.dart';
import 'package:frontend/features/player/facility_detail/widgets/court_expand_player.dart';
import 'package:frontend/features/player/facility_detail/widgets/date_tag_player.dart';
import 'package:frontend/features/player/facility_detail/widgets/timepicker_player_btm_sheet.dart';
import 'package:frontend/models/court.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/providers/manager/current_facility_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CourtDetailScreen extends StatefulWidget {
  static const String routeName = '/courtDetail';

  const CourtDetailScreen({Key? key}) : super(key: key);

  @override
  _CourtDetailScreenState createState() => _CourtDetailScreenState();
}

class _CourtDetailScreenState extends State<CourtDetailScreen> {
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _dates = [];
  final _facilityDetailService = FacilityDetailService();
  List<Court> _courts = [];
  Court _selectedCourt = Court(
    id: '',
    courtName: 'Default Court Name',
    description: 'Default description for the court.',
    pricePerHour: 100000,
    state: 'Active',
    createdAt: DateTime.now().toUtc().toIso8601String(),
    orderPeriods: [],
  );

  void _removeInactiveDays(Facility facility) {
    const List<String> daysOfWeek = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

    for (int i = 0; i < daysOfWeek.length; i++) {
      final dayName = daysOfWeek[i];

      if (!facility.hasDay(dayName)) {
        _dates.removeWhere((date) => date.weekday == (i + 1));
      }
    }

    // Gán ngày đầu tiên còn lại vào _selectedDate, nếu có
    if (_dates.isNotEmpty) {
      _selectedDate = _dates[0];
    }
  }

  Future<void> _fetchCourtByFacilityId(Facility facility) async {
    _courts = await _facilityDetailService.fetchCourtByFacilityId(
      context,
      facility.id,
    );
    setState(() {});
  }

  void _handleDateTagPressed(DateTime selectedDate) {
    setState(() {
      _selectedDate = selectedDate;
      for (int i = 0; i < _dates.length; i++) {
        _dates[i] == selectedDate ? true : false;
      }
    });
  }

  void _handleCourtSelection(Court court) {
    setState(() {
      _selectedCourt = court;
    });
  }

  @override
  void initState() {
    super.initState();
    // Khởi tạo danh sách ngày
    for (int i = 0; i < 14; i++) {
      _dates.add(_selectedDate.add(Duration(days: i)));
    }

    // Lấy facility từ Provider
    final currentFacilityProvider =
        Provider.of<CurrentFacilityProvider>(context, listen: false);
    final facility = currentFacilityProvider.currentFacility;

    // Loại bỏ các ngày không hoạt động và tải danh sách sân
    _removeInactiveDays(facility);
    _fetchCourtByFacilityId(facility);
  }

  @override
  Widget build(BuildContext context) {
    final currentFacilityProvider = context.watch<CurrentFacilityProvider>();
    final facility = currentFacilityProvider.currentFacility;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: GlobalVariables.green,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Court detail',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
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
      body: (_dates.isNotEmpty)
          ? Container(
              color: GlobalVariables.defaultColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            color: GlobalVariables.white,
                            padding: EdgeInsets.only(top: 12, bottom: 16),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  SizedBox(width: 16),
                                  for (DateTime date in _dates)
                                    DateTagPlayer(
                                      datetime: date,
                                      isActived: date == _selectedDate,
                                      onPressed: () {
                                        _handleDateTagPressed(date);
                                      },
                                    ),
                                  SizedBox(width: 8),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 12,
                            ),
                            color: GlobalVariables.defaultColor,
                            child: Column(
                              children: List.generate(
                                _courts.length,
                                (index) => CourtExpandPlayer(
                                  facility: facility,
                                  court: _courts[index],
                                  currentDateTime: _selectedDate,
                                  onExpansionChanged: _handleCourtSelection,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    child: Column(
                      children: [
                        Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(
                                color: GlobalVariables.grey,
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _subTotalText('Selected court:'),
                              _subTotalPriceText(_selectedCourt.courtName),
                            ],
                          ),
                        ),
                        Container(
                          color: GlobalVariables.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: CustomButton(
                            onTap: () => {
                              if (_selectedCourt.id == "")
                                {
                                  IconSnackBar.show(context,
                                      label: 'No selected court',
                                      snackBarType: SnackBarType.fail)
                                }
                              else
                                {
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
                                        child: TimePickerPlayerBottomSheet(
                                          court: _selectedCourt,
                                          dateTime: _selectedDate,
                                        ),
                                      );
                                    },
                                  ),
                                }
                            },
                            buttonText: 'Add a time slot',
                            borderColor: GlobalVariables.green,
                            fillColor: GlobalVariables.green,
                            textColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Center(child: _subTotalText('No data found')),
    );
  }

  Widget _subTotalText(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: 16,
        color: Colors.black,
        textStyle: const TextStyle(
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _subTotalPriceText(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: 16,
        color: Colors.black,
        textStyle: const TextStyle(
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
