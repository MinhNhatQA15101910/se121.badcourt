import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/auth/screens/auth_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WelcomeScreen extends StatefulWidget {
  static const String routeName = '/welcome';
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _controller = CarouselController();

  var _activeIndex = 0;

  void _animateToSlide(int index) => _controller.animateToPage(index);

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
      _controller.nextPage(
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
              carouselController: _controller,
              items: [
                // Carousel item 1
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome to',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: GlobalVariables.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    RichText(
                      text: TextSpan(
                        text: 'BAD',
                        style: GoogleFonts.alfaSlabOne(
                          color: GlobalVariables.yellow,
                          fontSize: 24,
                        ),
                        children: [
                          TextSpan(
                            text: 'COURT',
                            style: GoogleFonts.alfaSlabOne(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          )
                        ],
                      ),
                    ),
                    Image.asset(
                      'assets/images/img-welcome-1.png',
                      fit: BoxFit.cover,
                    ),
                  ],
                ),

                // Carousel item 2
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/img-welcome-2.png',
                      fit: BoxFit.cover,
                    ),
                    Text(
                      'Let\'s start journey with',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: GlobalVariables.white,
                      ),
                    ),
                    Text(
                      'BadCourt',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: GlobalVariables.white,
                      ),
                    ),
                    Text(
                      'BadCourt provides a variety of',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: GlobalVariables.white,
                      ),
                    ),
                    Text(
                      'badminton training court options.',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: GlobalVariables.white,
                      ),
                    ),
                  ],
                ),

                // Carousel item 3
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/img-welcome-3.png',
                      fit: BoxFit.cover,
                    ),
                    Text(
                      'BadCourt make you feel',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: GlobalVariables.white,
                      ),
                    ),
                    Text(
                      'convenient',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: GlobalVariables.white,
                      ),
                    ),
                    Text(
                      'BadCourt provides comfort and',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: GlobalVariables.white,
                      ),
                    ),
                    Text(
                      'convenience, making you feel at ease.',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: GlobalVariables.white,
                      ),
                    ),
                  ],
                ),
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
              width: 200,
              height: 40,
              child: ElevatedButton(
                onPressed: _handleIndex,
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
