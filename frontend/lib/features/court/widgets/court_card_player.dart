import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/court/screens/court_detail_screen.dart';
import 'package:frontend/models/court.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/providers/player/selected_court_provider.dart';
import 'package:frontend/providers/court_hub_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CourtCardPlayer extends StatelessWidget {
  final Facility facility;
  final Court court;
  final DateTime selectedDate;

  const CourtCardPlayer({
    Key? key,
    required this.facility,
    required this.court,
    required this.selectedDate,
  }) : super(key: key);

  void _navigateToCourtDetail(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: GlobalVariables.green),
                SizedBox(height: 16),
                Text(
                  'Connecting to court...',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Get providers
      final courtHubProvider = Provider.of<CourtHubProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final selectedCourtProvider = Provider.of<SelectedCourtProvider>(context, listen: false);

      // Get access token
      final accessToken = userProvider.user.token;
      if (accessToken.isEmpty) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication required. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Connect to court hub and get real-time court data
      await courtHubProvider.connectToCourt(accessToken, court.id, initialCourt: court);
      
      // Wait a moment for the connection to establish and receive court data
      await Future.delayed(Duration(milliseconds: 500));
      
      // Get the updated court data from the hub
      final updatedCourt = courtHubProvider.getCourt(court.id) ?? court;
      
      // Set selected court with updated data
      selectedCourtProvider.setSelectedCourt(updatedCourt, facility, selectedDate);
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Navigate to single court detail
      Navigator.of(context).pushNamed(CourtDetailScreen.routeName);
      
      print('✅ [CourtCard] Successfully connected to court: ${court.id}');
    } catch (e) {
      // Close loading dialog if still open
      Navigator.of(context).pop();
      
      print('❌ [CourtCard] Error connecting to court ${court.id}: $e');
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect to court. Using offline data.'),
          backgroundColor: Colors.orange,
        ),
      );
      
      // Fallback: use original court data
      final selectedCourtProvider = Provider.of<SelectedCourtProvider>(context, listen: false);
      selectedCourtProvider.setSelectedCourt(court, facility, selectedDate);
      Navigator.of(context).pushNamed(CourtDetailScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToCourtDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: GlobalVariables.grey,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Court icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: GlobalVariables.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.sports_tennis,
                  color: GlobalVariables.green,
                  size: 30,
                ),
              ),
              SizedBox(width: 16),
              // Court info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      court.courtName,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: GlobalVariables.blackGrey,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      court.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: GlobalVariables.darkGrey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          color: GlobalVariables.green,
                          size: 16,
                        ),
                        Text(
                          '${court.pricePerHour.toString()} đ/hour',
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
              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                color: GlobalVariables.darkGrey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
