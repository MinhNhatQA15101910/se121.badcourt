import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/player/home/screens/home_screen.dart';
import 'package:frontend/features/player/search/screens/search_screen.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class PlayerBottomBar extends StatefulWidget {
  static const String routeName = '/player-bottom-bar';
  const PlayerBottomBar({super.key});

  @override
  State<PlayerBottomBar> createState() => _PlayerBottomBarState();
}

class _PlayerBottomBarState extends State<PlayerBottomBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const SearchScreen(),
    const Center(
      child: Text(
        'Favorite Screen',
      ),
    ),
    const Center(
      child: Text(
        'Profile Screen',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        color: GlobalVariables.green,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          child: GNav(
            gap: 6,
            backgroundColor: GlobalVariables.green,
            color: Colors.white,
            activeColor: GlobalVariables.green,
            tabBackgroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
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
                icon: Icons.favorite_border,
                text: 'Favorite',
              ),
              GButton(
                icon: Icons.account_circle,
                text: 'Profile',
              )
            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
