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

  final List<String> tabbarList = ['All', 'Played', 'Not played'];

  List<Order>? orders;

  void _fetchAllOrders() async {
    orders = await _bookingManagementService.fetchAllOrders(context: context);
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
      length: tabbarList.length,
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
              _buildTabbar(tabbarList),
              Expanded(
                child: TabBarView(
                  children: [
                    for (int i = 0; i < tabbarList.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        child: orders == null
                            ? const Loader()
                            : ListView.builder(
                                itemCount: orders?.length ?? 0,
                                itemBuilder: (
                                  BuildContext _,
                                  int index,
                                ) =>
                                    BookingDetailCard(
                                  order: orders![index],
                                ),
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
