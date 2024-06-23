import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_container.dart';
import 'package:frontend/common/widgets/separator.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/booking_details_manager/widgets/booking_info_item_manager.dart';
import 'package:frontend/features/manager/booking_details_manager/widgets/total_price_manager.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingDetailManagerScreen extends StatefulWidget {
  static const String routeName = '/bookingDetailManagerScreen';
  const BookingDetailManagerScreen({Key? key}) : super(key: key);

  @override
  State<BookingDetailManagerScreen> createState() =>
      _BookingDetailManagerScreenState();
}

class _BookingDetailManagerScreenState
    extends State<BookingDetailManagerScreen> {
  String currentStatus = 'Pending';

  final deliverState = {
    'Pending': GlobalVariables.darkYellow,
    'Indelivery': GlobalVariables.darkBlue,
    'Delivered': GlobalVariables.darkGreen,
    'Cancelled': GlobalVariables.darkRed,
  };
  final titleStyle = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  final contentStyle = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: GlobalVariables.green,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Datetime management',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.none,
                  color: GlobalVariables.white,
                ),
              ),
            ],
          ),
        ),
        body: Container(
          color: GlobalVariables.defaultColor,
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 2 / 1,
                    child: Image(
                      image: AssetImage('assets/images/demo_facility.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  Container(
                    width: double.maxFinite,
                    color: GlobalVariables.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: _InterMedium18(
                      'Sân cầu lông Nhật Duy',
                      GlobalVariables.blackGrey,
                      2,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      top: 12,
                      left: 16,
                      right: 16,
                    ),
                    child: _InterBold16(
                      'Booking detail',
                      GlobalVariables.blackGrey,
                      1,
                    ),
                  ),
                  CustomContainer(
                    child: Container(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _InterMedium14(
                                  'Booking ID', GlobalVariables.blackGrey, 1),
                              _InterBold14(
                                  '000000', GlobalVariables.blackGrey, 1),
                            ],
                          ),
                          Separator(color: GlobalVariables.darkGrey),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _InterMedium14(
                                  'Booking date', GlobalVariables.blackGrey, 1),
                              _InterBold14('16:24, 21/05/2021',
                                  GlobalVariables.blackGrey, 1),
                            ],
                          ),
                          Separator(color: GlobalVariables.darkGrey),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _InterMedium14(
                                  'Order status', GlobalVariables.blackGrey, 1),
                              _InterBold14(
                                  currentStatus, GlobalVariables.darkGreen, 1),
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
                    ),
                    child: _InterBold16(
                      'Customer infomation',
                      GlobalVariables.blackGrey,
                      1,
                    ),
                  ),
                  CustomContainer(
                    child: Container(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _InterMedium14(
                                  'Customer ID', GlobalVariables.blackGrey, 1),
                              _InterBold14(
                                  '000000', GlobalVariables.blackGrey, 1),
                            ],
                          ),
                          Separator(color: GlobalVariables.darkGrey),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _InterMedium14(
                                  'Name', GlobalVariables.blackGrey, 1),
                              _InterBold14('Nguyễn Văn Người Chơi',
                                  GlobalVariables.blackGrey, 1),
                            ],
                          ),
                          Separator(color: GlobalVariables.darkGrey),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _InterMedium14(
                                  'Phone number', GlobalVariables.blackGrey, 1),
                              _InterBold14(
                                  '0123456789', GlobalVariables.blackGrey, 1),
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
                    ),
                    child: _InterBold16(
                      'Detail address',
                      GlobalVariables.blackGrey,
                      1,
                    ),
                  ),
                  CustomContainer(
                    child: Container(
                      child: Row(
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
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      top: 12,
                      left: 16,
                      right: 16,
                    ),
                    child: _InterBold16(
                      'Booking info',
                      GlobalVariables.blackGrey,
                      1,
                    ),
                  ),
                  CustomContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InterBold16(
                          'Saturday, 29/03/2024',
                          GlobalVariables.blackGrey,
                          1,
                        ),
                        Separator(color: GlobalVariables.darkGrey),
                        BookingInfoItemManager(),
                        BookingInfoItemManager(),
                      ],
                    ),
                  ),
                  TotalPriceManager(promotionPrice: 0, subTotalPrice: 80),
                  SizedBox(
                    height: 12,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _InterMedium18(String text, Color color, int maxLines) {
    return Container(
      child: Text(
        text,
        textAlign: TextAlign.start,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
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

  Widget _InterRegular12(String text, Color color, int maxLines) {
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
