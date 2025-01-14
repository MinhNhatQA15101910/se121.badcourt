import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/common/widgets/colored_safe_area.dart';
import 'package:frontend/common/widgets/manager_facility_item.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/account/services/account_service.dart';
import 'package:frontend/features/manager/add_facility/screens/facility_info_screen.dart';
import 'package:frontend/features/manager/intro_manager/services/intro_manager_service.dart';
import 'package:frontend/models/facility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class IntroManagerScreen extends StatefulWidget {
  static const String routeName = '/manager/manager-intro';
  const IntroManagerScreen({super.key});

  @override
  State<IntroManagerScreen> createState() => _IntroManagerScreenState();
}

class _IntroManagerScreenState extends State<IntroManagerScreen> {
  final _introManagerService = IntroManagerService();
  List<Facility> _facilityList = [];

  void _logOut() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Log out confirm'),
          content: const Text('Are you sure to log out the app?'),
          actions: [
            TextButton(
              onPressed: () {
                final accountService = AccountService();
                accountService.logOut(context);

                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            )
          ],
        );
      },
    );
  }

  void _navigateToFacilityInfo() {
    Navigator.of(context).pushNamed(FacilityInfo.routeName);
  }

  void _fetchFacilitiesByUserId() async {
    _facilityList = await _introManagerService.fetchFacilitiesByUserId(
      context: context,
    );

    if (!mounted) return;

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _fetchFacilitiesByUserId();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredSafeArea(
      child: Scaffold(
        backgroundColor: GlobalVariables.green,
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            if (_facilityList.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Choose your badminton facility',
                  style: GoogleFonts.inter(
                    color: GlobalVariables.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ..._facilityList.map(
                (facility) => ManagerFacilityItem(facility: facility),
              ),
              const SizedBox(height: 16),
            ] else ...[
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/vectors/vector-badminton-cross.svg',
                      width: 240,
                      height: 240,
                      colorFilter: ColorFilter.mode(
                        GlobalVariables.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'No badminton facility yet',
                      style: GoogleFonts.inter(
                        color: GlobalVariables.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: _navigateToFacilityInfo,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: GlobalVariables.white,
                      ),
                      child: Text(
                        'Add a new facility',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: GlobalVariables.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            if (_facilityList.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    // Register a facility button
                    SizedBox(
                      width: 240,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _navigateToFacilityInfo,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: GlobalVariables.white,
                        ),
                        child: Text(
                          'Register a facility',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: GlobalVariables.green,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Logout button
                    Container(
                      width: 240,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: GlobalVariables.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ElevatedButton(
                        onPressed: _logOut,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                        ),
                        child: Text(
                          'Logout',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: GlobalVariables.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Facility registration instructions
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: RichText(
                  text: TextSpan(
                    text: 'View ',
                    style: GoogleFonts.inter(
                      color: GlobalVariables.white,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: 'facility registration instructions',
                        style: GoogleFonts.inter(
                          color: GlobalVariables.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
