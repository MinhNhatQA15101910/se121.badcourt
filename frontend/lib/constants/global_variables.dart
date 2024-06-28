import 'package:flutter/material.dart';

String uri = 'http://10.45.134.83:3000';

class GlobalVariables {
  //Define Scales
  static double screenWidth = 0;
  static double screenHeight = 0;

  static void init(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    screenWidth = screenSize.width;
    screenHeight = screenSize.height;
  }

  // Colors
  static const Color black = Color(0xFF000000);
  static const Color blackGrey = Color(0xFF27272A);
  static const Color darkGrey = Color(0xFF808089);
  static const Color pinputColor = Color(0xFF545454);
  static const Color grey = Color(0xFFEBEBF0);
  static const Color lightGrey = Color(0xFFF2F4F5);
  static const Color defaultColor = Color(0xFFFAFAFA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkRed = Color(0xFFBF1D28);
  static const Color lightRed = Color(0xFFFFDBDE);
  static const Color red = Color(0xFFFF424F);
  static const Color darkBlue = Color(0xFF0D5BB5);
  static const Color lightBlue = Color(0xFFDBEEFF);
  static const Color darkYellow = Color(0xFFCC8100);
  static const Color yellow = Color(0xFFFFBA49);
  static const Color lightYellow = Color(0xFFFFF5C7);
  static const Color darkGreen = Color(0xFF198155);
  static const Color lightGreen = Color(0xFFDAEFDE);
  static const Color green = Color(0xFF23C16B);
}
