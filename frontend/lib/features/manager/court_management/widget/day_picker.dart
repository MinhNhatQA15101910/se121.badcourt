import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';

class DayPicker extends StatefulWidget {
  final void Function(List<int>)
      onDaysSelected; // Callback để truyền danh sách ngày đã chọn

  const DayPicker({
    required this.onDaysSelected,
    Key? key,
  }) : super(key: key);

  @override
  _DayPickerState createState() => _DayPickerState();
}

class _DayPickerState extends State<DayPicker> {
  List<int> selectedDays = [
    2
  ]; // Default selected days (you can change it as needed)

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GlobalVariables.white,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InterBold16(
                  'Days open',
                  GlobalVariables.blackGrey,
                  1,
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(7, (index) {
                    int day =
                        (index + 2) % 8; // Ensure the days wrap around properly
                    if (day == 0) {
                      day = 1; // Correct wrap-around to ensure day 1
                    }
                    bool isSelected = selectedDays.contains(day);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedDays.remove(
                                day); // Unselect the day if already selected
                          } else {
                            selectedDays
                                .add(day); // Select the day if not selected
                          }
                        });
                        widget.onDaysSelected(
                            selectedDays); // Callback to pass selected days to parent
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? GlobalVariables.green
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: GlobalVariables.green,
                            width: 1.0,
                          ),
                        ),
                        width: 24.0,
                        height: 24.0,
                        child: Center(
                          child: Text(
                            day == 1 ? 'S' : '$day',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? GlobalVariables.white
                                  : GlobalVariables.green,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: GlobalVariables.grey,
          )
        ],
      ),
    );
  }

  Widget _InterBold16(String text, Color color, int maxLines) {
    return Container(
      child: Text(
        text,
        textAlign: TextAlign.start,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
