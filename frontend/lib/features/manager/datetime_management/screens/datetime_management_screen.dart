import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_button.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/datetime_management/widgets/court_expand.dart';
import 'package:frontend/features/manager/datetime_management/widgets/date_tag.dart';
import 'package:frontend/features/manager/datetime_management/widgets/timepicker_btm_sheet.dart';
import 'package:google_fonts/google_fonts.dart';

class DatetimeManagementScreen extends StatefulWidget {
  static const String routeName = '/datetime-management';
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
                            descriptionText:
                                'Detail: With covered badminton court',
                          ),
                          CourtExpand(
                            titleText: 'Court 2',
                            descriptionText:
                                'Detail: With covered badminton court',
                          ),
                          CourtExpand(
                            titleText: 'Court 3',
                            descriptionText:
                                'Detail: With covered badminton court',
                          ),
                        ],
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: GlobalVariables.grey,
                            width: 1.0,
                          ),
                        )),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _subTotalText('Selected court '),
                        _subTotalPriceText('Court 1'),
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
                              child: TimePickerBottomSheet(),
                            );
                          },
                        ),
                      },
                      buttonText: 'Add a time to lock',
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
      ),
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
