import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_buttom.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numberpicker/numberpicker.dart';

class TimePickerBottomSheet extends StatefulWidget {
  const TimePickerBottomSheet({
    Key? key,
  }) : super(key: key);

  @override
  State<TimePickerBottomSheet> createState() => _TimePickerBottomSheetState();
}

class _TimePickerBottomSheetState extends State<TimePickerBottomSheet> {
  int startHour = 0;
  int startMinuteIndex = 0;
  int endHour = 0;
  int endMinuteIndex = 0;
  bool isSelectingStartTime = true;
  final List<int> minuteValues = List.generate(12, (index) => index * 5);

  Color startColor = GlobalVariables.grey;
  Color endColor = GlobalVariables.white;

  int get selectedMinute => isSelectingStartTime
      ? minuteValues[startMinuteIndex]
      : minuteValues[endMinuteIndex];
  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.only(
        bottom: keyboardSpace,
      ),
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
                  SizedBox(
                    width: 24,
                  ),
                  Expanded(
                    child: Container(
                      child: _BoldSizeText('Choose a time to lock'),
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
              padding: EdgeInsets.only(
                bottom: 12,
                left: 16,
                right: 16,
              ),
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
                      const SizedBox(height: 20),
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
              color: GlobalVariables.defaultColor,
              thickness: 12.0,
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
                        onTap: () {},
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
