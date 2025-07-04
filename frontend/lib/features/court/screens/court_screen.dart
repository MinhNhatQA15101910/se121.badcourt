import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/court/services/court_service.dart';
import 'package:frontend/features/court/widgets/court_card_player.dart';
import 'package:frontend/features/court/widgets/date_tag_player.dart';
import 'package:frontend/models/court.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/providers/manager/current_facility_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/court_hub_provider.dart';

class CourtScreen extends StatefulWidget {
  static const String routeName = '/courtDetail';

  const CourtScreen({Key? key}) : super(key: key);

  @override
  _CourtScreenState createState() => _CourtScreenState();
}

class _CourtScreenState extends State<CourtScreen> {
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _dates = [];
  final _courtService = CourtService();
  List<Court> _courts = [];
  bool _isLoading = true;

  bool _isDateDisabled(DateTime date, Facility facility) {
    const daysOfWeek = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];
    final dayName = daysOfWeek[date.weekday - 1];
    return !facility.hasDay(dayName);
  }

  Future<void> _fetchCourtByFacilityId(Facility facility) async {
    setState(() {
      _isLoading = true;
    });

    _courts = await _courtService.fetchCourtByFacilityId(
      context,
      facility.id,
    );

    setState(() {
      _isLoading = false;
    });
  }

  void _handleDateTagPressed(DateTime selectedDate) {
    setState(() {
      _selectedDate = selectedDate;
    });
  }

  @override
  void initState() {
    super.initState();

    // Lấy facility từ Provider
    final currentFacilityProvider =
        Provider.of<CurrentFacilityProvider>(context, listen: false);
    final facility = currentFacilityProvider.currentFacility;

    // Khởi tạo danh sách ngày (14 ngày tiếp theo)
    final now = DateTime.now();
    for (int i = 0; i < 14; i++) {
      _dates.add(now.add(Duration(days: i)));
    }

    // Tìm ngày hợp lệ đầu tiên để gán vào _selectedDate
    final firstAvailableDate = _dates.firstWhere(
        (date) => !_isDateDisabled(date, facility),
        orElse: () => now);
    _selectedDate = firstAvailableDate;

    _fetchCourtByFacilityId(facility);
  }

  @override
  void dispose() {
    // Clean up any connections when leaving the screen
    final courtHubProvider =
        Provider.of<CourtHubProvider>(context, listen: false);
    courtHubProvider.disconnectFromAllCourts();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentFacilityProvider = context.watch<CurrentFacilityProvider>();
    context.watch<CourtHubProvider>();
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
                  'Select Court',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                    color: GlobalVariables.white,
                  ),
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
                children: [
                  // Date selector
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
                              isDisabled: _isDateDisabled(date, facility),
                              onPressed: () {
                                if (!_isDateDisabled(date, facility)) {
                                  _handleDateTagPressed(date);
                                }
                              },
                            ),
                          SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                  // Courts list
                  Expanded(
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: GlobalVariables.green,
                            ),
                          )
                        : _courts.isEmpty
                            ? Center(
                                child: _subTotalText('No courts available'),
                              )
                            : Container(
                                padding: EdgeInsets.all(16),
                                child: ListView.builder(
                                  itemCount: _courts.length,
                                  itemBuilder: (context, index) {
                                    final court = _courts[index];

                                    return CourtCardPlayer(
                                      facility: facility,
                                      court: court,
                                      selectedDate: _selectedDate,
                                    );
                                  },
                                ),
                              ),
                  ),
                ],
              ),
            )
          : Center(child: _subTotalText('No available dates')),
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
}
