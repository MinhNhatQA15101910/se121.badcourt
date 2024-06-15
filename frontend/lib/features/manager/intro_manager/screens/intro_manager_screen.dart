import 'package:frontend/common/widgets/custom_buttom.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/intro_manager/widgets/facility_item.dart';
import 'package:frontend/features/manager/manager_bottom_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class IntroManagerScreen extends StatefulWidget {
  static const String routeName = '/manager-intro';
  const IntroManagerScreen({super.key});

  @override
  State<IntroManagerScreen> createState() => _IntroManagerScreenState();
}

class _IntroManagerScreenState extends State<IntroManagerScreen> {
  void _navigateToManagerBottomBar() {
    Navigator.of(context).pushNamed(ManagerBottomBar.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalVariables.green,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 12,
            ),
            FacilityItem(
              onTap: _navigateToManagerBottomBar,
            ),
            FacilityItem(
              onTap: _navigateToManagerBottomBar,
            ),
            Container(
              width: 200,
              child: CustomButton(
                onTap: () => {},
                buttonText: 'Register a facility',
                borderColor: GlobalVariables.white,
                fillColor: GlobalVariables.white,
                textColor: GlobalVariables.green,
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {},
                child: RichText(
                  textAlign: TextAlign.right,
                  text: TextSpan(
                    text: 'View ',
                    style: GoogleFonts.inter(
                      color: GlobalVariables.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                    children: [
                      TextSpan(
                        text: 'facility registration instructions',
                        style: GoogleFonts.inter(
                          color: GlobalVariables.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 12,
            ),
          ],
        ),
      ),
    );
  }
}
