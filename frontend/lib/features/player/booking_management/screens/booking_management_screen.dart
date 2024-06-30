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

  final List<String> _tabbarList = ['All', 'Played', 'Not played'];

  List<Order>? _orders;
  List<Order>? _playedOrders;
  List<Order>? _notPlayedOrders;

  int _ordersCount = 0;
  int _playedOrdersCount = 0;
  int _notPlayedOrdersCount = 0;

  void _fetchAllOrders() async {
    _orders = await _bookingManagementService.fetchAllOrders(context: context);
    _playedOrders = _orders!.where((order) {
      DateTime now = DateTime.now();
      DateTime playTime = order.period.hourFrom;
      return now.isAfter(playTime);
    }).toList();
    _notPlayedOrders = _orders!.where((order) {
      DateTime now = DateTime.now();
      DateTime playTime = order.period.hourFrom;
      return now.isBefore(playTime);
    }).toList();
    _ordersCount = _orders!.length;
    _playedOrdersCount = _playedOrders!.length;
    _notPlayedOrdersCount = _ordersCount - _playedOrdersCount;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _fetchAllOrders();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabbarList.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: GlobalVariables.green,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Booking management',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.none,
                  color: GlobalVariables.white,
                ),
              ),
            ],
          ),
        ),
        body: Container(
          color: GlobalVariables.defaultColor,
          child: Column(
            children: [
              _buildTabbar(_tabbarList),
              Expanded(
                child: TabBarView(
                  children: [
                    for (int i = 0; i < _tabbarList.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        child: _orders == null
                            ? const Loader()
                            : ListView.builder(
                                itemCount: _orders == null
                                    ? 0
                                    : i == 0
                                        ? _orders!.length
                                        : i == 1
                                            ? _playedOrdersCount
                                            : _notPlayedOrdersCount,
                                itemBuilder: (
                                  BuildContext _,
                                  int index,
                                ) {
                                  return BookingDetailCard(
                                    order: i == 0
                                        ? _orders![index]
                                        : i == 1
                                            ? _playedOrders![index]
                                            : _notPlayedOrders![index],
                                  );
                                },
                              ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                height: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabbar(List<String> tabbarList) {
    return TabBar(
      isScrollable: true,
      unselectedLabelColor: GlobalVariables.darkGrey,
      labelColor: GlobalVariables.green,
      indicatorColor: GlobalVariables.green,
      tabs: [
        for (final tab in tabbarList)
          Tab(
            child: Text(tab),
          ),
      ],
    );
  }
}
