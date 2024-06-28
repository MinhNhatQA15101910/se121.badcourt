import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:frontend/common/widgets/custom_container.dart';
import 'package:frontend/common/widgets/facility_item.dart';
import 'package:frontend/common/widgets/separator.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';

class ManagerAccountScreen extends StatelessWidget {
  const ManagerAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: GlobalVariables.green,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'ACCOUNT',
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
      body: Container(
        color: GlobalVariables.defaultColor,
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 3 / 2,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/img_account_background.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.5),
                              Colors.black.withOpacity(0.5)
                            ],
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AspectRatio(
                            aspectRatio: 3 / 1,
                            child:
                                Container(color: GlobalVariables.defaultColor),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AspectRatio(
                            aspectRatio: 3 / 1,
                            child: Row(
                              children: [
                                AspectRatio(aspectRatio: 1.0),
                                AspectRatio(
                                  aspectRatio: 1.0,
                                  child: ClipOval(
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Image.asset(
                                        'assets/images/img_account.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                AspectRatio(aspectRatio: 1.0),
                              ],
                            ),
                          ),
                          AspectRatio(
                            aspectRatio: 3 / 0.5,
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 16),
                              child: Center(
                                child: _usernameText(
                                  'Mai Hoàng Nhật Duy Siêu Cấp Đẹp Trai Nhất Vũ Trụ',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                CustomContainer(
                  child: Container(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _InterMedium14('5.0', GlobalVariables.blackGrey, 1),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: RatingBar.builder(
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                ignoreGestures: true,
                                itemCount: 5,
                                itemSize: 16,
                                unratedColor: GlobalVariables.lightYellow,
                                itemBuilder: (context, _) => const Icon(
                                  Icons.star,
                                  color: GlobalVariables.yellow,
                                ),
                                onRatingUpdate: (rating) {
                                  print(rating);
                                },
                              ),
                            ),
                            _InterRegular14(
                              '(50 Ratings)',
                              GlobalVariables.green,
                              1,
                            ),
                          ],
                        ),
                        Separator(color: GlobalVariables.darkGrey),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _InterMedium14(
                              'Response rate (24h recent)',
                              GlobalVariables.blackGrey,
                              1,
                            ),
                            _InterBold14(
                              '97%',
                              GlobalVariables.blackGrey,
                              1,
                            ),
                          ],
                        ),
                        Separator(color: GlobalVariables.darkGrey),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: GlobalVariables.green,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: _InterBold14(
                                '288 Erie Street South Unit D, Leamington, Ontario',
                                GlobalVariables.blackGrey,
                                4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    top: 12,
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ),
                  child: _InterBold16(
                    'Badminton facility list',
                    GlobalVariables.blackGrey,
                    1,
                  ),
                ),
                FacilityItem(onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _usernameText(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _InterBold16(String text, Color color, int maxLines) {
    return Container(
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

  Widget _InterRegular14(String text, Color color, int maxLines) {
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

  Widget _InterMedium14(String text, Color color, int maxLines) {
    return Container(
      child: Text(
        text,
        textAlign: TextAlign.start,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _InterBold14(String text, Color color, int maxLines) {
    return Container(
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
}
