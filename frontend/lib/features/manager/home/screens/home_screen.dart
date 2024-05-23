import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/home/widgets/facility_home.dart';
import 'package:frontend/features/manager/home/widgets/item_tag.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeIndex = 0;
  final _tempImageQuantity = 5;
  int _rateNumber = 44;
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Container(
        color: GlobalVariables.defaultColor,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 1,
                color: GlobalVariables.white,
              ),
              FacilityHome(),
              ItemTag(
                title: 'View detail infomation',
                description: 'View your badminton facility detail infomation',
                imgPath: 'assets/images/img_court.png',
                onTap: () {},
                isVisibleArrow: true,
              ),
              ItemTag(
                title: 'Datetime management',
                description: 'Update the infomation of your badminton facility',
                imgPath: 'assets/images/img_datetime.png',
                onTap: () {},
                isVisibleArrow: true,
              ),
              ItemTag(
                title: 'Statistic',
                description:
                    'Statistics on your badminton facility business activities',
                imgPath: 'assets/images/img_statistic.png',
                onTap: () {},
                isVisibleArrow: true,
              ),
              ItemTag(
                title: 'Support',
                description: 'Message admin for support',
                imgPath: 'assets/images/img_support.png',
                onTap: () {},
                isVisibleArrow: true,
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
}
