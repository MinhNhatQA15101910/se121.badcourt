import 'package:flutter/material.dart';
import 'package:frontend/Enums/facility_state.dart';
import 'package:frontend/common/widgets/state_badge_widget.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:frontend/features/manager/add_facility/screens/facility_registration_screen.dart';
import 'package:frontend/features/manager/intro_manager/screens/intro_manager_screen.dart';
import 'package:frontend/features/manager/manager_home/services/manager_home_service.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/providers/manager/current_facility_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FacilityHome extends StatefulWidget {
  const FacilityHome({super.key});

  @override
  State<FacilityHome> createState() => _FacilityHomeState();
}

class _FacilityHomeState extends State<FacilityHome> {
  int _activeIndex = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  void _navigateToIntroManagerScreen() {
    Navigator.of(context).pushReplacementNamed(IntroManagerScreen.routeName);
  }

  void _navigateToFacilityInfo(Facility? facility) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FacilityRegistrationScreen(existingFacility: facility),
      ),
    );
  }

Future<void> _deleteFacility(String facilityId) async {
  final ManagerHomeService managerHomeService = new ManagerHomeService();
  bool success = await managerHomeService.deleteFacility(
    context: context,
    facilityId: facilityId,
  );
  if(success){
    _navigateToIntroManagerScreen();
  }
}

  String _formatPrice(int price) {
    if (price >= 1000000) {
      double millions = price / 1000000;
      if (millions == millions.toInt()) {
        return '${millions.toInt()}tr đ';
      } else {
        return '${millions.toStringAsFixed(1)}tr đ';
      }
    } else if (price >= 1000) {
      double thousands = price / 1000;
      if (thousands == thousands.toInt()) {
        return '${thousands.toInt()}k đ';
      } else {
        return '${thousands.toStringAsFixed(1)}k đ';
      }
    } else {
      return '${price}đ';
    }
  }

  void _showEditDialog(Facility? facility) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.edit, color: GlobalVariables.yellow),
              SizedBox(width: 8),
              Text('Update Facility'),
            ],
          ),
          content: Text('Do you want to update this facility information?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToFacilityInfo(facility);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GlobalVariables.yellow,
                foregroundColor: GlobalVariables.white,
              ),
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(Facility? facility) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.delete, color: GlobalVariables.red),
              SizedBox(width: 8),
              Text('Delete Facility'),
            ],
          ),
          content: Text(
              'Are you sure you want to delete this facility? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteFacility(facility!.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GlobalVariables.red,
                foregroundColor: GlobalVariables.white,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentFacilityProvider = context.watch<CurrentFacilityProvider>();
    final currentFacility = currentFacilityProvider.currentFacility;
    final imageCount =
        currentFacilityProvider.currentFacility.facilityImages.length;
    final minPrice = currentFacilityProvider.currentFacility.minPrice;
    final maxPrice = currentFacilityProvider.currentFacility.maxPrice;

    // Convert string state to enum
    final facilityState = FacilityStateExtension.fromString(
        currentFacilityProvider.currentFacility.state);

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with action buttons
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            color: GlobalVariables.green,
            child: SafeArea(
              child: Row(
                children: [
                  StateBadge(
                    state: facilityState,
                    fontSize: 12,
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => _showEditDialog(currentFacility),
                    icon: Icon(
                      Icons.edit,
                      color: GlobalVariables.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showDeleteDialog(currentFacility),
                    icon: Icon(
                      Icons.delete_outline,
                      color: GlobalVariables.white,
                    ),
                  ),
                  IconButton(
                    onPressed: _navigateToIntroManagerScreen,
                    icon: Icon(
                      Icons.sync_alt_outlined,
                      color: GlobalVariables.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Image Carousel
          Stack(
            children: [
              CarouselSlider.builder(
                carouselController: _controller,
                itemCount: imageCount,
                options: CarouselOptions(
                  viewportFraction: 1.0,
                  aspectRatio: 2,
                  onPageChanged: (index, reason) => setState(() {
                    _activeIndex = index;
                  }),
                ),
                itemBuilder: (context, index, realIndex) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          currentFacilityProvider
                              .currentFacility.facilityImages[index].url,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
              if (imageCount > 1)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      imageCount,
                      (index) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          child: CircleAvatar(
                            radius: 4,
                            backgroundColor: _activeIndex == index
                                ? GlobalVariables.green
                                : GlobalVariables.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),

          // Facility Information
          Container(
            width: double.maxFinite,
            padding: EdgeInsets.all(16),
            color: GlobalVariables.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Facility Name
                Text(
                  currentFacilityProvider.currentFacility.facilityName,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: GlobalVariables.blackGrey,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    if (minPrice > 0)
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: GlobalVariables.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _formatPrice(minPrice),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: GlobalVariables.green,
                            ),
                          ),
                        ),
                      ),
                    if (maxPrice > 0 && maxPrice > minPrice)
                      Text(
                        " to ",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: GlobalVariables.green,
                        ),
                      ),
                    if (maxPrice > 0 && maxPrice > minPrice)
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: GlobalVariables.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _formatPrice(maxPrice),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: GlobalVariables.green,
                            ),
                          ),
                        ),
                      ),
                    if (minPrice > 0)
                      Text(
                        " per hour",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: GlobalVariables.green,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
