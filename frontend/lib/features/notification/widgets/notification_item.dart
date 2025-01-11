import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_container.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Sử dụng để định dạng ngày giờ

class NotificationItem extends StatelessWidget {
  final String title;
  final String description;
  final String? imgPath;
  final DateTime createdAt; // Thêm thuộc tính createdAt

  const NotificationItem({
    super.key,
    required this.title,
    required this.description,
    this.imgPath,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: CustomContainer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imgPath ?? 'assets/images/badminton_court_default.png',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/badminton_court_default.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _timeText(createdAt), // Hiển thị thời gian
                  _semiBoldSizeText(title),
                  SizedBox(height: 4),
                  _detailText(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _semiBoldSizeText(String text) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _detailText(String text) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: GlobalVariables.darkGrey,
        fontSize: 10,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _timeText(DateTime createdAt) {
    final formattedTime = DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
    return Text(
      formattedTime,
      textAlign: TextAlign.start,
      style: GoogleFonts.inter(
        color: GlobalVariables.green, // Màu chữ cho thời gian
        fontSize: 10,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
