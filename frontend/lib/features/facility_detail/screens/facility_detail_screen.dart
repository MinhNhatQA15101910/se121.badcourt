import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:frontend/common/widgets/custom_button.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/facility_detail/widgets/recent_ratings_widget.dart';
import 'package:frontend/features/message/screens/message_detail_screen.dart';
import 'package:frontend/features/court/screens/court_screen.dart';
import 'package:frontend/features/facility_detail/screens/player_map_screen.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/providers/manager/current_facility_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
      CourtScreen.routeName,
      arguments: facility,
    );
  }

  void _navigateToPlayerMapScreen(Facility facility) {
    Navigator.of(context).pushNamed(
      PlayerMapScreen.routeName,
      arguments: facility,
    );
  }

  Future<void> _navigateToCallPhoneScreen(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('Lỗi mở ứng dụng gọi điện: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể mở ứng dụng gọi điện')),
        );
      }
    }
  }

  void _navigateToDetailMessageScreen(BuildContext context, String userId) {
    Navigator.of(context).pushNamed(
      MessageDetailScreen.routeName,
      arguments: userId,
    );
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

  @override
  Widget build(BuildContext context) {
    final facilityProvider = Provider.of<CurrentFacilityProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    final currentFacility = facilityProvider.currentFacility;
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
                    itemCount: currentFacility.facilityImages.isNotEmpty
                        ? currentFacility.facilityImages.length
                        : 1,
                    itemBuilder: (context, index, realIndex) {
                      if (currentFacility.facilityImages.isEmpty) {
                        return Image.asset(
                          'assets/images/demo_facility.png',
                          fit: BoxFit.cover,
                        );
                      }

                      final imageUrl =
                          currentFacility.facilityImages[index].url;
                      return Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {},
                          ),
                        ),
                        child: imageUrl.isNotEmpty
                            ? Container()
                            : Image.asset(
                                'assets/images/demo_facility.png',
                                fit: BoxFit.cover,
                              ),
                      );
                    },
                    options: CarouselOptions(
                      viewportFraction: 1.0,
                      aspectRatio: 3 / 2,
                      onPageChanged: (index, reason) => setState(() {
                        _activeIndex = index;
                      }),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        currentFacility.facilityImages.length,
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
                        currentFacility.facilityName,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: GlobalVariables.blackGrey,
                        ),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Row(
                        children: [
                          if (currentFacility.totalRating > 0) ...[
                            RatingBar.builder(
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 20,
                              initialRating: currentFacility.ratingAvg,
                              ignoreGestures: true,
                              unratedColor: GlobalVariables.lightYellow,
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: GlobalVariables.yellow,
                              ),
                              onRatingUpdate: (rating) {},
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${currentFacility.ratingAvg.toStringAsFixed(1)}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: GlobalVariables.blackGrey,
                              ),
                            ),
                            Text(
                              ' (${currentFacility.totalRating} reviews)',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: GlobalVariables.darkGrey,
                              ),
                            ),
                          ] else ...[
                            Row(
                              children: List.generate(
                                  5,
                                  (index) => Icon(
                                        Icons.star_border,
                                        size: 20,
                                        color: GlobalVariables.lightGrey,
                                      )),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'No reviews yet',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: GlobalVariables.darkGrey,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Row(
                        children: [
                          if (currentFacility.minPrice > 0)
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
                                  _formatPrice(currentFacility.minPrice),
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: GlobalVariables.green,
                                  ),
                                ),
                              ),
                            ),
                          if (currentFacility.maxPrice > 0 &&
                              currentFacility.maxPrice >
                                  currentFacility.minPrice)
                            Text(
                              " to ",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: GlobalVariables.green,
                              ),
                            ),
                          if (currentFacility.maxPrice > 0 &&
                              currentFacility.maxPrice >
                                  currentFacility.minPrice)
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
                                  _formatPrice(currentFacility.maxPrice),
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: GlobalVariables.green,
                                  ),
                                ),
                              ),
                            ),
                          if (currentFacility.minPrice > 0)
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
                        child: Image.network(
                          currentFacility.userImageUrl ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/img_account.png',
                              fit: BoxFit.cover,
                            );
                          },
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
                            currentFacility.userName,
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
                                  currentFacility.province,
                                  GlobalVariables.darkGrey,
                                  1,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _navigateToCallPhoneScreen(
                            currentFacility.managerInfo.phoneNumber);
                      },
                      child: Container(
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
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    GestureDetector(
                      onTap: () {
                        _navigateToDetailMessageScreen(
                            context, currentFacility.userId);
                      },
                      child: Container(
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
                        _navigateToPlayerMapScreen(currentFacility);
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
                                    currentFacility.detailAddress,
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
                      currentFacility.courtsAmount.toString(),
                    ),
                    SizedBox(height: 12),
                    Text(
                      currentFacility.description,
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
                      currentFacility.policy,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: GlobalVariables.blackGrey),
                    ),
                  ],
                ),
              ),
              Container(
                height: 12,
                color: GlobalVariables.defaultColor,
              ),
              RecentRatingsWidget(
                facilityId: currentFacility.id,
                facilityName: currentFacility.facilityName,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: userProvider.user.id != currentFacility.userId
          ? Container(
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
                  _navigateToCourtDetailScreen(currentFacility);
                },
              ),
            )
          : null,
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
