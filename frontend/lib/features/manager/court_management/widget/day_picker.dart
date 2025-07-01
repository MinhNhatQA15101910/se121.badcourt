import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';

class DayPicker extends StatefulWidget {
  final List<int> selectedDays; // Pass selected days from parent
  final void Function(List<int>) onDaysSelected; // Callback để truyền danh sách ngày đã chọn

  const DayPicker({
    required this.selectedDays,
    required this.onDaysSelected,
    Key? key,
  }) : super(key: key);

  @override
  _DayPickerState createState() => _DayPickerState();
}

class _DayPickerState extends State<DayPicker> {
  late List<int> selectedDays;

  @override
  void initState() {
    super.initState();
    selectedDays = List.from(widget.selectedDays);
  }

  @override
  void didUpdateWidget(DayPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update local state when parent changes
    if (!_listsEqual(oldWidget.selectedDays, widget.selectedDays)) {
      setState(() {
        selectedDays = List.from(widget.selectedDays);
      });
    }
  }

  bool _listsEqual(List<int> list1, List<int> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (!list2.contains(list1[i])) return false;
    }
    return true;
  }

  String _getDayName(int dayNumber) {
    // Chuyển đổi số ngày thành tên ngày
    switch (dayNumber) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GlobalVariables.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
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
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(7, (index) {
                    int day = index + 1; // Ngày từ 1 đến 7 (Chủ nhật -> Thứ 7)
                    bool isSelected = selectedDays.contains(day);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedDays.remove(day); // Bỏ chọn ngày
                          } else {
                            selectedDays.add(day); // Chọn ngày
                          }
                        });
                        // Truyền danh sách ngày đã chọn cho callback
                        widget.onDaysSelected(selectedDays);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
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
                            _getDayName(day).substring(0, 1).toUpperCase(),
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
          ),
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
