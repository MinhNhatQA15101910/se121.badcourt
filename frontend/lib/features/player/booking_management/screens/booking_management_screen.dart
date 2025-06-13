import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/loader.dart';
import 'package:frontend/features/player/booking_management/services/booking_management_service.dart';
import 'package:frontend/features/player/booking_management/widgets/booking_detail_card.dart';
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

  List<Order>? _orders;
  List<Order>? _playedOrders;
  List<Order>? _notPlayedOrders;

  void _fetchAllOrders() async {
    _orders = await _bookingManagementService.fetchAllOrders(context: context);
    _playedOrders = _orders!.where((order) {
      DateTime now = DateTime.now();
      DateTime playTime = order.timePeriod.hourFrom;
      return now.isAfter(playTime);
    }).toList();
    _notPlayedOrders = _orders!.where((order) {
      DateTime now = DateTime.now();
      DateTime playTime = order.timePeriod.hourFrom;
      return now.isBefore(playTime);
    }).toList();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _fetchAllOrders();
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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: GlobalVariables.white),
            onPressed: () {
              _fetchAllOrders();
            },
          ),
        ],
      ),
      body: Container(
        color: GlobalVariables.defaultColor,
        child: Column(
          children: [
            _buildCustomTabSelector(),
            Expanded(
              child: _orders == null
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
        ? _orders!
        : viewIndex == 1
            ? _playedOrders!
            : _notPlayedOrders!;
            
    return displayOrders.isEmpty
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: displayOrders.length,
            itemBuilder: (context, index) {
              return BookingDetailCard(order: displayOrders[index]);
            },
          );
  }
}
