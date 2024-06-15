import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_container.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';

class ItemTimeSlot extends StatelessWidget {
  final String timeRange;
  final String price;

  const ItemTimeSlot({
    super.key,
    required this.timeRange,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: CustomContainer(
        child: Row(
          children: [
            Expanded(
              child: _mediumSizeText18(timeRange),
            ),
            SizedBox(
              width: 8,
            ),
            _regularSizeText16(price)
          ],
        ),
      ),
    );
  }

  Widget _mediumSizeText18(String text) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: GlobalVariables.blackGrey,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _regularSizeText16(String text) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: GlobalVariables.green,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
