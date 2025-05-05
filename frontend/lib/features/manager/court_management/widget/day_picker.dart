import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/providers/manager/current_facility_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
  late List<int> selectedDays;

  @override
  void initState() {
    super.initState();
    // Lấy danh sách ngày từ provider
    final currentFacilityProvider =
        Provider.of<CurrentFacilityProvider>(context, listen: false);
    final scheduleKeys = currentFacilityProvider.currentFacility.activeAt?.schedule.keys;

selectedDays = scheduleKeys != null
    ? scheduleKeys
        .map(_getDayNumber)
        .whereType<int>()
        .toList()
    : [];

  }

  int? _getDayNumber(String dayName) {
    // Chuyển đổi tên ngày thành số ngày
    switch (dayName.toLowerCase()) {
      case 'sunday':
        return 1;
      case 'monday':
        return 2;
      case 'tuesday':
        return 3;
      case 'wednesday':
        return 4;
      case 'thursday':
        return 5;
      case 'friday':
        return 6;
      case 'saturday':
        return 7;
      default:
        return null;
    }
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
