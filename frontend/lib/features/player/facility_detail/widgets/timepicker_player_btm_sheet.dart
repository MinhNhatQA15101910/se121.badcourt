import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_button.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/player/checkout/screens/checkout_screen.dart';
import 'package:frontend/features/player/facility_detail/services/facility_detail_service.dart';
import 'package:frontend/providers/checkout_provider.dart';
import 'package:frontend/providers/player/selected_court_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

class TimePickerPlayerBottomSheet extends StatefulWidget {
  const TimePickerPlayerBottomSheet({Key? key}) : super(key: key);

  @override
  State<TimePickerPlayerBottomSheet> createState() =>
      _TimePickerPlayerBottomSheetState();
}

class _TimePickerPlayerBottomSheetState
    extends State<TimePickerPlayerBottomSheet> {
  int startHour = 0;
  int startMinuteIndex = 0;
  int endHour = 0;
  int endMinuteIndex = 0;
  bool isSelectingStartTime = true;
  final List<int> minuteValues = List.generate(12, (index) => index * 5);

  Color startColor = GlobalVariables.grey;
  Color endColor = GlobalVariables.white;

  final _facilityDetailService = FacilityDetailService();

  @override
  void initState() {
    super.initState();
    final selectedCourtProvider = Provider.of<SelectedCourtProvider>(context, listen: false);
    final selectedDate = selectedCourtProvider.selectedDate;
    
    if (selectedDate != null) {
      startHour = selectedDate.hour;
      endHour = selectedDate.hour;
    }
  }

  DateTime combineDateTime(DateTime currentDateTime, int hour, int minuteIndex) {
    return DateTime(
      currentDateTime.year,
      currentDateTime.month,
      currentDateTime.day,
      hour,
      minuteValues[minuteIndex],
    );
  }

  Future<bool> isOverlapse(String courtId, DateTime dateTime) async {
    return await _facilityDetailService.checkIntersect(
      context,
      courtId,
      combineDateTime(dateTime, startHour, startMinuteIndex),
      combineDateTime(dateTime, endHour, endMinuteIndex),
    );
  }

  void updateActiveSchedule() {
    Navigator.of(context).pushNamed(CheckoutScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    
    return Consumer<SelectedCourtProvider>(
      builder: (context, selectedCourtProvider, child) {
        final court = selectedCourtProvider.selectedCourt;
        final dateTime = selectedCourtProvider.selectedDate;

        if (court == null || dateTime == null) {
          return Container(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                'No court or date selected',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          );
        }

        return Container(
          padding: EdgeInsets.only(bottom: keyboardSpace),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 32,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(width: 24),
                      Expanded(
                        child: Container(
                          child: _BoldSizeText('Book a playtime'),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        iconSize: 24,
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: GlobalVariables.lightGrey,
                  thickness: 1.0,
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSelectingStartTime = true;
                                    startColor = GlobalVariables.grey;
                                    endColor = GlobalVariables.white;
                                  });
                                },
                                child: Container(
                                  height: 56,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: startColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${startHour.toString().padLeft(2, '0')}:${minuteValues[startMinuteIndex].toString().padLeft(2, '0')}",
                                      style: TextStyle(
                                        color: GlobalVariables.blackGrey,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Transform.rotate(
                                angle: 3.14,
                                child: Icon(
                                  Icons.keyboard_backspace_outlined,
                                  color: GlobalVariables.darkGrey,
                                  size: 24,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSelectingStartTime = false;
                                    endColor = GlobalVariables.grey;
                                    startColor = GlobalVariables.white;
                                  });
                                },
                                child: Container(
                                  height: 56,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: endColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${endHour.toString().padLeft(2, '0')}:${minuteValues[endMinuteIndex].toString().padLeft(2, '0')}",
                                      style: TextStyle(
                                        color: GlobalVariables.blackGrey,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            color: GlobalVariables.grey,
                            thickness: 1,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                NumberPicker(
                                  minValue: 0,
                                  maxValue: 23,
                                  value: isSelectingStartTime ? startHour : endHour,
                                  zeroPad: true,
                                  infiniteLoop: true,
                                  itemWidth: 80,
                                  itemHeight: 60,
                                  onChanged: (value) {
                                    setState(() {
                                      if (isSelectingStartTime) {
                                        startHour = value;
                                      } else {
                                        endHour = value;
                                      }
                                    });
                                  },
                                  textStyle: GoogleFonts.inter(
                                    color: GlobalVariables.grey,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  selectedTextStyle: GoogleFonts.inter(
                                    color: GlobalVariables.black,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                _SemiBoldBlack40(':'),
                                NumberPicker(
                                  minValue: 0,
                                  maxValue: minuteValues.length - 1,
                                  value: isSelectingStartTime
                                      ? startMinuteIndex
                                      : endMinuteIndex,
                                  infiniteLoop: true,
                                  itemWidth: 80,
                                  itemHeight: 60,
                                  onChanged: (value) {
                                    setState(() {
                                      if (isSelectingStartTime) {
                                        startMinuteIndex = value;
                                      } else {
                                        endMinuteIndex = value;
                                      }
                                    });
                                  },
                                  textStyle: GoogleFonts.inter(
                                    color: GlobalVariables.grey,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  selectedTextStyle: GoogleFonts.inter(
                                    color: GlobalVariables.black,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textMapper: (indexString) {
                                    int index = int.parse(indexString);
                                    return minuteValues[index]
                                        .toString()
                                        .padLeft(2, '0');
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: GlobalVariables.grey,
                  thickness: 1,
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          child: CustomButton(
                            onTap: () => Navigator.pop(context),
                            buttonText: 'Cancel',
                            borderColor: GlobalVariables.green,
                            fillColor: Colors.white,
                            textColor: GlobalVariables.green,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          child: CustomButton(
                            onTap: () async {
                              if (await isOverlapse(court.id, dateTime) == true) {
                                final checkoutProvider =
                                    Provider.of<CheckoutProvider>(context,
                                        listen: false);
                                checkoutProvider.startDate = combineDateTime(
                                    dateTime, startHour, startMinuteIndex);
                                checkoutProvider.endDate = combineDateTime(
                                    dateTime, endHour, endMinuteIndex);
                                checkoutProvider.court = court;
                                updateActiveSchedule();
                              }
                            },
                            buttonText: 'Confirm',
                            borderColor: GlobalVariables.green,
                            fillColor: GlobalVariables.green,
                            textColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _BoldSizeText(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _SemiBoldBlack40(String text) {
    return Container(
      padding: EdgeInsets.only(
        bottom: 14,
        top: 8,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: GlobalVariables.blackGrey,
          fontSize: 40,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
