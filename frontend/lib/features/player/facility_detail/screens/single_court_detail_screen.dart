import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/player/facility_detail/widgets/booking_widget_player.dart';
import 'package:frontend/providers/player/selected_court_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class SingleCourtDetailScreen extends StatefulWidget {
  static const String routeName = '/singleCourtDetail';

  const SingleCourtDetailScreen({Key? key}) : super(key: key);

  @override
  _SingleCourtDetailScreenState createState() => _SingleCourtDetailScreenState();
}

class _SingleCourtDetailScreenState extends State<SingleCourtDetailScreen> {
  @override
  Widget build(BuildContext context) {
    print('SingleCourtDetailScreen build called');
    
    return Consumer<SelectedCourtProvider>(
      builder: (context, selectedCourtProvider, child) {
        print('Provider data - Court: ${selectedCourtProvider.selectedCourt?.courtName}');
        print('Provider data - Facility: ${selectedCourtProvider.selectedFacility?.facilityName}');
        
        final court = selectedCourtProvider.selectedCourt;
        final facility = selectedCourtProvider.selectedFacility;
        final selectedDate = selectedCourtProvider.selectedDate;

        if (court == null || facility == null || selectedDate == null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: GlobalVariables.green,
              title: Text(
                'Court Detail',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: GlobalVariables.white,
                ),
              ),
            ),
            body: Center(
              child: Text(
                'No court selected',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: GlobalVariables.green,
            title: Text(
              DateFormat('EEE, dd/MM/yyyy').format(selectedDate),
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: GlobalVariables.white,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.notifications_outlined,
                  color: GlobalVariables.white,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.message_outlined,
                  color: GlobalVariables.white,
                ),
              ),
            ],
          ),
          body: Container(
            color: GlobalVariables.defaultColor,
            child: Column(
              children: [
                // Court info header
                Container(
                  color: GlobalVariables.white,
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: GlobalVariables.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.sports_tennis,
                          color: GlobalVariables.green,
                          size: 40,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              court.courtName,
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: GlobalVariables.blackGrey,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              court.description,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: GlobalVariables.darkGrey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${court.pricePerHour.toString()} đ/hour',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: GlobalVariables.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                // Booking widget
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: BookingWidgetPlayer(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
