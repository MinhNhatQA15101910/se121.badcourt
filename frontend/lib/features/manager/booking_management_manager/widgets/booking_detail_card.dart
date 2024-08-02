import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/booking_details_manager/screens/booking_detail_manager_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingDetailCardManager extends StatefulWidget {
  const BookingDetailCardManager({super.key});

  @override
  State<BookingDetailCardManager> createState() =>
      _BookingDetailCardManagerState();
}

class _BookingDetailCardManagerState extends State<BookingDetailCardManager> {
  @override
  Widget build(BuildContext context) {
    void _navigateToBookingDetailManagerScreen() {
      Navigator.of(context).pushNamed(BookingDetailManagerScreen.routeName);
    }

    return GestureDetector(
      onTap: _navigateToBookingDetailManagerScreen,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID: 000001',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: GlobalVariables.blackGrey),
                    ),
                    Text(
                      'Saturday, 29/03/2024',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: GlobalVariables.darkGrey),
                    ),
                    Text(
                      'Nguyễn Văn Người Chơi',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: GlobalVariables.darkGrey),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: GlobalVariables.lightGreen,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'Played',
                    style: TextStyle(
                      fontSize: 14,
                      color: GlobalVariables.darkGreen,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: GlobalVariables.lightGrey),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image(
                        image: AssetImage('assets/images/demo_facility.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sân cầu lông nhật duy 123456789',
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: GlobalVariables.blackGrey),
                        ),
                        Text(
                          'Đường hàng Thuyên, khu phố 6, Phường Linh Trung, TP Thủ Đức',
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: GlobalVariables.darkGrey),
                        ),
                        Text(
                          'Price: \$20',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: GlobalVariables.darkGrey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment Method: ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  'Method Name',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
