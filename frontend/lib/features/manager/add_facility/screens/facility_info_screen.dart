import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_button.dart';
import 'package:frontend/common/widgets/custom_textfield.dart';
import 'package:frontend/common/widgets/drop_down_button.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/add_facility/screens/manager_info_screen.dart';
import 'package:frontend/features/manager/add_facility/screens/map_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class FacilityInfo extends StatefulWidget {
  static const String routeName = '/facilityInfo';
  const FacilityInfo({Key? key}) : super(key: key);

  @override
  State<FacilityInfo> createState() => _FacilityInfoState();
}

class _FacilityInfoState extends State<FacilityInfo> {
  final _facilityNameController = TextEditingController();
  final _streetNameController = TextEditingController();

  List<String> provinceList = [
    'TP Hồ Chí Minh',
    'Hà Nội',
    'Đà Nẵng',
    'Cần Thơ',
    'Đồng Nai',
  ];
  List<String> districtList = [
    'TP Hồ Chí Minh',
    'Hà Nội',
    'Đà Nẵng',
    'Cần Thơ',
    'Đồng Nai',
  ];
  List<String> wardList = [
    'TP Hồ Chí Minh',
    'Hà Nội',
    'Đà Nẵng',
    'Cần Thơ',
    'Đồng Nai',
  ];

  void _navigateToManagerInfoScreen() {
    Navigator.of(context).pushNamed(ManagerInfo.routeName);
  }

  void _navigateToMapScreen() {
    Navigator.of(context).pushNamed(MapScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: GlobalVariables.green,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Facility infomation',
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
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => {},
                            child: Container(
                              color: GlobalVariables.lightGrey,
                              height: 240,
                              child: Center(
                                child: Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: GlobalVariables.darkGrey,
                                  size: 120,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 124,
                            padding:
                                EdgeInsets.only(top: 16, bottom: 16, right: 12),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 16),
                                    child: GestureDetector(
                                      onTap: () {
                                        // Handle button tap
                                        print('Button tapped!');
                                      },
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: GlobalVariables.lightGrey,
                                          borderRadius: BorderRadius.circular(
                                              10), // Adjust border radius here
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.add_photo_alternate_outlined,
                                            color: GlobalVariables.darkGrey,
                                            size: 60,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _InterRegular14(
                                  "Badminton facility Name *",
                                  GlobalVariables.darkGrey,
                                  1,
                                ),
                                CustomTextfield(
                                  controller: _facilityNameController,
                                  hintText: 'Facility name',
                                  validator: (facilityName) {
                                    if (facilityName == null ||
                                        facilityName.isEmpty) {
                                      return 'Please enter your facility name.';
                                    }
                                    return null;
                                  },
                                ),
                                _InterRegular14(
                                  "Select a location on the map *",
                                  GlobalVariables.darkGrey,
                                  1,
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: double.maxFinite,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _navigateToMapScreen,
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          side: BorderSide(
                                            color: GlobalVariables.green,
                                            width: 1,
                                          ),
                                        ),
                                        backgroundColor: GlobalVariables.white,
                                        elevation: 0,
                                      ),
                                      child: Icon(
                                        Icons.add_location_alt_outlined,
                                        color: GlobalVariables.green,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: _isValidateText(false),
                                ),
                                _InterRegular14(
                                  "Province *",
                                  GlobalVariables.darkGrey,
                                  1,
                                ),
                                CustomDropdownButton(
                                  items: provinceList,
                                  initialSelectedItem: provinceList[0],
                                  onChanged: (selectedItem) {
                                    print('Selected item: $selectedItem');
                                  },
                                ),
                                _InterRegular14(
                                  "District *",
                                  GlobalVariables.darkGrey,
                                  1,
                                ),
                                CustomDropdownButton(
                                  items: districtList,
                                  initialSelectedItem: districtList[0],
                                  onChanged: (selectedItem) {
                                    print('Selected item: $selectedItem');
                                  },
                                ),
                                _InterRegular14(
                                  "Ward *",
                                  GlobalVariables.darkGrey,
                                  1,
                                ),
                                CustomDropdownButton(
                                  items: wardList,
                                  initialSelectedItem: wardList[0],
                                  onChanged: (selectedItem) {
                                    print('Selected item: $selectedItem');
                                  },
                                ),
                                _InterRegular14(
                                  "Street/ House number",
                                  GlobalVariables.darkGrey,
                                  1,
                                ),
                                CustomTextfield(
                                  controller: _streetNameController,
                                  hintText: 'Street/ House number',
                                  validator: (streetName) {
                                    if (streetName == null ||
                                        streetName.isEmpty) {
                                      return '';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: CustomButton(
                        onTap: _navigateToManagerInfoScreen,
                        buttonText: 'Next',
                        borderColor: GlobalVariables.green,
                        fillColor: GlobalVariables.green,
                        textColor: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _InterRegular14(String text, Color color, int maxLines) {
    return Container(
      padding: EdgeInsets.only(
        bottom: 8,
        top: 12,
      ),
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

  Widget _isValidateText(bool isValidateText) {
    String text = isValidateText ? 'Verified' : 'Not verified';
    Color textColor = isValidateText ? Colors.green : Colors.red;
    return Text(
      text,
      textAlign: TextAlign.start,
      style: GoogleFonts.inter(
        fontSize: 10,
        color: textColor,
        decoration: TextDecoration.underline,
        decorationColor: textColor,
        textStyle: const TextStyle(
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
