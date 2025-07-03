import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/common/widgets/custom_button.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/player/player_bottom_bar.dart';
import 'package:frontend/features/player/checkout/services/stripe_service.dart';
import 'package:frontend/features/player/checkout/widgets/checkout_item.dart';
import 'package:frontend/features/player/checkout/widgets/checkout_total_price.dart';
import 'package:frontend/providers/manager/current_facility_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/checkout_provider.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends StatefulWidget {
  static const String routeName = '/checkoutScreen';

  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _stripeService = StripeService();
  bool _isProcessingPayment = false;
  bool _paymentSuccessful = false;

  Future<void> _processStripePayment(
    String courtId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    print('🔄 [CheckoutScreen] Starting payment process...');

    if (_isProcessingPayment) {
      print('⚠️ [CheckoutScreen] Payment already in progress, ignoring...');
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      print('🔄 [CheckoutScreen] Calling Stripe service...');

      final success = await _stripeService.processPayment(
        context,
        courtId,
        startTime,
        endTime,
      );

      print('🔄 [CheckoutScreen] Stripe service returned: $success');

      if (success == true) {
        print('✅ [CheckoutScreen] Payment successful, showing success UI...');

        if (mounted) {
          setState(() {
            _paymentSuccessful = true;
            _isProcessingPayment = false;
          });
        }
      } else {
        print('❌ [CheckoutScreen] Payment failed or returned false');

        if (mounted) {
          setState(() {
            _isProcessingPayment = false;
          });

          IconSnackBar.show(
            context,
            label: 'Payment was not completed. Please try again.',
            snackBarType: SnackBarType.fail,
          );
        }
      }
    } catch (e, stackTrace) {
      print('❌ [CheckoutScreen] Payment error: $e');
      print('❌ [CheckoutScreen] Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });

        IconSnackBar.show(
          context,
          label: 'Payment failed. Please try again.',
          snackBarType: SnackBarType.fail,
        );
      }
    }
  }

  // Navigate to home
  void _navigateToHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      PlayerBottomBar.routeName,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentFacilityProvider = context.watch<CurrentFacilityProvider>();

    return SafeArea(
      child: Scaffold(
        backgroundColor: GlobalVariables.defaultColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: GlobalVariables.green,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              if (_isProcessingPayment) {
                IconSnackBar.show(
                  context,
                  label: 'Please wait for payment to complete',
                  snackBarType: SnackBarType.alert,
                );
                return;
              }
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'Checkout', // MODIFIED: Always show "Checkout"
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: WillPopScope(
          onWillPop: () async {
            // MODIFIED: Allow normal back navigation
            if (_isProcessingPayment) {
              IconSnackBar.show(
                context,
                label: 'Please wait for payment to complete',
                snackBarType: SnackBarType.alert,
              );
              return false;
            }
            return true; // Allow back navigation
          },
          child: Consumer<CheckoutProvider>(
            builder: (context, checkoutProvider, child) {
              final court = checkoutProvider.court;
              final startDate = checkoutProvider.startDate;
              final endDate = checkoutProvider.endDate;
              final durationHours =
                  endDate.difference(startDate).inMinutes / 60;
              final pricePerHour = court.pricePerHour;
              final totalPrice = durationHours * pricePerHour;

              // Show success UI when payment is successful
              if (_paymentSuccessful) {
                return _buildSuccessUI(court, startDate, endDate, totalPrice);
              }

              // Original checkout UI
              return _buildCheckoutUI(currentFacilityProvider, court, startDate,
                  endDate, totalPrice);
            },
          ),
        ),
      ),
    );
  }

  // Success UI
  Widget _buildSuccessUI(
      court, DateTime startDate, DateTime endDate, double totalPrice) {
    final durationHours = endDate.difference(startDate).inHours;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Booking Successful!',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: GlobalVariables.green,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  // Success Message
                  Text(
                    'Your court has been successfully booked. You can view your booking details below.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: GlobalVariables.darkGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Booking Details Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
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
                            Text(
                              'Booking Details',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: GlobalVariables.blackGrey,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Court Name
                        _buildDetailRow(
                          'Court',
                          court.courtName,
                          Icons.sports_tennis,
                        ),

                        const SizedBox(height: 12),

                        // Date
                        _buildDetailRow(
                          'Date',
                          DateFormat('EEEE, dd MMMM yyyy').format(startDate),
                          Icons.calendar_today,
                        ),

                        const SizedBox(height: 12),

                        // Time
                        _buildDetailRow(
                          'Time',
                          '${DateFormat('HH:mm').format(startDate)} - ${DateFormat('HH:mm').format(endDate)}',
                          Icons.access_time,
                        ),

                        const SizedBox(height: 12),

                        // Duration
                        _buildDetailRow(
                          'Duration',
                          '$durationHours hour${durationHours > 1 ? 's' : ''}',
                          Icons.timelapse,
                        ),

                        const SizedBox(height: 20),

                        // Divider
                        Container(
                          height: 1,
                          color: GlobalVariables.lightGrey,
                        ),

                        const SizedBox(height: 20),

                        // Total Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: GlobalVariables.blackGrey,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: GlobalVariables.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${NumberFormat('#,###').format(totalPrice)} đ',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: GlobalVariables.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),

        // MODIFIED: Only Go Home Button
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity, // MODIFIED: Full width button
              child: CustomButton(
                buttonText: 'Go Home',
                borderColor: GlobalVariables.green,
                fillColor: GlobalVariables.green,
                textColor: Colors.white,
                onTap: _navigateToHome,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Detail row widget
  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: GlobalVariables.lightGrey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: GlobalVariables.darkGrey,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: GlobalVariables.darkGrey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: GlobalVariables.blackGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Original checkout UI
  Widget _buildCheckoutUI(currentFacilityProvider, court, DateTime startDate,
      DateTime endDate, double totalPrice) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Facility Image
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: Image.network(
                      currentFacilityProvider
                          .currentFacility.facilityImages.first.url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: GlobalVariables.lightGrey,
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 50),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Facility Name
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: GlobalVariables.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.location_city,
                          color: GlobalVariables.green,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentFacilityProvider
                                  .currentFacility.facilityName,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: GlobalVariables.blackGrey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: GlobalVariables.darkGrey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    currentFacilityProvider
                                        .currentFacility.province,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: GlobalVariables.darkGrey,
                                    ),
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
                const SizedBox(height: 20),
                // Booking Details Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Booking Details',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: GlobalVariables.blackGrey,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Checkout Item
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: CheckoutItem(),
                ),
                const SizedBox(height: 20),
                // Total Price
                CheckoutTotalPrice(
                  promotionPrice: 0,
                  subTotalPrice: totalPrice,
                ),
                const SizedBox(height: 20),
                // Payment Method Info
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: GlobalVariables.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.payment,
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
                              'Secure Payment',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: GlobalVariables.blackGrey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Powered by Stripe - Your payment is secure',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: GlobalVariables.darkGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.security,
                        color: GlobalVariables.green,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Payment Status Indicator
                if (_isProcessingPayment)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Processing Payment...',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Please do not close the app or go back',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.blue.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Bottom Checkout Button
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: CustomButton(
              buttonText: _isProcessingPayment
                  ? 'Processing Payment...'
                  : 'Pay & Confirm Booking',
              borderColor: GlobalVariables.green,
              fillColor: _isProcessingPayment
                  ? GlobalVariables.darkGrey
                  : GlobalVariables.green,
              textColor: Colors.white,
              onTap: () {
                if (!_isProcessingPayment) {
                  print('🔄 [CheckoutScreen] User tapped payment button');
                  _processStripePayment(
                    court.id,
                    startDate,
                    endDate,
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
