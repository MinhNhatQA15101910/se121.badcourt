import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/facility_detail/services/facility_detail_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class FacilityRatingsScreen extends StatefulWidget {
  static const String routeName = '/facility-ratings-screen';
  const FacilityRatingsScreen({Key? key}) : super(key: key);

  @override
  State<FacilityRatingsScreen> createState() => _FacilityRatingsScreenState();
}

class _FacilityRatingsScreenState extends State<FacilityRatingsScreen> {
  final FacilityDetailService _facilityDetailService = FacilityDetailService();
  
  List<dynamic> _ratings = [];
  Map<String, dynamic>? _paginationInfo;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _facilityId;
  String? _facilityName;
  
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_facilityId == null) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
      _facilityId = args['facilityId']!;
      _facilityName = args['facilityName'] ?? 'Facility';
      _fetchRatings();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // Helper methods for pagination
  bool get _hasNextPage {
    if (_paginationInfo == null) return false;
    final currentPage = _paginationInfo!['currentPage'] as int;
    final totalPages = _paginationInfo!['totalPages'] as int;
    return currentPage < totalPages;
  }

  int get _nextPage {
    if (_paginationInfo == null) return 1;
    final currentPage = _paginationInfo!['currentPage'] as int;
    return _hasNextPage ? currentPage + 1 : currentPage;
  }

  int get _itemsPerPage {
    if (_paginationInfo == null) return 8;
    return _paginationInfo!['itemsPerPage'] as int;
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        !_isLoadingMore &&
        _hasNextPage) {
      _loadMoreRatings();
    }
  }

  Future<void> _fetchRatings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> response = await _facilityDetailService.getFacilityRatingsPaginated(
        context: context,
        facilityId: _facilityId!,
        pageNumber: 1,
        pageSize: 8,
      );

      final ratings = response['ratings'] as List<dynamic>;
      final pagination = response['pagination'] as Map<String, dynamic>;

      setState(() {
        _ratings = ratings;
        _paginationInfo = pagination;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreRatings() async {
    if (!_hasNextPage) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      Map<String, dynamic> response = await _facilityDetailService.getFacilityRatingsPaginated(
        context: context,
        facilityId: _facilityId!,
        pageNumber: _nextPage,
        pageSize: _itemsPerPage,
      );

      final ratings = response['ratings'] as List<dynamic>;
      final pagination = response['pagination'] as Map<String, dynamic>;

      setState(() {
        _ratings.addAll(ratings);
        _paginationInfo = pagination;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalVariables.defaultColor,
      appBar: AppBar(
        backgroundColor: GlobalVariables.green,
        title: Text(
          'Reviews - $_facilityName',
          style: GoogleFonts.inter(
            fontSize: 18,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ratings.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    // Rating summary
                    if (_paginationInfo != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.white,
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${_paginationInfo!['totalItems']} reviews',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: GlobalVariables.blackGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Ratings list
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _ratings.length + (_hasNextPage ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _ratings.length) {
                            return _buildLoadingIndicator();
                          }
                          return _buildRatingItem(_ratings[index]);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_border,
            size: 64,
            color: GlobalVariables.darkGrey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No reviews yet',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: GlobalVariables.darkGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to leave a review!',
            style: GoogleFonts.inter(
              fontSize: 14,
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              // User avatar placeholder
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: GlobalVariables.green.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.person,
                  color: GlobalVariables.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User ${userId.substring(0, 8)}...',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: GlobalVariables.blackGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Star rating
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < stars ? Icons.star : Icons.star_border,
                              size: 16,
                              color: index < stars ? Colors.amber : GlobalVariables.lightGrey,
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd MMM yyyy').format(createdAt),
                          style: GoogleFonts.inter(
                            fontSize: 12,
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
            const SizedBox(height: 12),
            Text(
              feedback,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: GlobalVariables.blackGrey,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: _isLoadingMore
          ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(GlobalVariables.green),
            )
          : const SizedBox.shrink(),
    );
  }
}
