import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/booking_management/screens/booking_management_screen.dart';
import 'package:frontend/features/facility_detail/screens/facility_detail_screen.dart';
import 'package:frontend/features/manager/datetime_management/screens/datetime_management_screen.dart';
import 'package:frontend/features/manager/home/widgets/facility_home.dart';
import 'package:frontend/features/manager/home/widgets/item_tag.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _navigateToDatetimeManagementScreen() {
    Navigator.of(context).pushNamed(DatetimeManagementScreen.routeName);
  }

  void _navigateToBookingManagementScreen() {
    Navigator.of(context).pushNamed(BookingManagementScreen.routeName);
  }

  void _navigateToFacilityDetailScreen() {
    Navigator.of(context).pushNamed(
      FacilityDetailScreen.routeName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: GlobalVariables.defaultColor,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 1,
                color: GlobalVariables.white,
              ),
              FacilityHome(),
              ItemTag(
                title: 'Booking management',
                description:
                    'View the history of player bookings for your facility',
                imgPath: 'assets/images/img_datetime.png',
                onTap: _navigateToBookingManagementScreen,
                isVisibleArrow: true,
              ),
              ItemTag(
                title: 'View detail information',
                description: 'View your badminton facility detail information',
                imgPath: 'assets/images/img_court.png',
                onTap: _navigateToFacilityDetailScreen,
                isVisibleArrow: true,
              ),
              ItemTag(
                title: 'Datetime management',
                description:
                    'Update the information of your badminton facility',
                imgPath: 'assets/images/img_recent.png',
                onTap: _navigateToDatetimeManagementScreen,
                isVisibleArrow: true,
              ),
              ItemTag(
                title: 'Statistic',
                description:
                    'Statistics on your badminton facility business activities',
                imgPath: 'assets/images/img_statistic.png',
                onTap: () {},
                isVisibleArrow: true,
              ),
              ItemTag(
                title: 'Support',
                description: 'Message admin for support',
                imgPath: 'assets/images/img_support.png',
                onTap: () {},
                isVisibleArrow: true,
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
}
