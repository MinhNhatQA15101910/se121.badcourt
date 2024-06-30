import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:frontend/features/manager/intro_manager/screens/intro_manager_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class FacilityHome extends StatefulWidget {
  const FacilityHome({
    super.key,
  });

  @override
  _FacilityHomeState createState() => _FacilityHomeState();
}

class _FacilityHomeState extends State<FacilityHome> {
  int _activeIndex = 0;

  final CarouselController _controller = CarouselController();
  void _navigateToFacilityInfo() {
    Navigator.of(context).pushReplacementNamed(IntroManagerScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final imageCount = GlobalVariables.facility.imageUrls.length;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56,
            color: GlobalVariables.green,
            padding: EdgeInsets.only(
              left: 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _InterMedium16(
                      GlobalVariables.facility.name, GlobalVariables.white, 1),
                ),
                IconButton(
                  onPressed: _navigateToFacilityInfo,
                  iconSize: 24,
                  icon: const Icon(
                    Icons.sync_alt_outlined,
                    color: GlobalVariables.white,
                  ),
                ),
                IconButton(
                  onPressed: () => {},
                  iconSize: 24,
                  color: GlobalVariables.white,
                  icon: PopupMenuButton<String>(
                    onSelected: (String result) {
                      switch (result) {
                        case 'Edit':
                          // Xử lý khi chọn Edit
                          print('Edit selected');
                          break;
                        case 'Delete':
                          // Xử lý khi chọn Delete
                          print('Delete selected');
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'Edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                            GlobalVariables.facility.imageUrls[index]),
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
          Container(
            width: double.maxFinite,
            padding: EdgeInsets.only(
              bottom: 12,
              left: 16,
              right: 16,
            ),
            color: GlobalVariables.white,
            child: Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InterRegular18(
                    GlobalVariables.facility.name,
                    GlobalVariables.blackGrey,
                    1,
                  ),
                  _InterBold16(
                    '120.000đ - 150.000đ /1h ',
                    GlobalVariables.blackGrey,
                    1,
                  ),
                  _InterRegular14Underline(
                    'activated',
                    GlobalVariables.green,
                    1,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _InterRegular18(String text, Color color, int maxLines) {
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
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _InterBold16(String text, Color color, int maxLines) {
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
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _InterRegular14Underline(String text, Color color, int maxLines) {
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
          decoration: TextDecoration.underline,
          decorationColor: color,
        ),
      ),
    );
  }

  Widget _InterMedium16(String text, Color color, int maxLines) {
    return Container(
      padding: EdgeInsets.only(
        bottom: 8,
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
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
