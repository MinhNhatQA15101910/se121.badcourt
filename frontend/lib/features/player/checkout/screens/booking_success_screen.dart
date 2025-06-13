import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_button.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/player/facility_detail/screens/court_detail_screen.dart';
import 'package:frontend/features/player/player_bottom_bar.dart';
import 'package:frontend/providers/checkout_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

class BookingSuccessScreen extends StatelessWidget {
  static const String routeName = '/bookingSuccess';

  const BookingSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final checkoutProvider = Provider.of<CheckoutProvider>(context);
    final court = checkoutProvider.court;
    final startDate = checkoutProvider.startDate;
    final endDate = checkoutProvider.endDate;
    final durationHours = endDate.difference(startDate).inHours;
    final totalPrice = durationHours * court.pricePerHour;

    return WillPopScope(
      // Prevent back button from going back to checkout screen
      onWillPop: () async {
        _navigateToCourts(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: GlobalVariables.green,
          automaticallyImplyLeading: false,
          title: Text(
            'Booking Confirmation',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        
                        // Success Animation
                        Container(
                          height: 200,
                          width: 200,
                          child: Lottie.network(
                            'https://assets9.lottiefiles.com/packages/lf20_jbrw3hcz.json',
                            repeat: false,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Success Title
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
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        
                        // Booking ID
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: GlobalVariables.lightGrey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Booking ID',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: GlobalVariables.darkGrey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '#${DateTime.now().millisecondsSinceEpoch.toString().substring(5, 13)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: GlobalVariables.blackGrey,
                                    ),
                                  ),
                                  Icon(
                                    Icons.content_copy,
                                    size: 18,
                                    color: GlobalVariables.green,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Bottom Buttons
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
                  child: Row(
                    children: [
                      // View Courts Button
                      Expanded(
                        child: CustomButton(
                          buttonText: 'View Courts',
                          borderColor: GlobalVariables.green,
                          fillColor: Colors.white,
                          textColor: GlobalVariables.green,
                          onTap: () => _navigateToCourts(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Go Home Button
                      Expanded(
                        child: CustomButton(
                          buttonText: 'Go Home',
                          borderColor: GlobalVariables.green,
                          fillColor: GlobalVariables.green,
                          textColor: Colors.white,
                          onTap: () => _navigateToHome(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCourts(BuildContext context) {
    // Tìm màn hình CourtDetailScreen trong stack
    bool foundCourtDetailScreen = false;
    
    Navigator.popUntil(context, (route) {
      // Kiểm tra xem route hiện tại có phải là CourtDetailScreen không
      if (route.settings.name == CourtDetailScreen.routeName) {
        foundCourtDetailScreen = true;
        return true;
      }
      
      // Nếu đã tìm thấy CourtDetailScreen, dừng lại
      if (foundCourtDetailScreen) {
        return true;
      }
      
      // Tiếp tục tìm kiếm
      return false;
    });
    
    // Nếu không tìm thấy CourtDetailScreen trong stack, điều hướng đến đó
    if (!foundCourtDetailScreen) {
      Navigator.pushNamed(context, CourtDetailScreen.routeName);
    }
  }

  void _navigateToHome(BuildContext context) {
    // Tìm màn hình PlayerBottomBar trong stack
    bool foundHomeScreen = false;
    
    Navigator.popUntil(context, (route) {
      // Kiểm tra xem route hiện tại có phải là PlayerBottomBar không
      if (route.settings.name == PlayerBottomBar.routeName) {
        foundHomeScreen = true;
        return true;
      }
      
      // Nếu đã tìm thấy PlayerBottomBar, dừng lại
      if (foundHomeScreen) {
        return true;
      }
      
      // Tiếp tục tìm kiếm
      return false;
    });
    
    // Nếu không tìm thấy PlayerBottomBar trong stack, điều hướng đến đó
    if (!foundHomeScreen) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        PlayerBottomBar.routeName,
        (route) => false,
      );
    }
  }

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
}
