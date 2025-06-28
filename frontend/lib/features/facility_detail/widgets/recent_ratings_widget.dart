import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/facility_detail/screens/facility_ratings_screen.dart';
import 'package:frontend/features/facility_detail/services/facility_detail_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class RecentRatingsWidget extends StatefulWidget {
  final String facilityId;
  final String facilityName;

  const RecentRatingsWidget({
    Key? key,
    required this.facilityId,
    required this.facilityName,
  }) : super(key: key);

  @override
  State<RecentRatingsWidget> createState() => _RecentRatingsWidgetState();
}

class _RecentRatingsWidgetState extends State<RecentRatingsWidget> {
  final FacilityDetailService _facilityDetailService = FacilityDetailService();
  List<dynamic> _recentRatings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecentRatings();
  }

  Future<void> _fetchRecentRatings() async {
    try {
      final ratings = await _facilityDetailService.getRecentFacilityRatings(
        context: context,
        facilityId: widget.facilityId,
        limit: 3,
      );

      setState(() {
        _recentRatings = ratings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToAllRatings() {
    Navigator.of(context).pushNamed(
      FacilityRatingsScreen.routeName,
      arguments: {
        'facilityId': widget.facilityId,
        'facilityName': widget.facilityName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Reviews',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: GlobalVariables.blackGrey,
                ),
              ),
              if (_recentRatings.isNotEmpty)
                GestureDetector(
                  onTap: _navigateToAllRatings,
                  child: Text(
                    'See more',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: GlobalVariables.green,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_recentRatings.isEmpty)
            _buildEmptyState()
          else
            Column(
              children: _recentRatings.map((rating) => _buildRatingItem(rating)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.star_border,
            size: 48,
            color: GlobalVariables.darkGrey.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No reviews yet',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: GlobalVariables.darkGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingItem(Map<String, dynamic> rating) {
    final stars = rating['stars'] as int;
    final feedback = rating['feedback'] as String? ?? '';
    final createdAt = DateTime.parse(rating['createdAt']);
    final userId = rating['userId'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: GlobalVariables.lightGrey,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // User avatar placeholder
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: GlobalVariables.green.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.person,
                  color: GlobalVariables.green,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User ${userId.substring(0, 8)}...',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: GlobalVariables.blackGrey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        // Star rating
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < stars ? Icons.star : Icons.star_border,
                              size: 12,
                              color: index < stars ? Colors.amber : GlobalVariables.lightGrey,
                            );
                          }),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('dd MMM yyyy').format(createdAt),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: GlobalVariables.darkGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (feedback.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              feedback,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: GlobalVariables.blackGrey,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
