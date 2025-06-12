import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/message_button.dart';
import 'package:frontend/common/widgets/notification_button.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/constants/utils.dart';
import 'package:frontend/features/player/account/screens/account_screen.dart';
import 'package:frontend/features/player/home/screens/home_screen.dart';
import 'package:frontend/features/player/search/screens/search_screen.dart';
import 'package:frontend/features/post/screens/post_screen.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';

class PlayerBottomBar extends StatefulWidget {
  static const String routeName = '/player-bottom-bar';
  const PlayerBottomBar({super.key});

  @override
  State<PlayerBottomBar> createState() => _PlayerBottomBarState();
}

class _PlayerBottomBarState extends State<PlayerBottomBar> {
  int _selectedIndex = 0;
  String userId = "";

  final List<Widget> _pages = [
    const HomeScreen(),
    const SearchScreen(),
    const PostScreen(),
    const AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    getCurrentLocation(context);
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
  void dispose() {
    super.dispose();
  }

  // Callback function để reset index
  void _resetIndex() {
    setState(() {
      _selectedIndex = 0; // Chuyển về tab đầu tiên (Home)
    });
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
              NotificationButton(
                userId: userId,
                onNotificationButtonPressed: _resetIndex,
              ),
              // Sử dụng MessageButton mới không cần truyền unreadMessages
              MessageButton(
                userId: userId,
                onMessageButtonPressed: _resetIndex,
              ),
            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        color: GlobalVariables.green,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: GNav(
            gap: 6,
            backgroundColor: GlobalVariables.green,
            color: Colors.white,
            activeColor: GlobalVariables.green,
            tabBackgroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
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
                icon: Icons.search,
                text: 'Search',
              ),
              GButton(
                icon: Icons.dashboard,
                text: 'Post',
              ),
              GButton(
                icon: Icons.account_circle,
                text: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
