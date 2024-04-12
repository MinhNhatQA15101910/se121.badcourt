import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/auth/screens/auth_screen.dart';
import 'package:frontend/features/intro/widgets/first_welcome.dart';
import 'package:frontend/features/intro/widgets/second_welcome.dart';
import 'package:frontend/features/intro/widgets/third_welcome.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WelcomeScreen extends StatefulWidget {
  static const String routeName = '/welcome';
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _carouselController = CarouselController();

  var _activeIndex = 0;

  void _animateToSlide(int index) => _carouselController.animateToPage(index);

  Widget _buildIndicator() => AnimatedSmoothIndicator(
        activeIndex: _activeIndex,
        count: 3,
        onDotClicked: _animateToSlide,
        effect: ExpandingDotsEffect(
          dotWidth: 28,
          dotHeight: 5,
          expansionFactor: 1.5,
          dotColor: GlobalVariables.white,
          activeDotColor: GlobalVariables.yellow,
        ),
      );

  void _handleIndex() {
    if (_activeIndex == 2) {
      Navigator.of(context).pushNamed(AuthScreen.routeName);
    } else {
      setState(() {
        _activeIndex++;
      });
      _carouselController.nextPage(
        duration: Duration(
          milliseconds: 200,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalVariables.green,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Carousel Slider
            CarouselSlider(
              carouselController: _carouselController,
              items: [
                FirstWelcome(),
                SecondWelcome(),
                ThirdWelcome(),
              ],
              options: CarouselOptions(
                viewportFraction: 1,
                enlargeStrategy: CenterPageEnlargeStrategy.zoom,
                height: 430,
                reverse: false,
                initialPage: 0,
                enableInfiniteScroll: false,
                enlargeCenterPage: false,
                autoPlay: false,
                autoPlayInterval: Duration(seconds: 3),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                scrollDirection: Axis.horizontal,
                onPageChanged: (index, reason) => setState(
                  () {
                    _activeIndex = index;
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Indicator
            _buildIndicator(),

            const SizedBox(height: 12),

            SizedBox(
              width: 216,
              height: 40,
              child: ElevatedButton(
                onPressed: _handleIndex,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                ),
                child: Text(
                  _activeIndex == 0
                      ? 'Get Started'
                      : _activeIndex == 1
                          ? 'Next'
                          : 'Ready',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: GlobalVariables.green,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
