import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/court_management/widget/item_time_slot.dart';
import 'package:google_fonts/google_fonts.dart';

class CourtManagementDetailScreen extends StatefulWidget {
  static const String routeName = '/court-management-detail';

  const CourtManagementDetailScreen({super.key});

  @override
  State<CourtManagementDetailScreen> createState() =>
      _CourtManagementDetailScreenState();
}

class _CourtManagementDetailScreenState
    extends State<CourtManagementDetailScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                'Court 1',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.none,
                  color: GlobalVariables.white,
                ),
              ),
              IconButton(
                onPressed: () {},
                iconSize: 24,
                icon: const Icon(
                  Icons.more_vert_outlined,
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
          children: [
            Container(
              color: GlobalVariables.white,
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _InterBold16(
                        'Time slots', GlobalVariables.blackGrey, 1),
                  ),
                ],
              ),
            ),
            ItemTimeSlot(timeRange: '07:30 - 11:30', price: '120.000đ'),
            ItemTimeSlot(timeRange: '07:30 - 11:30', price: '120.000đ'),
            ItemTimeSlot(timeRange: '07:30 - 11:30', price: '120.000đ'),
            ItemTimeSlot(timeRange: '07:30 - 11:30', price: '120.000đ'),
          ],
        ),
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
