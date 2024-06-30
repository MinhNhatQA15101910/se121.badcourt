import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:frontend/common/widgets/custom_radio_button.dart';
import 'package:frontend/common/widgets/single_facility_card.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/player/home/services/home_service.dart';
import 'package:frontend/models/facility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeIndex = 0;
  final CarouselController _carouselController = CarouselController();
  final List<String> cities = [
    'Hà Nội',
    'Thành phố Hồ Chí Minh',
    'Đà Nẵng',
    'Hải Phòng',
    'Cần Thơ',
  ];
  String _selectedCity = 'Hà Nội';
  final _homeService = HomeService();
  List<Facility> _facility = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllFacilities();
  }

  Future<void> fetchAllFacilities() async {
    final facilities = await _homeService.fetchAllFacilities(context);
    setState(() {
      _facility = facilities;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  children: [
                    CarouselSlider.builder(
                      itemCount: 5,
                      carouselController: _carouselController,
                      options: CarouselOptions(
                        viewportFraction: 0.8,
                        aspectRatio: 3 / 1,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 6),
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 1000),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        pauseAutoPlayOnTouch: true,
                        enlargeCenterPage: true,
                        scrollDirection: Axis.horizontal,
                        enableInfiniteScroll: true,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _activeIndex = index;
                          });
                        },
                      ),
                      itemBuilder: (context, index, realIndex) => Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/images/img_carousel_${index + 1}.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    AnimatedSmoothIndicator(
                      activeIndex: _activeIndex,
                      count: 5,
                      duration: const Duration(milliseconds: 600),
                      effect: const ExpandingDotsEffect(
                        spacing: 8.0,
                        radius: 4.0,
                        dotWidth: 12.0,
                        dotHeight: 4.0,
                        strokeWidth: 1.5,
                        dotColor: GlobalVariables.grey,
                        activeDotColor: GlobalVariables.yellow,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 12,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Near by your location',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Row(
                                  children: [
                                    Text(
                                      'View more',
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: GlobalVariables.green,
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_outlined,
                                      color: GlobalVariables.green,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Container(
                            height: 240,
                            child: _facility.isNotEmpty
                                ? GridView.builder(
                                    padding: const EdgeInsets.all(0),
                                    itemCount: _facility.length,
                                    scrollDirection: Axis.horizontal,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 1,
                                      mainAxisSpacing: 20,
                                      childAspectRatio: 5 / 3,
                                    ),
                                    itemBuilder: (context, index) {
                                      return SingleFacilityCard(
                                        facility: _facility[index],
                                      );
                                    },
                                    physics: const BouncingScrollPhysics(),
                                  )
                                : Center(
                                    child: Text('No facilities available'),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: GlobalVariables.defaultColor,
                      height: 12,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 12,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Select by location',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Row(
                                  children: [
                                    Text(
                                      'View more',
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: GlobalVariables.green,
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_outlined,
                                      color: GlobalVariables.green,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          CustomRadioButton(
                            choices: cities,
                            selectedChoice: _selectedCity,
                            onSelected: (choice) {
                              setState(() {
                                _selectedCity = choice;
                              });
                            },
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Container(
                            height: 240,
                            child: _facility.isNotEmpty
                                ? GridView.builder(
                                    padding: const EdgeInsets.all(0),
                                    itemCount: _facility.length,
                                    scrollDirection: Axis.horizontal,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 1,
                                      mainAxisSpacing: 20,
                                      childAspectRatio: 5 / 3,
                                    ),
                                    itemBuilder: (context, index) {
                                      return SingleFacilityCard(
                                        facility: _facility[index],
                                      );
                                    },
                                    physics: const BouncingScrollPhysics(),
                                  )
                                : Center(
                                    child: Text('No facilities available'),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: GlobalVariables.defaultColor,
                      height: 12,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recommended for you',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Row(
                                  children: [
                                    Text(
                                      'View more',
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: GlobalVariables.green,
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_outlined,
                                      color: GlobalVariables.green,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          _facility.isNotEmpty
                              ? GridView.builder(
                                  itemCount: _facility.length,
                                  shrinkWrap: true,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 3 / 5,
                                  ),
                                  itemBuilder: (context, index) {
                                    return SingleFacilityCard(
                                      facility: _facility[index],
                                    );
                                  },
                                  physics: const NeverScrollableScrollPhysics(),
                                )
                              : Center(
                                  child: Text('No facilities available'),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
