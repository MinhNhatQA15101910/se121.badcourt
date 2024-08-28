import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/common/widgets/custom_button.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/constants/utils.dart';
import 'package:frontend/features/manager/add_facility/providers/new_facility_provider.dart';
import 'package:frontend/features/manager/add_facility/screens/contracts_screen.dart';
import 'package:frontend/common/widgets/custom_form_field.dart';
import 'package:frontend/features/manager/add_facility/widgets/image_picker_button.dart';
import 'package:frontend/common/widgets/label_display.dart';
import 'package:frontend/features/manager/add_facility/widgets/multiple_image_picker_button.dart';
import 'package:frontend/features/manager/add_facility/widgets/selected_images.dart';
import 'package:frontend/models/facility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

enum ImagePickerOption {
  frontCitizenId,
  backCitizenId,
  frontBankCard,
  backBankCard,
  licenses,
}

class ManagerInfoScreen extends StatefulWidget {
  static const String routeName = '/manager/manager-info';
  const ManagerInfoScreen({super.key});

  @override
  State<ManagerInfoScreen> createState() => _ManagerInfoScreenState();
}

class _ManagerInfoScreenState extends State<ManagerInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _citizenIdController = TextEditingController();
  File? _frontCitizenIdImage;
  File? _backCitizenIdImage;
  File? _frontBankCardImage;
  File? _backBankCardImage;
  List<File>? _licenseImages = [];

  void _navigateToContractScreen() {
    Navigator.of(context).pushNamed(ContractScreen.routeName);
  }

  Future<void> _pickImage(ImagePickerOption option) async {
    // Add license images
    if (option == ImagePickerOption.licenses) {
      final List<File> images = await pickMultipleImages();
      if (images.isNotEmpty) {
        setState(() {
          _licenseImages!.addAll(images);
        });
      }
      return;
    }

    final File? image = await pickOneImage();
    if (image != null) {
      switch (option) {
        // Add front citizen ID image
        case ImagePickerOption.frontCitizenId:
          setState(() {
            _frontCitizenIdImage = image;
          });
          break;
        // Add back citizen ID image
        case ImagePickerOption.backCitizenId:
          setState(() {
            _backCitizenIdImage = image;
          });
          break;
        // Add front bank card image
        case ImagePickerOption.frontBankCard:
          setState(() {
            _frontBankCardImage = image;
          });
          break;
        // Add back bank card image
        case ImagePickerOption.backBankCard:
          setState(() {
            _backBankCardImage = image;
          });
          break;
        default:
          break;
      }
    }
  }

  void _handleNextButton() {
    if (_formKey.currentState!.validate()) {
      if (_frontCitizenIdImage == null ||
          _backCitizenIdImage == null ||
          _frontBankCardImage == null ||
          _backBankCardImage == null ||
          _licenseImages == null ||
          _licenseImages!.isEmpty) {
        IconSnackBar.show(
          context,
          label: 'Please add all required images.',
          snackBarType: SnackBarType.fail,
        );
        return;
      }

      final newFacilityProvider = Provider.of<NewFacilityProvider>(
        context,
        listen: false,
      );

      newFacilityProvider.setFrontCitizenIdImage(_frontCitizenIdImage!);
      newFacilityProvider.setBackCitizenIdImage(_backCitizenIdImage!);
      newFacilityProvider.setFrontBankCardImage(_frontBankCardImage!);
      newFacilityProvider.setBackBankCardImage(_backBankCardImage!);
      newFacilityProvider.setLicenseImages(_licenseImages!);

      ManagerInfo managerInfo =
          newFacilityProvider.newFacility.managerInfo.copyWith(
        fullName: _fullNameController.text,
        email: _emailController.text,
        phoneNumber: _phoneNumberController.text,
        citizenId: _citizenIdController.text,
      );

      Facility facility = newFacilityProvider.newFacility.copyWith(
        managerInfo: managerInfo,
      );

      newFacilityProvider.setFacility(facility);

      _navigateToContractScreen();
    }
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
                'Manager information',
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
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Manager full name text
                                  CustomFormField(
                                    controller: _fullNameController,
                                    label: 'Manager full name',
                                    hintText: 'Manager full name',
                                    validator: (fullName) {
                                      if (fullName == null ||
                                          fullName.isEmpty) {
                                        return 'Please enter your Manager full name.';
                                      }
                                      return null;
                                    },
                                  ),

                                  // Email text
                                  CustomFormField(
                                    controller: _emailController,
                                    label: 'Email',
                                    hintText: 'Email',
                                    validator: (email) {
                                      if (email == null || email.isEmpty) {
                                        return 'Please enter your email.';
                                      }
                                      return null;
                                    },
                                    isEmail: true,
                                  ),

                                  // Phone number text
                                  CustomFormField(
                                    controller: _phoneNumberController,
                                    label: 'Phone number',
                                    isPhoneNumber: true,
                                    hintText: 'Phone number',
                                    validator: (phoneNumber) {
                                      if (phoneNumber == null ||
                                          phoneNumber.isEmpty) {
                                        return 'Please enter your phone number.';
                                      } else if (phoneNumber.length != 10) {
                                        return 'Phone number must be 10 digits.';
                                      }
                                      return null;
                                    },
                                  ),

                                  // Citizen ID text
                                  CustomFormField(
                                    controller: _citizenIdController,
                                    label: 'Citizen ID',
                                    hintText: 'Citizen ID',
                                    isNumber: true,
                                    validator: (citizenId) {
                                      if (citizenId == null ||
                                          citizenId.isEmpty) {
                                        return 'Please enter your citizen ID.';
                                      } else if (citizenId.length != 12) {
                                        return 'Citizen ID must be 12 digits.';
                                      }
                                      return null;
                                    },
                                  ),

                                  LabelDisplay(
                                    label:
                                        'Photos of citizen identification card (Includes front and back)',
                                    isRequired: true,
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        ImagePickerButton(
                                          onTap: () => _pickImage(
                                            ImagePickerOption.frontCitizenId,
                                          ),
                                          image: _frontCitizenIdImage,
                                          onClear: () {
                                            setState(() {
                                              _frontCitizenIdImage = null;
                                            });
                                          },
                                        ),
                                        SizedBox(width: 8),
                                        ImagePickerButton(
                                          image: _backCitizenIdImage,
                                          onTap: () => _pickImage(
                                            ImagePickerOption.backCitizenId,
                                          ),
                                          onClear: () {
                                            setState(() {
                                              _backCitizenIdImage = null;
                                            });
                                          },
                                        )
                                      ],
                                    ),
                                  ),

                                  LabelDisplay(
                                    label:
                                        'Photos of bank card (Includes front and back)',
                                    isRequired: true,
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        ImagePickerButton(
                                          image: _frontBankCardImage,
                                          onTap: () => _pickImage(
                                            ImagePickerOption.frontBankCard,
                                          ),
                                          onClear: () {
                                            setState(() {
                                              _frontBankCardImage = null;
                                            });
                                          },
                                        ),
                                        SizedBox(width: 8),
                                        ImagePickerButton(
                                          image: _backBankCardImage,
                                          onTap: () => _pickImage(
                                            ImagePickerOption.backBankCard,
                                          ),
                                          onClear: () {
                                            setState(() {
                                              _backBankCardImage = null;
                                            });
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                  LabelDisplay(
                                    label:
                                        'Photos of business license (Maximum 10 photos)',
                                    isRequired: true,
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        if (_licenseImages != null)
                                          SelectedImages(
                                            images: _licenseImages!,
                                          ),
                                        MultipleImagePickerButton(
                                          onTap: () => _pickImage(
                                            ImagePickerOption.licenses,
                                          ),
                                        ),
                                      ],
                                    ),
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
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: CustomButton(
                      onTap: _handleNextButton,
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
}
