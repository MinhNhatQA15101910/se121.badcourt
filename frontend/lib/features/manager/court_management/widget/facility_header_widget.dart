import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/facility.dart';
import 'package:google_fonts/google_fonts.dart';

class FacilityHeaderWidget extends StatelessWidget {
  final Facility facility;

  const FacilityHeaderWidget({
    super.key,
    required this.facility,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Facility Image
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(facility.facilityImages.first.url),
              fit: BoxFit.fill,
            ),
          ),
          child: AspectRatio(aspectRatio: 2 / 1),
        ),
        
        // Facility Name
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
          color: GlobalVariables.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  facility.facilityName,
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: GlobalVariables.blackGrey,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
