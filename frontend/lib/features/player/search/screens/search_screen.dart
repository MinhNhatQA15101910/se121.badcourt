import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/loader.dart';
import 'package:frontend/common/widgets/single_facility_card.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/player/search/screens/search_by_location_screen.dart';
import 'package:frontend/features/player/search/services/search_service.dart';
import 'package:frontend/features/player/search/widgets/filter_btm_sheet.dart';
import 'package:frontend/features/player/search/widgets/sort_btm_sheet.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/providers/filter_provider.dart';
import 'package:frontend/providers/sort_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchService = SearchService();

  late FilterProvider _filterProvider;
  late SortProvider _sortProvider;

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounceTimer;

  List<Facility> _facilities = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;

  void _navigateToSearchByLocationScreen() {
    Navigator.of(context).pushNamed(SearchByLocationScreen.routeName);
  }

  void _fetchAllFacilities({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
        _hasMore = true;
        _facilities.clear();
      });
    }

    final result = await _searchService.fetchAllFacilities(
      context: context,
      sort: Sort.location_asc,
      page: _currentPage,
      limit: 10,
    );

    if (mounted) {
      setState(() {
        if (isRefresh) {
          _facilities = result['facilities'] as List<Facility>;
        } else {
          _facilities.addAll(result['facilities'] as List<Facility>);
        }
        _currentPage = result['currentPage'] as int;
        _totalPages = result['totalPages'] as int;
        _hasMore = _currentPage < _totalPages;
        _isLoading = false;
      });
    }
  }

  void _refreshFacilities({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
        _hasMore = true;
        _facilities.clear();
      });
    }

    final result = await _searchService.fetchAllFacilities(
      context: context,
      province: _filterProvider.province,
      minPrice: _filterProvider.minPrice,
      maxPrice: _filterProvider.maxPrice,
      search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      sort: _sortProvider.sort,
      page: _currentPage,
      limit: 10,
    );

    if (mounted) {
      setState(() {
        if (isRefresh) {
          _facilities = result['facilities'] as List<Facility>;
        } else {
          _facilities.addAll(result['facilities'] as List<Facility>);
        }
        _currentPage = result['currentPage'] as int;
        _totalPages = result['totalPages'] as int;
        _hasMore = _currentPage < _totalPages;
        _isLoading = false;
      });
    }
  }

  void _loadMoreFacilities() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    final result = await _searchService.fetchAllFacilities(
      context: context,
      province: _filterProvider.province,
      minPrice: _filterProvider.minPrice,
      maxPrice: _filterProvider.maxPrice,
      search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      sort: _sortProvider.sort,
      page: _currentPage,
      limit: 10,
    );

    if (mounted) {
      setState(() {
        _facilities.addAll(result['facilities'] as List<Facility>);
        _currentPage = result['currentPage'] as int;
        _totalPages = result['totalPages'] as int;
        _hasMore = _currentPage < _totalPages;
        _isLoadingMore = false;
      });
    }
  }

  void _onSearchChanged() {
    // Cancel the previous timer
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    // Start a new timer
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _refreshFacilities(isRefresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreFacilities();
    }
  }

  @override
  void initState() {
    super.initState();

    _filterProvider = Provider.of<FilterProvider>(
      context,
      listen: false,
    );
    _sortProvider = Provider.of<SortProvider>(
      context,
      listen: false,
    );

    // Add listeners
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);

    _fetchAllFacilities(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshFacilities(isRefresh: true);
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Container(
            child: Column(
              children: [
                Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 12,
                          left: 16,
                          right: 16,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Find badminton facilities',
                                  hintStyle: GoogleFonts.inter(
                                    color: GlobalVariables.darkGrey,
                                    fontSize: 16,
                                  ),
                                  contentPadding: const EdgeInsets.all(8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: GlobalVariables.lightGreen,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: GlobalVariables.lightGreen,
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: GlobalVariables.darkGrey,
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.clear,
                                            color: GlobalVariables.darkGrey,
                                          ),
                                          onPressed: () {
                                            _searchController.clear();
                                          },
                                        )
                                      : null,
                                ),
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                ),
                                validator: (facilityName) {
                                  if (facilityName == null ||
                                      facilityName.isEmpty) {
                                    return 'Please enter your facility name.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            GestureDetector(
                              onTap: _navigateToSearchByLocationScreen,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: GlobalVariables.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.location_on_outlined,
                                    size: 32,
                                    color: GlobalVariables.green,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                          top: 12,
                          left: 16,
                          right: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => {
                                showModalBottomSheet<dynamic>(
                                  context: context,
                                  useRootNavigator: true,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (BuildContext context) {
                                    return FilterBtmSheet(
                                      filterProvider: _filterProvider,
                                      onDoneFilter: () => _refreshFacilities(isRefresh: true),
                                    );
                                  },
                                ),
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: GlobalVariables.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.filter_alt_outlined,
                                      size: 24,
                                      color: GlobalVariables.darkGrey,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    _interRegular14(
                                      'Filter',
                                      GlobalVariables.blackGrey,
                                      1,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => {
                                showModalBottomSheet<dynamic>(
                                  context: context,
                                  useRootNavigator: true,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (BuildContext context) {
                                    return SortBtmSheet(
                                      sortProvider: _sortProvider,
                                      onDoneSort: () => _refreshFacilities(isRefresh: true),
                                    );
                                  },
                                ),
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: GlobalVariables.green,
                                  ),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Row(
                                  children: [
                                    Transform.rotate(
                                      angle: 90 * 3.1415926535897932 / 180,
                                      child: Icon(
                                        Icons.sync_alt_outlined,
                                        size: 20,
                                        color: GlobalVariables.green,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    _interRegular14(
                                      _sortProvider.sort.value,
                                      GlobalVariables.green,
                                      1,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      )
                    ],
                  ),
                ),
                Container(
                  height: 12,
                  color: GlobalVariables.defaultColor,
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: _isLoading
                      ? const Loader()
                      : _facilities.isEmpty
                          ? _buildNoFacilitiesFound()
                          : Column(
                              children: [
                                GridView.builder(
                                  itemCount: _facilities.length,
                                  shrinkWrap: true,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 3 / 5,
                                  ),
                                  itemBuilder: (context, index) {
                                    return SingleFacilityCard(
                                      facility: _facilities[index],
                                    );
                                  },
                                  physics: const NeverScrollableScrollPhysics(),
                                ),
                                if (_isLoadingMore)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              GlobalVariables.green,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Loading more...',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: GlobalVariables.darkGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (!_hasMore && _facilities.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      'No more facilities to load',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: GlobalVariables.darkGrey,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoFacilitiesFound() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Facilities Found',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We couldn\'t find any badminton facilities matching your search criteria. Try adjusting your filters or search terms.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Reset filters and search
                _filterProvider.resetFilter();
                _sortProvider.resetSort();
                _searchController.clear();
                _fetchAllFacilities(isRefresh: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GlobalVariables.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 20),
              label: Text(
                'Reset Search',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    _filterProvider.resetFilter();
    _sortProvider.resetSort();
    _searchController.dispose();
    super.dispose();
  }

  Widget _interRegular14(
    String text,
    Color color,
    int maxLines,
  ) {
    return Container(
      child: Text(
        text,
        textAlign: TextAlign.start,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}