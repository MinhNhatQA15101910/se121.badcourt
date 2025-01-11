import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/message_button.dart';
import 'package:frontend/common/widgets/notification_button.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/account/screen/manager_account_screen.dart';
import 'package:frontend/features/manager/court_management/screen/court_management_screen.dart';
import 'package:frontend/features/manager/home/screens/home_screen.dart';
import 'package:frontend/features/post/screens/post_screen.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';

class ManagerBottomBar extends StatefulWidget {
  static const String routeName = '/manager/bottom-bar';
  const ManagerBottomBar({super.key});

  @override
  State<ManagerBottomBar> createState() => _ManagerBottomBarState();
}

class _ManagerBottomBarState extends State<ManagerBottomBar> {
  int _selectedIndex = 0;
  String userId = "";

  final List<Widget> _pages = [
    const HomeScreen(),
    const CourtManagementScreen(),
    const PostScreen(),
    const ManagerAccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    final id = userProvider.user.id;
    if (id.isNotEmpty) {
      setState(() {
        userId = id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: GlobalVariables.green,
          title: Row(
            children: [
              Text(
                'BAD',
                style: GoogleFonts.alfaSlabOne(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.none,
                  color: GlobalVariables.yellow,
                ),
              ),
              Expanded(
                child: Text(
                  'COURT',
                  style: GoogleFonts.alfaSlabOne(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none,
                    color: GlobalVariables.white,
                  ),
                ),
              ),
              NotificationButton(userId: userId),
              MessageButton(userId: userId),
            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex],
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
                icon: Icons.dashboard,
                text: 'Post',
              ),
              GButton(
                icon: Icons.account_circle,
                text: 'Account',
              )
            ],
          ),
        ),
      ),
    );
  }
}
