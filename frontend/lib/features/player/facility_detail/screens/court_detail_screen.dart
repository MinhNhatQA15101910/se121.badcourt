import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/player/facility_detail/services/facility_detail_service.dart';
import 'package:frontend/features/player/facility_detail/widgets/court_card_player.dart';
import 'package:frontend/features/player/facility_detail/widgets/date_tag_player.dart';
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
  bool _isLoading = true;

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
    setState(() {
      _isLoading = true;
    });
    
    _courts = await _facilityDetailService.fetchCourtByFacilityId(
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
                  'Select Court',
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
                              onPressed: () {
                                _handleDateTagPressed(date);
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
                                    return CourtCardPlayer(
                                      facility: facility,
                                      court: _courts[index],
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
