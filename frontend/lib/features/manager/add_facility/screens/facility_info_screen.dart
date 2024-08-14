import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/common/widgets/custom_button.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/constants/utils.dart';
import 'package:frontend/features/manager/add_facility/providers/address_provider.dart';
import 'package:frontend/features/manager/add_facility/providers/new_facility_provider.dart';
import 'package:frontend/features/manager/add_facility/screens/manager_info_screen.dart';
import 'package:frontend/features/manager/add_facility/widgets/facility_info_form_field.dart';
import 'package:frontend/features/manager/add_facility/widgets/location_selector.dart';
import 'package:frontend/models/facility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FacilityInfo extends StatefulWidget {
  static const String routeName = 'manager/facility-info';
  const FacilityInfo({super.key});

  @override
  State<FacilityInfo> createState() => _FacilityInfoState();
}

class _FacilityInfoState extends State<FacilityInfo> {
  final _formKey = GlobalKey<FormState>();
  final _facilityNameController = TextEditingController();
  final _streetNameController = TextEditingController();
  final _wardNameController = TextEditingController();
  final _districtNameController = TextEditingController();
  final _provinceNameController = TextEditingController();
  final _facebookUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _policyController = TextEditingController();

  List<File>? _images = [];
  List<String>? _facilityInfo = [];

  void _navigateToManagerInfoScreen() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pushNamed(ManagerInfoScreen.routeName);
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

  void _saveFacilityInfo() {
    if (_formKey.currentState!.validate()) {
      if (_images == null || _images!.isEmpty) {
        IconSnackBar.show(
          context,
          label: 'Please select you image!',
          snackBarType: SnackBarType.fail,
        );
      } else {
        final newFacilityProvider = Provider.of<NewFacilityProvider>(
          context,
          listen: false,
        );

        Facility facility = newFacilityProvider.newFacility.copyWith(
          name: _facilityNameController.text,
          facebookUrl: _facebookUrlController.text,
          description: _descriptionController.text,
          policy: _policyController.text,
        );
        newFacilityProvider.setFacility(facility);
        newFacilityProvider.setFacilityImageUrls(_images!);

        _navigateToManagerInfoScreen();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = context.watch<AddressProvider>();

    _provinceNameController.text = addressProvider.address.city;
    _districtNameController.text = addressProvider.address.district;
    _wardNameController.text = addressProvider.address.ward;
    _streetNameController.text = addressProvider.address.address;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: GlobalVariables.green,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Facility information',
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Pick first image
                            GestureDetector(
                              onTap: _selectMultipleImages,
                              child: Container(
                                color: GlobalVariables.lightGrey,
                                child: AspectRatio(
                                  aspectRatio: 4 / 3,
                                  child: (_images != null &&
                                          _images!.isNotEmpty)
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
                                                icon: Icon(
                                                  Icons.clear,
                                                  color: Colors.white,
                                                ),
                                                onPressed: () =>
                                                    _clearImage(0, true),
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

                            // Pick others image
                            Container(
                              height: 124,
                              padding: EdgeInsets.only(
                                top: 16,
                                bottom: 16,
                                right: 12,
                              ),
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
                                                    image:
                                                        FileImage(_images![i]),
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
                                              Icons
                                                  .add_photo_alternate_outlined,
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
                                  // Badminton facility Name text
                                  FacilityInfoFormField(
                                    controller: _facilityNameController,
                                    label: 'Badminton facility Name',
                                    hintText: 'Facility name',
                                    validator: (facilityName) {
                                      if (facilityName == null ||
                                          facilityName.isEmpty) {
                                        return 'Please enter your facility name.';
                                      }
                                      return null;
                                    },
                                  ),

                                  // Select a location on the map text
                                  LocationSelector(
                                    selectedAddress: addressProvider.address,
                                  ),

                                  // Province text
                                  FacilityInfoFormField(
                                    controller: _provinceNameController,
                                    label: 'Province',
                                    hintText: 'Province',
                                    readOnly: true,
                                    validator: (provinceName) {
                                      if (provinceName == null ||
                                          provinceName.isEmpty) {
                                        return 'Please enter the province.';
                                      }
                                      return null;
                                    },
                                  ),

                                  // District text
                                  FacilityInfoFormField(
                                    controller: _districtNameController,
                                    label: 'District',
                                    hintText: 'District',
                                    readOnly: true,
                                    validator: (districtName) {
                                      if (districtName == null ||
                                          districtName.isEmpty) {
                                        return 'Please enter the district.';
                                      }
                                      return null;
                                    },
                                  ),

                                  // Ward text
                                  FacilityInfoFormField(
                                    controller: _wardNameController,
                                    label: 'Ward',
                                    hintText: 'Ward',
                                    readOnly: true,
                                    validator: (wardName) {
                                      if (wardName == null ||
                                          wardName.isEmpty) {
                                        return 'Please enter the ward.';
                                      }
                                      return null;
                                    },
                                  ),

                                  // Street / House number text
                                  FacilityInfoFormField(
                                    controller: _streetNameController,
                                    label: 'Street / House number',
                                    hintText: 'Street / House number',
                                    validator: (streetName) {
                                      if (streetName == null ||
                                          streetName.isEmpty) {
                                        return 'Please enter street / house number.';
                                      }
                                      return null;
                                    },
                                  ),

                                  // Facebook url
                                  FacilityInfoFormField(
                                    controller: _facebookUrlController,
                                    label: 'Facebook url',
                                    hintText: 'Facebook url',
                                  ),

                                  // Facility description text
                                  FacilityInfoFormField(
                                    controller: _descriptionController,
                                    label: 'Facility description',
                                    hintText: 'Facility description',
                                    maxLines: 5,
                                    validator: (facilityDescription) {
                                      if (facilityDescription == null ||
                                          facilityDescription.isEmpty) {
                                        return 'Please enter facility description.';
                                      }
                                      return null;
                                    },
                                  ),

                                  // Facility policy text
                                  FacilityInfoFormField(
                                    controller: _policyController,
                                    label: 'Facility policy',
                                    hintText: 'Facility policy',
                                    maxLines: 5,
                                    validator: (facilityPolicy) {
                                      if (facilityPolicy == null ||
                                          facilityPolicy.isEmpty) {
                                        return 'Please enter facility policy.';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 12),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: CustomButton(
                      onTap: _saveFacilityInfo,
                      buttonText: 'Next',
                      borderColor: GlobalVariables.green,
                      fillColor: GlobalVariables.green,
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _facilityNameController.dispose();
    _streetNameController.dispose();
    _wardNameController.dispose();
    _districtNameController.dispose();
    _provinceNameController.dispose();
    _facebookUrlController.dispose();
    _descriptionController.dispose();
    _policyController.dispose();
    super.dispose();
  }
}
