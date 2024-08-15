import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/player/booking_details/screens/booking_detail_screen.dart';
import 'package:frontend/models/order.dart';
import 'package:frontend/providers/player/player_order_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BookingDetailCard extends StatefulWidget {
  const BookingDetailCard({
    super.key,
    required this.order,
  });

  final Order order;

  @override
  State<BookingDetailCard> createState() => _BookingDetailCardState();
}

class _BookingDetailCardState extends State<BookingDetailCard> {
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime playTime = widget.order.period.hourFrom;
    bool isPlayed = now.isAfter(playTime);

    void _navigateToBookingDetailScreen() {
      context.read<PlayerOrderProvider>().setOrder(widget.order);
      Navigator.of(context).pushNamed(BookingDetailScreen.routeName);
    }

    return GestureDetector(
      onTap: _navigateToBookingDetailScreen,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, dd/MM/yyyy').format(
                        playTime,
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: GlobalVariables.darkGrey,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isPlayed
                        ? GlobalVariables.lightGreen
                        : GlobalVariables.lightYellow,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    isPlayed ? 'Played' : 'Not Play',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isPlayed
                          ? GlobalVariables.darkGreen
                          : GlobalVariables.darkYellow,
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
                      child: widget.order.imageUrl.isNotEmpty
                          ? Image.network(
                              widget.order.imageUrl,
                              fit: BoxFit.fill,
                            )
                          : Image.asset(
                              'assets/images/badminton_court_default.png',
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
                          widget.order.facilityName,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: GlobalVariables.blackGrey),
                        ),
                        Text(
                          widget.order.address,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: GlobalVariables.darkGrey),
                        ),
                        Text(
                          'Price: ${NumberFormat.currency(
                            locale: 'vi_VN',
                            symbol: 'đ',
                          ).format(widget.order.price)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: GlobalVariables.darkGrey,
                          ),
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
                  'Google Pay',
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
