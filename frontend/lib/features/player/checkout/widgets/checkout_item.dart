import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/checkout_provider.dart';

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

        final DateFormat timeFormat = DateFormat('HH:mm');
        final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

        // Calculate duration and total price
        final durationHours = endDate.difference(startDate).inMinutes / 60;
        final totalPrice = durationHours * pricePerHour;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Court name with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: GlobalVariables.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.sports_tennis,
                      color: GlobalVariables.green,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          court.courtName,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: GlobalVariables.blackGrey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Court ID: ${court.id}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: GlobalVariables.darkGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Booking details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: GlobalVariables.defaultColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: GlobalVariables.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Date: ${dateFormat.format(startDate)}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: GlobalVariables.blackGrey,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Time range
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: GlobalVariables.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Time: ${timeFormat.format(startDate)} - ${timeFormat.format(endDate)}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: GlobalVariables.blackGrey,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Duration
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 16,
                          color: GlobalVariables.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Duration: $durationHours hour${durationHours > 1 ? 's' : ''}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: GlobalVariables.blackGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Price breakdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price per hour',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: GlobalVariables.darkGrey,
                        ),
                      ),
                      Text(
                        '${NumberFormat('#,###').format(pricePerHour)} đ/hour',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: GlobalVariables.blackGrey,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total amount',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: GlobalVariables.darkGrey,
                        ),
                      ),
                      Text(
                        '${NumberFormat('#,###').format(totalPrice)} đ',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: GlobalVariables.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
