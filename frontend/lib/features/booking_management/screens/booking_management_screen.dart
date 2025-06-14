import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/loader.dart';
import 'package:frontend/features/booking_management/services/booking_management_service.dart';
import 'package:frontend/features/booking_management/widgets/booking_detail_card.dart';
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

  // Pagination variables
  int _currentPage = 1;
  final int _pageSize = 4;
  bool _isLoading = false;
  bool _hasMoreData = true;
  
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

  // Scroll listener to detect when user reaches the bottom
  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMoreData) {
      _loadMoreOrders();
    }
  }

  // Initial fetch of orders
  void _fetchOrders() async {
    setState(() {
      _isLoading = true;
    });

    List<Order> newOrders = await _bookingManagementService.fetchAllOrders(
      context: context,
      pageNumber: _currentPage,
      pageSize: _pageSize,
    );

    _processOrders(newOrders);

    setState(() {
      _isLoading = false;
      _hasMoreData = newOrders.length == _pageSize;
    });
  }

  // Load more orders when scrolling
  void _loadMoreOrders() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _currentPage++;
    });

    List<Order> newOrders = await _bookingManagementService.fetchAllOrders(
      context: context,
      pageNumber: _currentPage,
      pageSize: _pageSize,
    );

    _processOrders(newOrders);

    setState(() {
      _isLoading = false;
      _hasMoreData = newOrders.length == _pageSize;
    });
  }

  // Process and categorize orders
  void _processOrders(List<Order> newOrders) {
    if (newOrders.isEmpty) {
      setState(() {
        _hasMoreData = false;
      });
      return;
    }

    List<Order> playedOrders = [];
    List<Order> notPlayedOrders = [];

    for (var order in newOrders) {
      DateTime now = DateTime.now();
      DateTime playTime = order.timePeriod.hourFrom;
      if (now.isAfter(playTime)) {
        playedOrders.add(order);
      } else {
        notPlayedOrders.add(order);
      }
    }

    setState(() {
      _orders.addAll(newOrders);
      _playedOrders.addAll(playedOrders);
      _notPlayedOrders.addAll(notPlayedOrders);
      
    });
  }

  // Refresh all data
  void _refreshData() {
    setState(() {
      _orders = [];
      _playedOrders = [];
      _notPlayedOrders = [];
      _currentPage = 1;
      _hasMoreData = true;
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
            itemCount: displayOrders.length + (_hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == displayOrders.length) {
                return _buildLoadingIndicator();
              }
              return BookingDetailCard(order: displayOrders[index]);
            },
          );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(GlobalVariables.green),
      ),
    );
  }
}
