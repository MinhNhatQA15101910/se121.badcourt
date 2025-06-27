import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_container.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/booking_details/services/booking_detail_service.dart';
import 'package:frontend/features/booking_details/widgets/total_price.dart';
import 'package:frontend/features/booking_management/services/booking_management_service.dart';
import 'package:frontend/features/player/rating/screens/rating_detail_screen.dart';
import 'package:frontend/features/player/rating/screens/rating_screen.dart';
import 'package:frontend/models/order.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BookingDetailScreen extends StatefulWidget {
  static const String routeName = '/booking-detail-screen';
  const BookingDetailScreen({Key? key}) : super(key: key);

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final BookingManagementService _bookingService = BookingManagementService();
  final BookingDetailService _bookingDetailService = BookingDetailService();

  Order? order;
  bool isLoading = true;
  bool isCancelling = false;
  String? error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (order == null) {
      final String orderId =
          ModalRoute.of(context)!.settings.arguments as String;
      _fetchOrderDetails(orderId);
    }
  }

  Future<void> cancelOrder(String orderId) async {
    // Show confirmation dialog first
    bool? shouldCancel = await _showCancelConfirmationDialog();
    if (shouldCancel != true) return;

    setState(() {
      isCancelling = true;
    });

    try {
      bool success = await _bookingDetailService.cancelOrder(
        context: context,
        orderId: orderId,
      );

      if (success) {
        // Refresh the order details to get updated state
        await _fetchOrderDetails(orderId);
      }
    } catch (e) {} finally {
      if (mounted) {
        setState(() {
          isCancelling = false;
        });
      }
    }
  }

  // Add method to navigate to rating screen
  Future<void> _navigateToRatingScreen() async {
    final result = await Navigator.of(context).pushNamed(
      RatingScreen.routeName,
      arguments: order,
    );

    if (result == true) {
      final String orderId =
          ModalRoute.of(context)!.settings.arguments as String;
      await _fetchOrderDetails(orderId);
    }
  }

  void _navigateToRatingDetailScreen() {
    if (order!.rating != null) {
      Navigator.of(context).pushNamed(
        RatingDetailScreen.routeName,
        arguments: order!.rating!.id,
      );
    }
  }

  Future<bool?> _showCancelConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cancel Booking',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: GlobalVariables.blackGrey,
            ),
          ),
          content: Text(
            'Are you sure you want to cancel this booking? This action cannot be undone.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: GlobalVariables.darkGrey,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Keep Booking',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: GlobalVariables.green,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GlobalVariables.red,
                foregroundColor: GlobalVariables.white,
              ),
              child: Text('Cancel Booking'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchOrderDetails(String orderId) async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final fetchedOrder = await _bookingService.fetchOrderById(
        context: context,
        orderId: orderId,
      );

      setState(() {
        order = fetchedOrder;
        isLoading = false;
        if (fetchedOrder == null) {
          error = 'Failed to load booking details';
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = 'An error occurred while loading booking details';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: GlobalVariables.defaultColor,
        appBar: AppBar(
          backgroundColor: GlobalVariables.green,
          title: Text(
            'Booking Details',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null || order == null) {
      return Scaffold(
        backgroundColor: GlobalVariables.defaultColor,
        appBar: AppBar(
          backgroundColor: GlobalVariables.green,
          title: Text(
            'Booking Details',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: GlobalVariables.darkGrey,
              ),
              const SizedBox(height: 16),
              Text(
                error ?? 'Booking not found',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: GlobalVariables.darkGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final String orderId =
                      ModalRoute.of(context)!.settings.arguments as String;
                  _fetchOrderDetails(orderId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlobalVariables.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

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
                  Image.network(
                    order!.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/demo_facility.png',
                      fit: BoxFit.cover,
                    ),
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
                    top: 40,
                    right: 16,
                    child: _buildStatusBadge(order!.state),
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
                          order!.facilityName,
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
                                order!.address,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: GlobalVariables.darkGrey,
                                ),
                                maxLines: 3,
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
                          _formatDateTime(order!.createdAt),
                          icon: Icons.event_note_outlined,
                        ),
                        _buildDivider(),
                        _buildDetailRow(
                          context,
                          'Status',
                          order!.state,
                          valueColor: order!.state == 'Played'
                              ? GlobalVariables.darkGreen
                              : order!.state == 'Cancelled'
                                  ? GlobalVariables.red
                                  : GlobalVariables.darkYellow,
                          icon: order!.state == 'Played'
                              ? Icons.check_circle_outline
                              : order!.state == 'Cancelled'
                                  ? Icons.cancel
                                  : Icons.schedule,
                          iconColor: order!.state == 'Played'
                              ? GlobalVariables.darkGreen
                              : order!.state == 'Cancelled'
                                  ? GlobalVariables.darkRed
                                  : GlobalVariables.darkYellow,
                        ),
                        // Show rating if it exists
                        if (order!.rating != null) ...[
                          _buildDivider(),
                          _buildDetailRow(
                            context,
                            'Your Rating',
                            '${order!.rating!.stars} stars',
                            valueColor: Colors.amber,
                            icon: Icons.star,
                            iconColor: Colors.amber,
                          ),
                          if (order!.rating!.feedback.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: GlobalVariables.green.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: GlobalVariables.green.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your Feedback:',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: GlobalVariables.darkGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    order!.rating!.feedback,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: GlobalVariables.blackGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
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
                              DateFormat('EEEE, dd/MM/yyyy')
                                  .format(order!.timePeriod.hourFrom),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      color: GlobalVariables.green
                                          .withOpacity(0.1),
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
                                    '${DateFormat('HH:mm').format(order!.timePeriod.hourFrom)} - ${DateFormat('HH:mm').format(order!.timePeriod.hourTo)}',
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
                                    ).format(order!.price),
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
                  TotalPrice(promotionPrice: 0, subTotalPrice: order!.price),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _shouldShowRatingButton()
                                ? _navigateToRatingScreen
                                : order!.rating != null
                                    ? _navigateToRatingDetailScreen
                                    : null,
                            icon: Icon(_shouldShowRatingButton()
                                ? Icons.star_outline
                                : Icons.visibility_outlined),
                            label: Text(_shouldShowRatingButton()
                                ? 'Rate Experience'
                                : 'View Rating'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: GlobalVariables.green,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: GlobalVariables.green),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: (order!.state != 'NotPlay' ||
                                    isCancelling)
                                ? null
                                : () => cancelOrder(order!.id),
                            icon: isCancelling
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.red),
                                    ),
                                  )
                                : const Icon(
                                    Icons.cancel_outlined,
                                    color: Colors.red,
                                  ),
                            label: Text(isCancelling
                                ? 'Cancelling...'
                                : 'Cancel Booking'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  (order!.state != 'NotPlay' || isCancelling)
                                      ? Colors.grey.shade300
                                      : Colors.white,
                              foregroundColor:
                                  (order!.state != 'NotPlay' || isCancelling)
                                      ? Colors.grey.shade600
                                      : Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: (order!.state != 'NotPlay' ||
                                          isCancelling)
                                      ? Colors.grey.shade300
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add method to determine if rating button should be shown
  bool _shouldShowRatingButton() {
    return order!.rating == null && order!.state == 'Played';
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}, ${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
