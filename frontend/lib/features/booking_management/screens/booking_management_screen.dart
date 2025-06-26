import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/loader.dart';
import 'package:frontend/features/booking_management/services/booking_management_service.dart';
import 'package:frontend/features/booking_management/widgets/booking_card_item.dart';
import 'package:frontend/models/order.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/constants/global_variables.dart';

class BookingManagementScreen extends StatefulWidget {
  static const String routeName = '/booking-management';
  const BookingManagementScreen({super.key});

  @override
  State<BookingManagementScreen> createState() =>
      _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> {
  final _bookingManagementService = BookingManagementService();

  final List<String> _viewOptions = ['All', 'Played', 'Pending'];
  int _selectedViewIndex = 0;

  List<Order> _orders = [];
  List<Order> _playedOrders = [];
  List<Order> _notPlayedOrders = [];

  // Pagination variables using dynamic
  Map<String, dynamic>? _paginationInfo;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  
  // Scroll controller for infinite scrolling
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    
    // Initialize the scroll controller
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    
    // Check if there are arguments passed to determine the initial tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is int) {
        setState(() {
          _selectedViewIndex = args;
        });
      }
      _fetchOrders();
    });
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
    if (_paginationInfo == null) return 10;
    return _paginationInfo!['itemsPerPage'] as int;
  }

  // Updated scroll listener using dynamic pagination info
  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        !_isLoadingMore &&
        _hasNextPage) {
      _loadMoreOrders();
    }
  }

  // Updated initial fetch method
  void _fetchOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> response = await _bookingManagementService.fetchAllOrdersPaginated(
        context: context,
        pageNumber: 1,
        pageSize: 10,
      );

      final orders = response['orders'] as List<Order>;
      final pagination = response['pagination'] as Map<String, dynamic>;

      _processOrders(orders, isRefresh: true);

      setState(() {
        _paginationInfo = pagination;
        _isLoading = false;
      });

      print('[BookingScreen] Initial fetch completed. Pagination: $pagination');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('[BookingScreen] Error fetching orders: $e');
    }
  }

  // Updated load more method
  void _loadMoreOrders() async {
    if (!_hasNextPage) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      Map<String, dynamic> response = await _bookingManagementService.fetchAllOrdersPaginated(
        context: context,
        pageNumber: _nextPage,
        pageSize: _itemsPerPage,
      );

      final orders = response['orders'] as List<Order>;
      final pagination = response['pagination'] as Map<String, dynamic>;

      _processOrders(orders, isRefresh: false);

      setState(() {
        _paginationInfo = pagination;
        _isLoadingMore = false;
      });

      print('[BookingScreen] Load more completed. Current page: ${pagination['currentPage']}/${pagination['totalPages']}');
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      print('[BookingScreen] Error loading more orders: $e');
    }
  }

  // Updated process orders method
  void _processOrders(List<Order> newOrders, {required bool isRefresh}) {
    if (newOrders.isEmpty && !isRefresh) {
      return;
    }

    List<Order> playedOrders = [];
    List<Order> notPlayedOrders = [];

    for (var order in newOrders) {
      // Use the state from the order instead of time comparison
      if (order.state == 'Played') {
        playedOrders.add(order);
      } else {
        notPlayedOrders.add(order);
      }
    }

    setState(() {
      if (isRefresh) {
        // Replace all data on refresh
        _orders = newOrders;
        _playedOrders = playedOrders;
        _notPlayedOrders = notPlayedOrders;
      } else {
        // Append data on load more
        _orders.addAll(newOrders);
        _playedOrders.addAll(playedOrders);
        _notPlayedOrders.addAll(notPlayedOrders);
      }
    });
  }

  // Updated refresh method
  void _refreshData() {
    setState(() {
      _orders = [];
      _playedOrders = [];
      _notPlayedOrders = [];
      _paginationInfo = null;
    });
    _fetchOrders();
  }

  void _selectView(int index) {
    setState(() {
      _selectedViewIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: GlobalVariables.green,
        title: Text(
          'My Bookings',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: GlobalVariables.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: GlobalVariables.white),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Container(
        color: GlobalVariables.defaultColor,
        child: Column(
          children: [
            _buildCustomTabSelector(),
            // Add pagination info display (optional, for debugging)
            if (_paginationInfo != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Page ${_paginationInfo!['currentPage']} of ${_paginationInfo!['totalPages']} (${_paginationInfo!['totalItems']} total)',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: GlobalVariables.darkGrey,
                  ),
                ),
              ),
            Expanded(
              child: _orders.isEmpty && _isLoading
                  ? const Center(child: Loader())
                  : _buildBookingList(_selectedViewIndex),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTabSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(
          _viewOptions.length,
          (index) => Expanded(
            child: GestureDetector(
              onTap: () => _selectView(index),
              child: Container(
                height: 36,
                margin: EdgeInsets.only(
                  right: index < _viewOptions.length - 1 ? 8 : 0,
                ),
                decoration: BoxDecoration(
                  color: _selectedViewIndex == index
                      ? GlobalVariables.green
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _selectedViewIndex == index
                        ? GlobalVariables.green
                        : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    _viewOptions[index],
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _selectedViewIndex == index
                          ? Colors.white
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingList(int viewIndex) {
    final List<Order> displayOrders = viewIndex == 0
        ? _orders
        : viewIndex == 1
            ? _playedOrders
            : _notPlayedOrders;
            
    return displayOrders.isEmpty && !_isLoading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 64,
                  color: GlobalVariables.darkGrey.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No bookings found',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: GlobalVariables.darkGrey,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: displayOrders.length + (_shouldShowLoadingIndicator() ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == displayOrders.length) {
                return _buildLoadingIndicator();
              }
              return BookingCardItem(order: displayOrders[index]);
            },
          );
  }

  // Updated method to determine when to show loading indicator
  bool _shouldShowLoadingIndicator() {
    return _isLoadingMore || (_hasNextPage && !_isLoading);
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
