import 'package:flutter/material.dart';
import 'package:frontend/features/manager/add_facility/providers/address_provider.dart';
import 'package:frontend/features/manager/add_facility/providers/new_facility_provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/checkout_provider.dart';
import 'package:frontend/providers/filter_provider.dart';
import 'package:frontend/providers/group_provider.dart';
import 'package:frontend/providers/manager/current_facility_provider.dart';
import 'package:frontend/providers/message_hub_provider.dart';
import 'package:frontend/providers/sort_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

String ipconfig = '192.168.1.107';
String uri = 'http://${ipconfig}:5000';
String signalrUri = 'http://${ipconfig}:7000';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(
    create: (context) => AuthProvider(),
  ),
  ChangeNotifierProvider(
    create: (context) => UserProvider(),
  ),
  ChangeNotifierProvider(
    create: (context) => FilterProvider(),
  ),
  ChangeNotifierProvider(
    create: (context) => SortProvider(),
  ),
  ChangeNotifierProvider(
    create: (context) => CheckoutProvider(),
  ),
  ChangeNotifierProvider(
    create: (context) => NewFacilityProvider(),
  ),
  ChangeNotifierProvider(
    create: (context) => CurrentFacilityProvider(),
  ),
  ChangeNotifierProvider(
    create: (context) => AddressProvider(),
  ),
  ChangeNotifierProvider(create: (context) => GroupProvider()),
  ChangeNotifierProvider(create: (context) => MessageHubProvider())
];

class GlobalVariables {
  // Define Scales
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
