import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/facility_detail/screens/facility_detail_screen.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/providers/manager/current_facility_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SingleFacilityCard extends StatelessWidget {
  const SingleFacilityCard({
    super.key,
    required this.facility,
  });
  final Facility facility;

  // Function để format giá tiền
  String _formatPrice(int price) {
    if (price >= 1000000) {
      double millions = price / 1000000;
      if (millions == millions.toInt()) {
        return '${millions.toInt()}tr đ';
      } else {
        return '${millions.toStringAsFixed(1)}tr đ';
      }
    } else if (price >= 1000) {
      double thousands = price / 1000;
      if (thousands == thousands.toInt()) {
        return '${thousands.toInt()}k đ';
      } else {
        return '${thousands.toStringAsFixed(1)}k đ';
      }
    } else {
      return '${price}đ';
    }
  }

  @override
  Widget build(BuildContext context) {
    void _navigateToFacilityDetailScreen() {
      final facilityProvider = Provider.of<CurrentFacilityProvider>(
        context,
        listen: false,
      );
      facilityProvider.setFacility(facility);
      Navigator.of(context).pushNamed(
        FacilityDetailScreen.routeName,
      );
    }

    return GestureDetector(
      onTap: _navigateToFacilityDetailScreen,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with overlay
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: (facility.facilityImages.isNotEmpty &&
                              facility.facilityImages[0].url.isNotEmpty)
                          ? Image.network(
                              facility.facilityImages[0].url,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        GlobalVariables.green,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/badminton_court_default.png',
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Image.asset(
                              'assets/images/badminton_court_default.png',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  // Rating overlay
                  if (facility.ratingAvg > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: GlobalVariables.yellow,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              facility.ratingAvg.toStringAsFixed(1),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Courts amount badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: GlobalVariables.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${facility.courtsAmount} court${facility.courtsAmount > 1 ? 's' : ''} ',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Facility name
                    Text(
                      facility.facilityName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: GlobalVariables.blackGrey,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Location
                    if (facility.province.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: GlobalVariables.darkGrey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              facility.province,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: GlobalVariables.darkGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Price section - bên trái
                        if (facility.minPrice > 0)
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: GlobalVariables.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _formatPrice(facility.minPrice),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: GlobalVariables.green,
                                ),
                              ),
                            ),
                          ),
                        if (facility.ratingAvg > 0)
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: GlobalVariables.yellow,
                                    size: 16,
                                  ),
                                  Text(
                                    '${facility.ratingAvg.toStringAsFixed(1)} (${facility.totalRating})',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: GlobalVariables.darkGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    // Total rating count - dòng riêng bên dưới rating
                    if (facility.ratingAvg > 0 && facility.totalRating > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '(${facility.totalRating} đánh giá)',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: GlobalVariables.darkGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
