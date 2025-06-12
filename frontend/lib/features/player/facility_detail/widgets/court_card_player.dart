import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/player/facility_detail/screens/single_court_detail_screen.dart';
import 'package:frontend/models/court.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/providers/player/selected_court_provider.dart';
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

  void _navigateToCourtDetail(BuildContext context) {
    // Set selected court in provider
    final selectedCourtProvider = Provider.of<SelectedCourtProvider>(context, listen: false);
    selectedCourtProvider.setSelectedCourt(court, facility, selectedDate);
        
    // Navigate to single court detail
    Navigator.of(context).pushNamed(SingleCourtDetailScreen.routeName);
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
