import 'package:flutter/material.dart';
import 'package:frontend/features/manager/booking_management_manager/widgets/booking_detail_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/constants/global_variables.dart';

class BookingManagementManagerScreen extends StatefulWidget {
  const BookingManagementManagerScreen({super.key});

  @override
  State<BookingManagementManagerScreen> createState() =>
      _BookingManagementManagerScreenState();
}

class _BookingManagementManagerScreenState
    extends State<BookingManagementManagerScreen> {
  final List<String> tabbarList = [
    'All',
    'Played',
    'Not played',
    'Cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabbarList.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: GlobalVariables.green,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'BOOKINGS',
                  style: GoogleFonts.alfaSlabOne(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none,
                    color: GlobalVariables.white,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => {},
                iconSize: 24,
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: GlobalVariables.white,
                ),
              ),
              IconButton(
                onPressed: () => {},
                iconSize: 24,
                icon: const Icon(
                  Icons.message_outlined,
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
                            BookingDetailCardManager(),
                            BookingDetailCardManager(),
                            BookingDetailCardManager(),
                            BookingDetailCardManager(),
                            BookingDetailCardManager(),
                          ],
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
