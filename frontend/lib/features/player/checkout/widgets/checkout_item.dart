import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/separator.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/checkout_provider.dart'; // Import CheckoutProvider

class CheckoutItem extends StatelessWidget {
  const CheckoutItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckoutProvider>(
      builder: (context, checkoutProvider, child) {
        final startDate = checkoutProvider.startDate;
        final endDate = checkoutProvider.endDate;
        final court = checkoutProvider.court;
        final pricePerHour = court.pricePerHour;

        final DateFormat timeFormat = DateFormat('HH:mm'); // Định dạng giờ

        // Tính toán tổng số giờ và giá
        final durationHours = endDate.difference(startDate).inHours;
        final totalPrice = durationHours * pricePerHour;

        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InterBold14(
                court.courtName,
                GlobalVariables.blackGrey,
                1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InterRegular14(
                    '${timeFormat.format(startDate)} - ${timeFormat.format(endDate)}', // Hiển thị khoảng thời gian
                    GlobalVariables.blackGrey,
                    1,
                  ),
                  _InterSemiBold14(
                    '$totalPrice\ đ', // Hiển thị giá
                    GlobalVariables.blackGrey,
                    1,
                  ),
                ],
              ),
              Separator(color: GlobalVariables.darkGrey),
            ],
          ),
        );
      },
    );
  }

  Widget _InterRegular14(String text, Color color, int maxLines) {
    return Container(
      child: Text(
        text,
        textAlign: TextAlign.start,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _InterSemiBold14(String text, Color color, int maxLines) {
    return Container(
      child: Text(
        text,
        textAlign: TextAlign.start,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _InterBold14(String text, Color color, int maxLines) {
    return Container(
      child: Text(
        text,
        textAlign: TextAlign.start,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
