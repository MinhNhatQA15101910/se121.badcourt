import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/add_facility/screens/contracts_screen.dart';
import 'package:frontend/features/manager/court_management/screen/court_management_screen.dart';
import 'package:frontend/features/manager/home/screens/home_screen.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class ManagerBottomBar extends StatefulWidget {
  static const String routeName = '/customer-bottom-bar';
  const ManagerBottomBar({super.key});

  @override
  State<ManagerBottomBar> createState() => _ManagerBottomBarState();
}

class _ManagerBottomBarState extends State<ManagerBottomBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const CourtManagementScreen(),
    const ContractScreen(),
    const ContractScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        color: GlobalVariables.green,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: GNav(
            gap: 6,
            backgroundColor: GlobalVariables.green,
            color: Colors.white,
            activeColor: GlobalVariables.green,
            tabBackgroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: Icons.vertical_split_outlined,
                text: 'Courts',
              ),
              GButton(
                icon: Icons.calendar_month,
                text: 'Booking',
              ),
              GButton(
                icon: Icons.account_circle,
                text: 'Account',
              )
            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
