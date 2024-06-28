import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_button.dart';
import 'package:frontend/common/widgets/custom_textfield.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/constants/utils.dart';
import 'package:frontend/features/manager/add_facility/models/detail_address.dart';
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
  final _wardNameController = TextEditingController();
  final _districtNameController = TextEditingController();
  final _provinceNameController = TextEditingController();
  List<File>? _images = [];
  List<String>? _facilityInfo = []; //just demo
  DetailAddress? _selectedAddress;

  void _navigateToManagerInfoScreen() {
    Navigator.of(context).pushNamed(ManagerInfo.routeName);
  }

  void _navigateToMapScreen() async {
    final DetailAddress? selectedAddress = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapScreen()),
    );

    if (selectedAddress != null) {
      setState(() {
        _selectedAddress = selectedAddress;
        _provinceNameController.text = _selectedAddress!.city;
        _districtNameController.text = _selectedAddress!.district;
        _wardNameController.text = _selectedAddress!.ward;
        _streetNameController.text = _selectedAddress!.address;
      });
    }
  }

  void _selectMultipleImages() async {
    List<File>? res =
        await pickMultipleImages(); // Assuming pickMultipleImages() returns List<File>?
    setState(() {
      if (res.isNotEmpty) {
        _images?.addAll(res); // Assuming _images is List<File>
      }
    });
  }

  void _clearImage(int index, bool isFile) {
    setState(() {
      if (isFile) {
        _images!.removeAt(index);
      } else {
        _facilityInfo!.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                          //Pick first image
                          GestureDetector(
                            onTap: _selectMultipleImages,
                            child: Container(
                              color: GlobalVariables.lightGrey,
                              child: AspectRatio(
                                aspectRatio: 4 / 3,
                                child: (_images != null && _images!.isNotEmpty)
                                    ? Stack(
                                        children: [
                                          Image.file(
                                            _images!.first,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: IconButton(
                                              icon: Icon(Icons.clear,
                                                  color: Colors.white),
                                              onPressed: () {
                                                _clearImage(0, true);
                                              },
                                            ),
                                          ),
                                        ],
                                      )
                                    : (_facilityInfo != null &&
                                            _facilityInfo!.isNotEmpty)
                                        ? Stack(
                                            children: [
                                              Image.network(
                                                _facilityInfo!.first,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                              ),
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: IconButton(
                                                  icon: Icon(Icons.clear,
                                                      color: Colors.white),
                                                  onPressed: () {
                                                    _clearImage(0, false);
                                                  },
                                                ),
                                              ),
                                            ],
                                          )
                                        : Center(
                                            child: Icon(
                                              Icons
                                                  .add_photo_alternate_outlined,
                                              color: GlobalVariables.darkGrey,
                                              size: 120,
                                            ),
                                          ),
                              ),
                            ),
                          ),

                          //Pick others image
                          Container(
                            height: 124,
                            padding:
                                EdgeInsets.only(top: 16, bottom: 16, right: 12),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  if (_images != null)
                                    for (int i = 1; i < _images!.length; i++)
                                      Padding(
                                        padding: EdgeInsets.only(left: 16),
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                image: DecorationImage(
                                                  image: FileImage(_images![i]),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: GestureDetector(
                                                onTap: () {
                                                  _clearImage(i, true);
                                                },
                                                child: Icon(
                                                  Icons.clear,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  for (int i = 1;
                                      i < _facilityInfo!.length;
                                      i++)
                                    Padding(
                                      padding: EdgeInsets.only(left: 16),
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    _facilityInfo![i]),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: GestureDetector(
                                              onTap: () {
                                                _clearImage(i, false);
                                              },
                                              child: Icon(
                                                Icons.clear,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 16),
                                    child: GestureDetector(
                                      onTap: _selectMultipleImages,
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: GlobalVariables.lightGrey,
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                  child: (_selectedAddress?.lat != 0.0 &&
                                          _selectedAddress?.lng != 0.0)
                                      ? _isValidateText(true)
                                      : _isValidateText(false),
                                ),
                                _InterRegular14(
                                  "Province *",
                                  GlobalVariables.darkGrey,
                                  1,
                                ),
                                CustomTextfield(
                                  controller: _provinceNameController,
                                  hintText: 'Province',
                                  validator: (streetName) {
                                    if (streetName == null ||
                                        streetName.isEmpty) {
                                      return '';
                                    }
                                    return null;
                                  },
                                ),
                                _InterRegular14(
                                  "District *",
                                  GlobalVariables.darkGrey,
                                  1,
                                ),
                                CustomTextfield(
                                  controller: _districtNameController,
                                  hintText: 'District',
                                  validator: (streetName) {
                                    if (streetName == null ||
                                        streetName.isEmpty) {
                                      return '';
                                    }
                                    return null;
                                  },
                                ),
                                _InterRegular14(
                                  "Ward *",
                                  GlobalVariables.darkGrey,
                                  1,
                                ),
                                CustomTextfield(
                                  controller: _wardNameController,
                                  hintText: 'Ward',
                                  validator: (streetName) {
                                    if (streetName == null ||
                                        streetName.isEmpty) {
                                      return '';
                                    }
                                    return null;
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
                          ),
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
                        onTap: () {
                          GlobalVariables.facilityImages = _images;
                          GlobalVariables.facilityName =
                              _facilityNameController.text;
                          _navigateToManagerInfoScreen();
                        },
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
