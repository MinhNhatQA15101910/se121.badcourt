// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_container.dart';
import 'package:frontend/common/widgets/separator.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/player/booking_details/widgets/total_price.dart';
import 'package:frontend/models/order.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BookingDetailScreen extends StatefulWidget {
  static const String routeName = '/booking-detail-screen';
  const BookingDetailScreen({Key? key}) : super(key: key);

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final titleStyle = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: GlobalVariables.blackGrey,
  );

  final contentStyle = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: GlobalVariables.blackGrey,
  );

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    final order = ModalRoute.of(context)!.settings.arguments as Order;
    DateTime playTime = order.timePeriod.hourFrom;
    bool isPlayed = now.isAfter(playTime);

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
                      order.facilityName,
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
                              SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: _InterBold14(
                                    order.id, GlobalVariables.blackGrey, 1),
                              ),
                            ],
                          ),
                          Separator(color: GlobalVariables.darkGrey),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _InterMedium14(
                                  'Booking date', GlobalVariables.blackGrey, 1),
                              _InterBold14(
                                '${order.createdAt.hour}:${order.createdAt.minute}, ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                                GlobalVariables.blackGrey,
                                1,
                              ),
                            ],
                          ),
                          Separator(color: GlobalVariables.darkGrey),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _InterMedium14(
                                  'Order status', GlobalVariables.blackGrey, 1),
                              _InterBold14(
                                isPlayed ? 'Played' : 'Not played',
                                isPlayed
                                    ? GlobalVariables.darkGreen
                                    : GlobalVariables.darkYellow,
                                1,
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
                    ),
                    child: _InterBold16(
                      'Facility owner',
                      GlobalVariables.blackGrey,
                      1,
                    ),
                  ),
                  CustomContainer(
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
                                'Mai Hoàng Nhật Duy',
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
                                      'TP Hồ Chí Minh',
                                      GlobalVariables.darkGrey,
                                      1,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                              order.address,
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
                          DateFormat('EEEE, dd/MM/yyyy')
                              .format(order.timePeriod.hourFrom),
                          GlobalVariables.blackGrey,
                          1,
                        ),
                        Separator(color: GlobalVariables.darkGrey),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _InterBold14(
                                'Court 1',
                                GlobalVariables.blackGrey,
                                1,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _InterRegular14(
                                    DateFormat('hh:mm')
                                            .format(order.timePeriod.hourFrom) +
                                        ' to ' +
                                        DateFormat('hh:mm')
                                            .format(order.timePeriod.hourTo),
                                    GlobalVariables.blackGrey,
                                    1,
                                  ),
                                  _InterSemiBold14(
                                    order.price.toStringAsFixed(0) + ' đ',
                                    GlobalVariables.blackGrey,
                                    1,
                                  ),
                                ],
                              ),
                              Separator(color: GlobalVariables.darkGrey),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  TotalPrice(promotionPrice: 0, subTotalPrice: order.price),
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

  Widget _InterRegular16(String text, Color color, int maxLines) {
    return Container(
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
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _InterSemiBold14(String text, Color color, int maxLines) {
    return Container(
      child: Text(
        text,
        textAlign: TextAlign.start,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w600,
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
