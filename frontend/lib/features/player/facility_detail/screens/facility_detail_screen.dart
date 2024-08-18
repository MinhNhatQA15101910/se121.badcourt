import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:frontend/common/widgets/custom_button.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/player/facility_detail/screens/court_detail_screen.dart';
import 'package:frontend/features/player/facility_detail/screens/player_map_screen.dart';
import 'package:frontend/models/facility.dart';
import 'package:google_fonts/google_fonts.dart';

class FacilityDetailScreen extends StatefulWidget {
  static const String routeName = '/facility-detail-screen';
  const FacilityDetailScreen({Key? key}) : super(key: key);

  @override
  State<FacilityDetailScreen> createState() => _FacilityDetailScreenState();
}

class _FacilityDetailScreenState extends State<FacilityDetailScreen> {
  int _activeIndex = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  void _navigateToCourtDetailScreen(Facility facility) {
    Navigator.of(context).pushNamed(
      CourtDetailScreen.routeName,
      arguments: facility,
    );
  }

  void _navigateToPlayerMapScreen(Facility facility) {
    Navigator.of(context).pushNamed(
      PlayerMapScreen.routeName,
      arguments: facility,
    );
  }

  @override
  Widget build(BuildContext context) {
    final facility = ModalRoute.of(context)!.settings.arguments as Facility;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: GlobalVariables.green,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Facility detail',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
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
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CarouselSlider.builder(
                    carouselController: _controller,
                    itemCount: facility.imageUrls.length, // Số lượng hình ảnh
                    options: CarouselOptions(
                      viewportFraction: 1.0,
                      aspectRatio: 3 / 2,
                      onPageChanged: (index, reason) => setState(() {
                        _activeIndex = index;
                      }),
                    ),
                    itemBuilder: (context, index, realIndex) {
                      return Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              facility.imageUrls[index],
                            ), // Sử dụng NetworkImage
                            fit: BoxFit.fill,
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        facility.imageUrls.length, // Số lượng hình ảnh
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
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () {
                        // Add your favorite button action here
                      },
                    ),
                  ),
                ],
              ),
              Container(
                color: Colors.white,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        facility.name,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: GlobalVariables.blackGrey,
                        ),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Row(
                        children: [
                          RatingBar.builder(
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 20,
                            unratedColor: GlobalVariables.lightYellow,
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: GlobalVariables.yellow,
                            ),
                            onRatingUpdate: (rating) {},
                          ),
                          Text(
                            ' (0)',
                            style: GoogleFonts.inter(
                              color: GlobalVariables.darkGrey,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        '${facility.minPrice}đ - ${facility.maxPrice}đ / h',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: GlobalVariables.blackGrey,
                        ),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 12,
                color: GlobalVariables.defaultColor,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey,
                          width: 0.5,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/demo_facility.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InterRegular14(
                            facility.managerInfo.fullName,
                            GlobalVariables.blackGrey,
                            1,
                          ),
                          Container(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: GlobalVariables.darkGrey,
                                  size: 20,
                                ),
                                _InterRegular12(
                                  facility.province,
                                  GlobalVariables.darkGrey,
                                  1,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: GlobalVariables.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.call_outlined,
                          color: GlobalVariables.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: GlobalVariables.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          width: 1,
                          color: GlobalVariables.green,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.message_outlined,
                          color: GlobalVariables.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 12,
                color: GlobalVariables.defaultColor,
              ),
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Address',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: GlobalVariables.blackGrey,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    GestureDetector(
                      onTap: () {
                        _navigateToPlayerMapScreen(facility);
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: GlobalVariables.lightGrey,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: GlobalVariables.green,
                              size: 24,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    facility.detailAddress,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: GlobalVariables.blackGrey,
                                    ),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: GlobalVariables.green,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 12,
                color: GlobalVariables.defaultColor,
              ),
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Badminton facility detail ',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: GlobalVariables.blackGrey,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildProductDetail(
                      'Number of courts',
                      facility.courtsAmount.toString(),
                    ),
                    SizedBox(height: 12),
                    Text(
                      facility.description,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: GlobalVariables.blackGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 12,
                color: GlobalVariables.defaultColor,
              ),
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Badminton facility policy',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: GlobalVariables.blackGrey,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      facility.policy,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: GlobalVariables.blackGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: GlobalVariables.lightGrey,
              width: 1,
            ),
          ),
        ),
        child: CustomButton(
          buttonText: 'choose the court',
          borderColor: GlobalVariables.green,
          fillColor: GlobalVariables.green,
          textColor: Colors.white,
          onTap: () {
            _navigateToCourtDetailScreen(facility);
          },
        ),
      ),
    );
  }

  Widget _InterRegular14(
    String text,
    Color color,
    int maxLines,
  ) {
    return Container(
      child: Text(
        text,
        textAlign: TextAlign.start,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _InterRegular12(
    String text,
    Color color,
    int maxLines,
  ) {
    return Container(
      child: Text(
        text,
        textAlign: TextAlign.start,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildProductDetail(
    String title,
    String value,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 12,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: GlobalVariables.lightGrey,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: GlobalVariables.blackGrey,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: GlobalVariables.blackGrey,
            ),
          ),
        ],
      ),
    );
  }
}
