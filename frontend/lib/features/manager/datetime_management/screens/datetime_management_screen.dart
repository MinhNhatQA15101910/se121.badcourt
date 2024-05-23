import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/datetime_management/widgets/booking_widget.dart';
import 'package:frontend/features/manager/datetime_management/widgets/court_expand.dart';
import 'package:frontend/features/manager/datetime_management/widgets/date_tag.dart';
import 'package:google_fonts/google_fonts.dart';

class DatetimeManagementScreen extends StatefulWidget {
  const DatetimeManagementScreen({Key? key}) : super(key: key);

  @override
  State<DatetimeManagementScreen> createState() =>
      _DatetimeManagementScreenState();
}

class _DatetimeManagementScreenState extends State<DatetimeManagementScreen> {
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _dates = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 14; i++) {
      _dates.add(_selectedDate.add(Duration(days: i)));
    }
  }

  void _handleDateTagPressed(DateTime selectedDate) {
    setState(() {
      _selectedDate = selectedDate;
      for (int i = 0; i < _dates.length; i++) {
        _dates[i] == selectedDate ? true : false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: AppBar(
            backgroundColor: GlobalVariables.green,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Datetime management',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                    color: GlobalVariables.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Container(
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
                        SizedBox(
                          width: 16,
                        ),
                        for (DateTime date in _dates)
                          DateTag(
                            datetime: date,
                            isActived: date == _selectedDate,
                            onPressed: () => _handleDateTagPressed(date),
                          ),
                        SizedBox(
                          width: 8,
                        ),
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
                    children: [
                      CourtExpand(
                        titleText: 'Court 1',
                        descriptionText: 'Detail: With covered badminton court',
                      ),
                      CourtExpand(
                        titleText: 'Court 1',
                        descriptionText: 'Detail: With covered badminton court',
                      ),
                      CourtExpand(
                        titleText: 'Court 1',
                        descriptionText: 'Detail: With covered badminton court',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
