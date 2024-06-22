import 'package:flutter/material.dart';
import 'package:frontend/features/player/booking_management/widgets/booking_detail_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/constants/global_variables.dart';

class BookingManagementScreen extends StatefulWidget {
  static const String routeName = '/bookingManagement';
  const BookingManagementScreen({super.key});

  @override
  State<BookingManagementScreen> createState() =>
      _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> {
  final List<String> tabbarList = [
    'All',
    'Pending',
    'In Delivery',
    'Delivered',
    'Cancelled'
  ];

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
                'Datetime management',
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
                        child: ListView(
                          children: [
                            BookingDetailCard(),
                            BookingDetailCard(),
                            BookingDetailCard(),
                            BookingDetailCard(),
                            BookingDetailCard(),
                          ],
                        ),
                      ),
                  ],
                ),
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
