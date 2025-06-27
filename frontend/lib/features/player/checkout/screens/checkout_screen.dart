import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/common/widgets/custom_button.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/player/checkout/screens/booking_success_screen.dart';
import 'package:frontend/features/player/checkout/widgets/checkout_item.dart';
import 'package:frontend/features/player/checkout/widgets/checkout_total_price.dart';
import 'package:frontend/features/facility_detail/services/facility_detail_service.dart';
import 'package:frontend/providers/manager/current_facility_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/checkout_provider.dart';

class CheckoutScreen extends StatefulWidget {
  static const String routeName = '/checkoutScreen';
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _facilityDetailService = FacilityDetailService();
  bool _isBooking = false;

  void _navigateToSuccessScreen() {
    Navigator.of(context).pushReplacementNamed(BookingSuccessScreen.routeName);
  }

  Future<void> bookCourt(
    String id,
    DateTime startTime,
    DateTime endTime,
  ) async {
    setState(() {
      _isBooking = true;
    });

    try {
      await _facilityDetailService.bookCourt(
        context,
        id,
        startTime,
        endTime,
      );
      
      // Navigate to success screen
      _navigateToSuccessScreen();
    } catch (e) {
      IconSnackBar.show(
        context,
        label: 'Booking failed. Please try again.',
        snackBarType: SnackBarType.fail,
      );
      setState(() {
        _isBooking = false;
      });
    }
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
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Checkout',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: Consumer<CheckoutProvider>(
          builder: (context, checkoutProvider, child) {
            final court = checkoutProvider.court;
            final startDate = checkoutProvider.startDate;
            final endDate = checkoutProvider.endDate;
            final durationHours = endDate.difference(startDate).inHours;
            final pricePerHour = court.pricePerHour;
            final totalPrice = durationHours * pricePerHour;

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
                              currentFacilityProvider.currentFacility.facilityImages.first.url,
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
                                      currentFacilityProvider.currentFacility.facilityName,
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
                                            currentFacilityProvider.currentFacility.province,
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
                          subTotalPrice: totalPrice.toDouble(),
                        ),

                        const SizedBox(height: 20),
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
                      buttonText: _isBooking ? 'Processing...' : 'Confirm Booking',
                      borderColor: GlobalVariables.green,
                      fillColor: _isBooking ? GlobalVariables.darkGrey : GlobalVariables.green,
                      textColor: Colors.white,
                      onTap: () {
                        if (!_isBooking) {
                          bookCourt(
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
          },
        ),
      ),
    );
  }
}
