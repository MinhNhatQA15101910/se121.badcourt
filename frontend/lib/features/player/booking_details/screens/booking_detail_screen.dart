import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_container.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/player/booking_details/widgets/total_price.dart';
import 'package:frontend/models/order.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BookingDetailScreen extends StatelessWidget {
  static const String routeName = '/booking-detail-screen';
  const BookingDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)!.settings.arguments as Order;
    DateTime now = DateTime.now();
    DateTime playTime = order.timePeriod.hourFrom;
    bool isPlayed = now.isAfter(playTime);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: GlobalVariables.green,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Court Image
                  order.image.url.isNotEmpty
                      ? Image.network(
                          order.image.url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            'assets/images/demo_facility.png',
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          'assets/images/demo_facility.png',
                          fit: BoxFit.cover,
                        ),
                  // Gradient overlay for better text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                  // Status badge
                  Positioned(
                    top: 16,
                    right: 16,
                    child: _buildStatusBadge(isPlayed),
                  ),
                ],
              ),
              title: Text(
                'Booking Details',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 72, bottom: 16),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Container(
              color: GlobalVariables.defaultColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Facility Name
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.facilityName,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: GlobalVariables.blackGrey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: GlobalVariables.green,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                order.address,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: GlobalVariables.darkGrey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Booking Details Section
                  _buildSectionHeader(context, 'Booking Details'),
                  CustomContainer(
                    child: Column(
                      children: [
                        _buildDetailRow(
                          context,
                          'Booking Date',
                          _formatDateTime(order.createdAt),
                          icon: Icons.event_note_outlined,
                        ),
                        _buildDivider(),
                        _buildDetailRow(
                          context,
                          'Status',
                          isPlayed ? 'Played' : 'Pending',
                          valueColor: isPlayed
                              ? GlobalVariables.darkGreen
                              : GlobalVariables.darkYellow,
                          icon: isPlayed
                              ? Icons.check_circle_outline
                              : Icons.schedule,
                          iconColor: isPlayed
                              ? GlobalVariables.darkGreen
                              : GlobalVariables.darkYellow,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Facility Owner Section
                  _buildSectionHeader(context, 'Facility Owner'),
                  CustomContainer(
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: GlobalVariables.lightGrey,
                              width: 1,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/demo_facility.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mai Hoàng Nhật Duy',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: GlobalVariables.blackGrey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: GlobalVariables.darkGrey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'TP Hồ Chí Minh',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: GlobalVariables.darkGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.message_outlined,
                            color: GlobalVariables.green,
                          ),
                          onPressed: () {
                            // Contact owner functionality
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Booking Info Section
                  _buildSectionHeader(context, 'Booking Information'),
                  CustomContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: GlobalVariables.green,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('EEEE, dd/MM/yyyy').format(order.timePeriod.hourFrom),
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: GlobalVariables.blackGrey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: GlobalVariables.green.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: GlobalVariables.green.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Court 1',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: GlobalVariables.blackGrey,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: GlobalVariables.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Badminton',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: GlobalVariables.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: GlobalVariables.darkGrey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${DateFormat('HH:mm').format(order.timePeriod.hourFrom)} - ${DateFormat('HH:mm').format(order.timePeriod.hourTo)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: GlobalVariables.darkGrey,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    NumberFormat.currency(
                                      locale: 'vi_VN',
                                      symbol: '₫',
                                      decimalDigits: 0,
                                    ).format(order.price),
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: GlobalVariables.green,
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
                  
                  const SizedBox(height: 16),
                  
                  // Payment Summary
                  TotalPrice(promotionPrice: 0, subTotalPrice: order.price),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: GlobalVariables.blackGrey,
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    IconData? icon,
    Color? valueColor,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: iconColor ?? GlobalVariables.green,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: GlobalVariables.darkGrey,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? GlobalVariables.blackGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: GlobalVariables.lightGrey,
    );
  }

  Widget _buildStatusBadge(bool isPlayed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        color: isPlayed
            ? GlobalVariables.lightGreen.withOpacity(0.9)
            : GlobalVariables.lightYellow.withOpacity(0.9),
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}, ${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
