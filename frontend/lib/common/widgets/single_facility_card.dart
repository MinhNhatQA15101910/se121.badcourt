import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/player/facility_detail/screens/facility_detail_screen.dart';
import 'package:frontend/models/facility.dart';
import 'package:google_fonts/google_fonts.dart';

class SingleFacilityCard extends StatelessWidget {
  const SingleFacilityCard({
    super.key,
    required this.facility,
  });
  final Facility facility;

  @override
  Widget build(BuildContext context) {
    void _navigateToFacilityDetailScreen() {
      Navigator.of(context).pushNamed(
        FacilityDetailScreen.routeName,
        arguments: facility,
      );
    }

    return GestureDetector(
      onTap: _navigateToFacilityDetailScreen,
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: facility.imageUrls.isNotEmpty &&
                        facility.imageUrls[0] != null
                    ? Image.network(
                        facility.imageUrls[0],
                        fit: BoxFit.fill,
                      )
                    : Image.asset(
                        'assets/images/badminton_court_default.png',
                        fit: BoxFit.fill,
                      ),
              ),
            ),
            const SizedBox(height: 4),
            _buildText(facility.name),
            const SizedBox(height: 4),
            Row(
              children: [
                RatingBar.builder(
                  initialRating: facility.ratingAvg,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  ignoreGestures: true,
                  itemCount: 5,
                  itemSize: 16,
                  unratedColor: GlobalVariables.lightYellow,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: GlobalVariables.yellow,
                  ),
                  onRatingUpdate: (rating) {
                    print(rating);
                  },
                ),
                SizedBox(
                  width: 4,
                ),
                _RatingNumberText('(${facility.totalRating})'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _priceText('120000 đ'),
                SizedBox(
                  width: 4,
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  decoration: BoxDecoration(
                    color: GlobalVariables.red,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: _discountText('-10%'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildText(String text) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        fontSize: 14,
        color: GlobalVariables.blackGrey,
      ),
    );
  }

  Widget _priceText(String text) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: GlobalVariables.blackGrey,
      ),
    );
  }

  Widget _RatingNumberText(String text) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: GlobalVariables.darkGrey,
      ),
    );
  }

  Widget _discountText(String text) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: GlobalVariables.white,
      ),
    );
  }
}
