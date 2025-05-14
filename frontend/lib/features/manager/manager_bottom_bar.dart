import 'package:flutter/material.dart';
import 'package:frontend/common/services/socket_service.dart';
import 'package:frontend/common/widgets/message_button.dart';
import 'package:frontend/common/widgets/notification_button.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/account/screen/manager_account_screen.dart';
import 'package:frontend/features/manager/court_management/screen/court_management_screen.dart';
import 'package:frontend/features/manager/home/screens/home_screen.dart';
import 'package:frontend/features/manager/intro_manager/services/intro_manager_service.dart';
import 'package:frontend/features/post/screens/post_screen.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/providers/manager/current_facility_provider.dart';
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
  int _unreadMessages = 0; // Lưu số tin nhắn chưa đọc
  final SocketService _socketService = SocketService();
  final List<Widget> _pages = [
    const HomeScreen(),
    const CourtManagementScreen(),
    const PostScreen(),
    const ManagerAccountScreen(),
  ];

  Future<void> onPageChanged(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    final currentFacilityProvider = Provider.of<CurrentFacilityProvider>(
      context,
      listen: false,
    );
    Facility facility = currentFacilityProvider.currentFacility;
    IntroManagerService introManagerService = new IntroManagerService();
    facility = (await introManagerService.fetchFacilityById(
        context: context, facilityId: facility.id))!;
    currentFacilityProvider.setFacility(facility);
  }

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    final id = userProvider.user.id;
    if (id.isNotEmpty) {
      _socketService.connect(userProvider.user.token, userProvider.user.id);

      setState(() {
        userId = id;
      });

      // Lắng nghe sự kiện newMessage
      _socketService.onNewMessage((data) {
        setState(() {
          _unreadMessages++; // Tăng số tin nhắn chưa đọc
        });
      });
    }
  }

  // Callback function để reset index và unreadMessages
  void _resetIndex() {
    setState(() {
      _selectedIndex = 0; // Chuyển về tab đầu tiên (Home)
      _unreadMessages = 0; // Reset số tin nhắn chưa đọc
    });
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
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
              // Pass the callback to reset index
              MessageButton(
                userId: userId,
                unreadMessages: _unreadMessages,
                onMessageButtonPressed: _resetIndex, // Truyền callback để reset
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
              onPageChanged(index); // Gọi async handler
            },
            tabs: const [
              GButton(icon: Icons.home, text: 'Home'),
              GButton(icon: Icons.vertical_split_outlined, text: 'Courts'),
              GButton(icon: Icons.dashboard, text: 'Post'),
              GButton(icon: Icons.account_circle, text: 'Account'),
            ],
          ),
        ),
      ),
    );
  }
}
