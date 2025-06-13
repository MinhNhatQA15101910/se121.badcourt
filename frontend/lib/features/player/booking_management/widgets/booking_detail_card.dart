import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/player/booking_details/screens/booking_detail_screen.dart';
import 'package:frontend/models/order.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BookingDetailCard extends StatelessWidget {
  const BookingDetailCard({
    super.key,
    required this.order,
  });

  final Order order;

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime playTime = order.timePeriod.hourFrom;
    bool isPlayed = now.isAfter(playTime);

    void _navigateToBookingDetailScreen() {
      Navigator.of(context).pushNamed(
        BookingDetailScreen.routeName,
        arguments: order,
      );
    }

    return GestureDetector(
      onTap: _navigateToBookingDetailScreen,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date and status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: GlobalVariables.green.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: GlobalVariables.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEE, dd MMM yyyy').format(playTime),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: GlobalVariables.darkGrey,
                        ),
                      ),
                    ],
                  ),
                  _buildStatusBadge(isPlayed),
                ],
              ),
            ),

            // Court details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Court image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: GlobalVariables.lightGrey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: order.image.url.isNotEmpty
                          ? Image.network(
                              order.image.url,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                'assets/images/badminton_court_default.png',
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              'assets/images/badminton_court_default.png',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Court information
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.facilityName,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: GlobalVariables.blackGrey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: GlobalVariables.darkGrey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                order.address,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: GlobalVariables.darkGrey,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: GlobalVariables.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('HH:mm')
                                      .format(order.timePeriod.hourFrom) +
                                  ' - ' +
                                  DateFormat('HH:mm')
                                      .format(order.timePeriod.hourTo),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: GlobalVariables.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          NumberFormat.currency(
                            locale: 'vi_VN',
                            symbol: '₫',
                            decimalDigits: 0,
                          ).format(order.price),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: GlobalVariables.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Footer with payment method
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: GlobalVariables.lightGrey,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment Method',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: GlobalVariables.darkGrey,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.payment_rounded,
                        size: 16,
                        color: GlobalVariables.darkGrey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Google Pay',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: GlobalVariables.blackGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isPlayed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            isPlayed ? GlobalVariables.lightGreen : GlobalVariables.lightYellow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPlayed ? Icons.check_circle_outline : Icons.schedule,
            size: 14,
            color: isPlayed
                ? GlobalVariables.darkGreen
                : GlobalVariables.darkYellow,
          ),
          const SizedBox(width: 4),
          Text(
            isPlayed ? 'Played' : 'Pending',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isPlayed
                  ? GlobalVariables.darkGreen
                  : GlobalVariables.darkYellow,
            ),
          ),
        ],
      ),
    );
  }
}
