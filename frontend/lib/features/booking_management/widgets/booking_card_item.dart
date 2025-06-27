import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/booking_details/screens/booking_detail_screen.dart';
import 'package:frontend/models/order.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BookingCardItem extends StatelessWidget {
  const BookingCardItem({
    super.key,
    required this.order,
  });

  final Order order;

  @override
  Widget build(BuildContext context) {
    DateTime playTime = order.timePeriod.hourFrom;

    void _navigateToBookingDetailScreen() {
      Navigator.of(context).pushNamed(
        BookingDetailScreen.routeName,
        arguments: order.id,
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
                  _buildStatusBadge(order.state),
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
                        child: Image.network(
                          order.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                            'assets/images/badminton_court_default.png',
                            fit: BoxFit.cover,
                          ),
                        )),
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

            // Footer with payment method and rating status
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
                  // Payment method
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
                  
                  // Rating status for played bookings
                  if (order.state == 'Played')
                    _buildRatingStatus(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStatus() {
    final bool hasRating = order.rating != null;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: hasRating 
            ? Colors.amber.withOpacity(0.1)
            : GlobalVariables.lightGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasRating 
              ? Colors.amber.withOpacity(0.3)
              : GlobalVariables.darkGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasRating ? Icons.star : Icons.star_border,
            size: 14,
            color: hasRating ? Colors.amber : GlobalVariables.darkGrey,
          ),
          const SizedBox(width: 4),
          Text(
            hasRating ? 'Rated' : 'Not Rated',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: hasRating ? Colors.amber.shade700 : GlobalVariables.darkGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: state == 'Played'
            ? GlobalVariables.lightGreen.withOpacity(0.9)
            : state == "Cancelled"
                ? GlobalVariables.lightRed.withOpacity(0.9)
                : GlobalVariables.lightYellow.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            state == "Played"
                ? Icons.check_circle_outline
                : state == "Cancelled"
                    ? Icons.cancel
                    : Icons.schedule,
            size: 14,
            color: state == "Played"
                ? GlobalVariables.darkGreen
                : state == "Cancelled"
                    ? GlobalVariables.darkRed
                    : GlobalVariables.darkYellow,
          ),
          const SizedBox(width: 4),
          Text(
            state,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: state == "Played"
                  ? GlobalVariables.darkGreen
                  : state == "Cancelled"
                      ? GlobalVariables.darkRed
                      : GlobalVariables.darkYellow,
            ),
          ),
        ],
      ),
    );
  }
}
