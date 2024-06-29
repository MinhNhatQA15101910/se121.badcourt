import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:frontend/models/facility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class FacilityItem extends StatefulWidget {
  const FacilityItem({
    super.key,
    required this.onTap,
    required this.facility,
  });

  final Facility facility;
  final VoidCallback onTap;

  @override
  _FacilityItemState createState() => _FacilityItemState();
}

class _FacilityItemState extends State<FacilityItem> {
  int _activeIndex = 0;
  final int _tempImageQuantity = 5; // Placeholder for image count
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: GlobalVariables.white,
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
                      carouselController: _controller,
                      itemCount: _tempImageQuantity,
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
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            image: DecorationImage(
                              image: NetworkImage(
                                  widget.facility.imageUrls[index]),
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
                          _tempImageQuantity,
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
              _InterRegular16(
                widget.facility.name,
                GlobalVariables.blackGrey,
                2,
              ),
              Row(
                children: [
                  _InterBold14(
                    '140000đ - 180000đ',
                    GlobalVariables.blackGrey,
                    1,
                  ),
                ],
              ),
              Row(
                children: [
                  RatingBarIndicator(
                    rating: widget.facility.ratingAvg
                        .toDouble(), // Use the facility's rating
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: GlobalVariables.yellow,
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
                        color: GlobalVariables.darkGrey,
                      ),
                    ),
                  ),
                ],
              ),
              _InterRegular14(
                widget.facility.detailAddress,
                GlobalVariables.darkGrey,
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

  Widget _InterRegular16(String text, Color color, int maxLines) {
    return Container(
      padding: EdgeInsets.only(
        top: 12,
      ),
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

  Widget _InterBold14(String text, Color color, int maxLines) {
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

  Widget _InterRegular14(String text, Color color, int maxLines) {
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
