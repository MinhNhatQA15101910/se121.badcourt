import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/common/widgets/colored_safe_area.dart';
import 'package:frontend/common/widgets/facility_item.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/add_facility/screens/facility_info_screen.dart';
import 'package:frontend/features/manager/intro_manager/services/intro_manager_service.dart';
import 'package:frontend/features/manager/manager_drawer.dart';
import 'package:frontend/models/facility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class IntroManagerScreen extends StatefulWidget {
  static const String routeName = '/manager-intro';
  const IntroManagerScreen({Key? key});

  @override
  State<IntroManagerScreen> createState() => _IntroManagerScreenState();
}

class _IntroManagerScreenState extends State<IntroManagerScreen> {
  final _introManagerService = IntroManagerService();

  List<Facility> _facilityList = [];

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
    Widget content = Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Vector badminton cross
          SvgPicture.asset(
            'assets/vectors/vector-badminton-cross.svg',
            width: 240,
            height: 240,
            colorFilter: ColorFilter.mode(
              GlobalVariables.green,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 15),

          // No badminton facility yet text
          Text(
            'No badminton',
            style: GoogleFonts.inter(
              color: GlobalVariables.green,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'facility yet',
            style: GoogleFonts.inter(
              color: GlobalVariables.green,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Let's add a badminton facility text
          Text(
            "Let's add a badminton facility",
            style: GoogleFonts.inter(
              color: GlobalVariables.green,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 15),

          // Add a new facility button
          SizedBox(
            width: 240,
            height: 40,
            child: ElevatedButton(
              onPressed: _navigateToFacilityInfo,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: GlobalVariables.green,
              ),
              child: Text(
                'Add a new facility',
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
    );

    if (_facilityList.isNotEmpty) {
      content = Expanded(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Choose your badminton facility',
                    style: GoogleFonts.inter(
                      color: GlobalVariables.green,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 450,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _facilityList.length,
                  itemBuilder: (context, index) => FacilityItem(
                    facility: _facilityList[index],
                    onPrimary: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ColoredSafeArea(
      child: Scaffold(
        backgroundColor: GlobalVariables.white,
        drawer: ManagerDrawer(),
        appBar: AppBar(
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
              IconButton(
                onPressed: () {},
                iconSize: 24,
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: GlobalVariables.white,
                ),
              ),
              IconButton(
                onPressed: () {},
                iconSize: 24,
                icon: const Icon(
                  Icons.message_outlined,
                  color: GlobalVariables.white,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            content,

            // Register a facility button
            if (_facilityList.isNotEmpty)
              SizedBox(
                width: 240,
                height: 40,
                child: ElevatedButton(
                  onPressed: _navigateToFacilityInfo,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: GlobalVariables.green,
                  ),
                  child: Text(
                    'Register a facility',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: GlobalVariables.white,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: RichText(
                  text: TextSpan(
                    text: 'View ',
                    style: GoogleFonts.inter(
                      color: GlobalVariables.green,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: 'facility registration instructions',
                        style: GoogleFonts.inter(
                          color: GlobalVariables.green,
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
