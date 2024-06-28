import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/features/manager/add_facility/models/detail_address.dart';

String uri = 'http://192.168.2.237:3000';

String vietmap_string_key =
    'https://maps.vietmap.vn/api/maps/light/styles.json?apikey=506862bb03a3d71632bdeb7674a3625328cb7e5a9b011841';
String vietmap_api_key = '506862bb03a3d71632bdeb7674a3625328cb7e5a9b011841';

class GlobalVariables {
  //Define Scales
  static double screenWidth = 0;
  static double screenHeight = 0;

  static void init(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    screenWidth = screenSize.width;
    screenHeight = screenSize.height;
  }

  static DetailAddress detailAddress = DetailAddress(
    display: '',
    name: '',
    hsNum: '',
    street: '',
    address: '',
    cityId: 0,
    city: '',
    districtId: 0,
    district: '',
    wardId: 0,
    ward: '',
    lat: 0.0,
    lng: 0.0,
  );

  static List<File>? facilityImages = [];
  static File frontCitizenIdImage = File('');
  static File backCitizenIdImage = File('');
  static File frontBankCardImage = File('');
  static File backBankCardImage = File('');
  static List<File>? lisenceImages = [];
  static String facilityName = "";
  static String managerName = "";
  static String manageEmail = "";
  static String managePhoneNumber = "";
  static String manageCitizenId = "";

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
