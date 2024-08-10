import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:frontend/features/manager/manager_bottom_bar.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/providers/manager/current_facility_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FacilityItem extends StatefulWidget {
  const FacilityItem({
    super.key,
    required this.facility,
    this.onPrimary = false,
  });

  final Facility facility;
  final bool onPrimary;

  @override
  State<FacilityItem> createState() => _FacilityItemState();
}

class _FacilityItemState extends State<FacilityItem> {
  int _activeIndex = 0;

  void _navigateToFacilityManagerBottomBar() {
    final currentFacilityProvider = Provider.of<CurrentFacilityProvider>(
      context,
      listen: false,
    );
    currentFacilityProvider.setFacility(widget.facility);

    Navigator.of(context).pushNamedAndRemoveUntil(
      ManagerBottomBar.routeName,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageCount = widget.facility.imageUrls.length;
    final minPrice = widget.facility.minPrice;
    final maxPrice = widget.facility.maxPrice;

    return GestureDetector(
      onTap: _navigateToFacilityManagerBottomBar,
      child: Container(
        margin: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color:
              widget.onPrimary ? GlobalVariables.green : GlobalVariables.white,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: 12,
                ),
                child: Stack(
                  children: [
                    CarouselSlider.builder(
                      itemCount: imageCount,
                      options: CarouselOptions(
                        viewportFraction: 1.0,
                        enableInfiniteScroll: imageCount > 1,
                        aspectRatio: 2,
                        onPageChanged: (index, reason) => setState(() {
                          _activeIndex = index;
                        }),
                      ),
                      itemBuilder: (context, index, realIndex) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            image: DecorationImage(
                              image: NetworkImage(
                                widget.facility.imageUrls[index],
                              ),
                              fit: BoxFit.contain,
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
              ),
              _interRegular16(
                widget.facility.name,
                widget.onPrimary
                    ? GlobalVariables.white
                    : GlobalVariables.blackGrey,
                2,
              ),
              Row(
                children: [
                  _interBold14(
                    minPrice == maxPrice
                        ? NumberFormat.currency(
                            locale: 'vi_VN',
                            symbol: 'đ',
                          ).format(minPrice)
                        : '${NumberFormat.currency(
                            locale: 'vi_VN',
                            symbol: 'đ',
                          ).format(widget.facility.minPrice)} - ${NumberFormat.currency(
                            locale: 'vi_VN',
                            symbol: 'đ',
                          ).format(widget.facility.maxPrice)}',
                    widget.onPrimary
                        ? GlobalVariables.white
                        : GlobalVariables.blackGrey,
                    1,
                  ),
                ],
              ),
              Row(
                children: [
                  RatingBarIndicator(
                    rating: widget.facility.ratingAvg,
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: Colors.yellow,
                    ),
                    itemCount: 5,
                    itemSize: 20.0,
                    unratedColor: GlobalVariables.lightGreen,
                    direction: Axis.horizontal,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      ' (${widget.facility.totalRating})',
                      style: GoogleFonts.inter(
                        color: widget.onPrimary
                            ? GlobalVariables.white
                            : GlobalVariables.darkGrey,
                      ),
                    ),
                  ),
                ],
              ),
              _interRegular14(
                widget.facility.detailAddress,
                widget.onPrimary
                    ? GlobalVariables.white
                    : GlobalVariables.darkGrey,
                2,
              ),
              SizedBox(
                height: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _interRegular16(String text, Color color, int maxLines) {
    return Container(
      padding: EdgeInsets.only(top: 12),
      child: Text(
        text,
        textAlign: TextAlign.start,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _interBold14(String text, Color color, int maxLines) {
    return Container(
      padding: EdgeInsets.only(
        top: 4,
      ),
      child: Text(
        text,
        textAlign: TextAlign.start,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _interRegular14(String text, Color color, int maxLines) {
    return Container(
      padding: EdgeInsets.only(
        top: 4,
      ),
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
}
