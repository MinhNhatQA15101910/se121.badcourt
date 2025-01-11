import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_button.dart';
import 'package:frontend/common/widgets/custom_container.dart';
import 'package:frontend/common/widgets/separator.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/player/checkout/widgets/checkout_item.dart';
import 'package:frontend/features/player/checkout/widgets/checkout_total_price.dart';
import 'package:frontend/features/player/facility_detail/screens/facility_detail_screen.dart';
import 'package:frontend/features/player/facility_detail/services/facility_detail_service.dart';
import 'package:frontend/providers/manager/current_facility_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/checkout_provider.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends StatefulWidget {
  static const String routeName = '/checkoutScreen';
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _facilityDetailService = FacilityDetailService();

  void _navigateToCourtDetailScreen() {
    Navigator.of(context).pushReplacementNamed(FacilityDetailScreen.routeName);
  }

  Future<void> bookCourt(
    String id,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      _facilityDetailService.bookCourt(
        context,
        id,
        startTime,
        endTime,
      );
      _navigateToCourtDetailScreen();
    } catch (e) {}
  }

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
    final currentFacilityProvider = context.watch<CurrentFacilityProvider>();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: GlobalVariables.green,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Checkout',
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
        body: Consumer<CheckoutProvider>(
          builder: (context, checkoutProvider, child) {
            final court = checkoutProvider.court;
            final startDate = checkoutProvider.startDate;
            final endDate = checkoutProvider.endDate;
            final durationHours = endDate.difference(startDate).inHours;
            final pricePerHour = court.pricePerHour;
            final totalPrice = durationHours * pricePerHour;

            final DateFormat dateFormat =
                DateFormat('EEEE, dd/MM/yyyy'); // Định dạng ngày

            return Column(
              children: [
                Expanded(
                  child: Container(
                    color: GlobalVariables.defaultColor,
                    child: SingleChildScrollView(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: 2 / 1,
                              child: Image(
                                image: NetworkImage(
                                  currentFacilityProvider
                                      .currentFacility.facilityImages.first.url,
                                ),
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
                              child: _interMedium18(
                                currentFacilityProvider.currentFacility.name,
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
                              child: _interBold16(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _interRegular14(
                                          currentFacilityProvider
                                              .currentFacility
                                              .managerInfo
                                              .fullName,
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
                                              _interRegular12(
                                                currentFacilityProvider
                                                    .currentFacility.province,
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
                              child: _interBold16(
                                'Detail address',
                                GlobalVariables.blackGrey,
                                1,
                              ),
                            ),
                            CustomContainer(
                              child: Container(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
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
                                      child: _interBold14(
                                        currentFacilityProvider
                                            .currentFacility.detailAddress,
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
                              child: _interBold16(
                                'Booking info',
                                GlobalVariables.blackGrey,
                                1,
                              ),
                            ),
                            CustomContainer(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _interBold16(
                                    dateFormat.format(startDate),
                                    GlobalVariables.blackGrey,
                                    1,
                                  ),
                                  Separator(color: GlobalVariables.darkGrey),
                                  CheckoutItem(),
                                ],
                              ),
                            ),
                            CheckoutTotalPrice(
                              promotionPrice: 0,
                              subTotalPrice: totalPrice.toDouble(),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  color: GlobalVariables.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: CustomButton(
                    buttonText: 'Checkout',
                    borderColor: GlobalVariables.green,
                    fillColor: GlobalVariables.green,
                    textColor: Colors.white,
                    onTap: () {
                      bookCourt(
                        court.id,
                        startDate,
                        endDate,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _interMedium18(
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
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _interBold16(
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
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _interRegular14(
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

  Widget _interRegular12(
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

  Widget _interBold14(
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
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
