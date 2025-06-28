import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/loader.dart';
import 'package:frontend/features/order/services/order_service.dart';
import 'package:frontend/features/order/widgets/order_card_item.dart';
import 'package:frontend/models/order.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/constants/global_variables.dart';

class OrderScreen extends StatefulWidget {
  static const String routeName = '/booking-management';
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() =>
      _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _bookingManagementService = OrderService();

  // Updated view options to include all 4 states
  final List<String> _viewOptions = ['All', 'Not Play', 'Played', 'Cancelled'];
  final List<String?> _stateValues = [null, 'notPlay', 'played', 'cancelled']; // API state values
  int _selectedViewIndex = 0;

  List<Order> _orders = [];

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

  // Get current state filter
  String? get _currentStateFilter => _stateValues[_selectedViewIndex];

  // Updated scroll listener using dynamic pagination info
  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        !_isLoadingMore &&
        _hasNextPage) {
      _loadMoreOrders();
    }
  }

  // Updated initial fetch method with state filtering
  void _fetchOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> response = await _bookingManagementService.fetchAllOrdersPaginated(
        context: context,
        pageNumber: 1,
        pageSize: 10,
        state: _currentStateFilter, // Pass current state filter
      );

      final orders = response['orders'] as List<Order>;
      final pagination = response['pagination'] as Map<String, dynamic>;

      setState(() {
        _orders = orders; // No need for client-side filtering anymore
        _paginationInfo = pagination;
        _isLoading = false;
      });

      print('[BookingScreen] Initial fetch completed. State: $_currentStateFilter, Pagination: $pagination');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('[BookingScreen] Error fetching orders: $e');
    }
  }

  // Updated load more method with state filtering
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
        state: _currentStateFilter, // Pass current state filter
      );

      final orders = response['orders'] as List<Order>;
      final pagination = response['pagination'] as Map<String, dynamic>;

      setState(() {
        _orders.addAll(orders); // Simply append new orders
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

  // Updated refresh method
  void _refreshData() {
    setState(() {
      _orders = [];
      _paginationInfo = null;
    });
    _fetchOrders();
  }

  // Updated select view method to refetch data when tab changes
  void _selectView(int index) {
    if (_selectedViewIndex != index) {
      setState(() {
        _selectedViewIndex = index;
        _orders = []; // Clear current orders
        _paginationInfo = null; // Reset pagination
      });
      _fetchOrders(); // Fetch orders for new state
    }
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
                  : _buildBookingList(),
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
                  right: index < _viewOptions.length - 1 ? 6 : 0,
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
                      fontSize: 13, // Slightly smaller to fit 4 tabs
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

  Widget _buildBookingList() {
    return _orders.isEmpty && !_isLoading
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
                const SizedBox(height: 8),
                Text(
                  _getEmptyStateMessage(),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: GlobalVariables.darkGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _orders.length + (_shouldShowLoadingIndicator() ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _orders.length) {
                return _buildLoadingIndicator();
              }
              return BookingCardItem(order: _orders[index]);
            },
          );
  }

  // Get appropriate empty state message based on selected tab
  String _getEmptyStateMessage() {
    switch (_selectedViewIndex) {
      case 0:
        return 'You haven\'t made any bookings yet';
      case 1:
        return 'No upcoming bookings';
      case 2:
        return 'No completed bookings';
      case 3:
        return 'No cancelled bookings';
      default:
        return 'No bookings found';
    }
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
