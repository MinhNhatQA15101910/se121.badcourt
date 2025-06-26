import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/player/rating/services/rating_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class RatingDetailScreen extends StatefulWidget {
  static const String routeName = '/rating-detail-screen';
  const RatingDetailScreen({Key? key}) : super(key: key);

  @override
  State<RatingDetailScreen> createState() => _RatingDetailScreenState();
}

class _RatingDetailScreenState extends State<RatingDetailScreen> {
  final RatingService _ratingService = RatingService();
  
  Map<String, dynamic>? _ratingData;
  bool _isLoading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String ratingId = ModalRoute.of(context)!.settings.arguments as String;
    _fetchRatingDetails(ratingId);
  }

  Future<void> _fetchRatingDetails(String ratingId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ratingData = await _ratingService.getRatingById(
        context: context,
        ratingId: ratingId,
      );

      setState(() {
        _ratingData = ratingData;
        _isLoading = false;
        if (ratingData == null) {
          _error = 'Failed to load rating details';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'An error occurred while loading rating details';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: GlobalVariables.defaultColor,
        appBar: AppBar(
          backgroundColor: GlobalVariables.green,
          title: Text(
            'Rating Details',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _ratingData == null) {
      return Scaffold(
        backgroundColor: GlobalVariables.defaultColor,
        appBar: AppBar(
          backgroundColor: GlobalVariables.green,
          title: Text(
            'Rating Details',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: GlobalVariables.darkGrey,
              ),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Rating not found',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: GlobalVariables.darkGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final stars = _ratingData!['stars'] as int;
    final feedback = _ratingData!['feedback'] as String? ?? '';
    final createdAt = DateTime.parse(_ratingData!['createdAt']);

    return Scaffold(
      backgroundColor: GlobalVariables.defaultColor,
      appBar: AppBar(
        backgroundColor: GlobalVariables.green,
        title: Text(
          'Your Rating',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Your Experience Rating',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: GlobalVariables.blackGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Star Display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          index < stars ? Icons.star : Icons.star_border,
                          size: 40,
                          color: index < stars 
                              ? Colors.amber 
                              : GlobalVariables.lightGrey,
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 16),

                  // Rating text
                  Text(
                    _getRatingText(stars),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: GlobalVariables.green,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Date
                  Text(
                    'Rated on ${DateFormat('dd MMM yyyy, HH:mm').format(createdAt)}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: GlobalVariables.darkGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Feedback Section
            if (feedback.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Feedback',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: GlobalVariables.blackGrey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: GlobalVariables.green.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: GlobalVariables.green.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        feedback,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: GlobalVariables.blackGrey,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getRatingText(int stars) {
    switch (stars) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}
