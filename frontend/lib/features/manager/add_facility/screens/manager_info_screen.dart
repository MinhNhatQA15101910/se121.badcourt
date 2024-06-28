import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/common/widgets/custom_button.dart';
import 'package:frontend/common/widgets/custom_textfield.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/constants/utils.dart';
import 'package:frontend/features/manager/add_facility/screens/contracts_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class ManagerInfo extends StatefulWidget {
  const ManagerInfo({Key? key}) : super(key: key);
  static const String routeName = '/managerInfo';

  @override
  State<ManagerInfo> createState() => _ManagerInfoState();
}

class _ManagerInfoState extends State<ManagerInfo> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _citizenIdController = TextEditingController();
  File? _frontCitizenIdImage;
  File? _backCitizenIdImage;
  File? _frontBankCardImage;
  File? _backBankCardImage;
  List<File>? _lisenceImages = [];

  void _navigateToContractScreen() {
    Navigator.of(context).pushNamed(ContractScreen.routeName);
  }

  Future<void> _pickFrontCitizenIdImage() async {
    final File? image = await pickOneImage();
    if (image != null) {
      setState(() {
        _frontCitizenIdImage = image;
      });
    }
  }

  Future<void> _pickBackCitizenIdImage() async {
    final File? image = await pickOneImage();
    if (image != null) {
      setState(() {
        _backCitizenIdImage = image;
      });
    }
  }

  Future<void> _pickFrontBankCardImage() async {
    final File? image = await pickOneImage();
    if (image != null) {
      setState(() {
        _frontBankCardImage = image;
      });
    }
  }

  Future<void> _pickBackBankCardImage() async {
    final File? image = await pickOneImage();
    if (image != null) {
      setState(() {
        _backBankCardImage = image;
      });
    }
  }

  Future<void> _pickLisenceImages() async {
    final List<File> images = await pickMultipleImages();
    if (images.isNotEmpty) {
      setState(() {
        _lisenceImages!.addAll(images);
      });
    }
  }

  Widget _buildImagePickerButton({
    required VoidCallback onTap,
    File? image,
    VoidCallback? onClear,
  }) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: GlobalVariables.lightGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: image == null
                ? Center(
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      color: GlobalVariables.darkGrey,
                      size: 36,
                    ),
                  )
                : Image.file(image, fit: BoxFit.cover),
          ),
        ),
        if (image != null && onClear != null)
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onClear,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.clear,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMultipleImagePickerButton() {
    return GestureDetector(
      onTap: _pickLisenceImages,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: GlobalVariables.lightGrey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Icon(
            Icons.add_photo_alternate_outlined,
            color: GlobalVariables.darkGrey,
            size: 36,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedImages(List<File> images) {
    return Row(
      children: images
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Stack(
                children: [
                  Image.file(
                    entry.value,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          images.removeAt(entry.key);
                        });
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.clear,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  void _handleNextButton() {
    if (_formKey.currentState!.validate()) {
      if (_frontCitizenIdImage == null ||
          _backCitizenIdImage == null ||
          _frontBankCardImage == null ||
          _backBankCardImage == null ||
          _lisenceImages == null ||
          _lisenceImages!.isEmpty) {
        IconSnackBar.show(
          context,
          label: 'Please add all required images.',
          snackBarType: SnackBarType.fail,
        );
        return;
      }

      GlobalVariables.managerName = _fullNameController.text;
      GlobalVariables.manageEmail = _emailController.text;
      GlobalVariables.managePhoneNumber = _phoneNumberController.text;
      GlobalVariables.manageCitizenId = _citizenIdController.text;
      GlobalVariables.frontCitizenIdImage = _frontCitizenIdImage!;
      GlobalVariables.backCitizenIdImage = _backCitizenIdImage!;
      GlobalVariables.frontBankCardImage = _frontBankCardImage!;
      GlobalVariables.backBankCardImage = _backBankCardImage!;
      GlobalVariables.lisenceImages = _lisenceImages!;

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
                                  _InterRegular14(
                                    "Manager full name *",
                                    GlobalVariables.darkGrey,
                                    1,
                                  ),
                                  CustomTextfield(
                                    controller: _fullNameController,
                                    hintText: 'Manager full name',
                                    validator: (fullName) {
                                      if (fullName == null ||
                                          fullName.isEmpty) {
                                        return 'Please enter your Manager full name.';
                                      }
                                      return null;
                                    },
                                  ),
                                  _InterRegular14(
                                    "Email *",
                                    GlobalVariables.darkGrey,
                                    1,
                                  ),
                                  CustomTextfield(
                                    controller: _emailController,
                                    hintText: 'Email',
                                    validator: (email) {
                                      if (email == null || email.isEmpty) {
                                        return 'Please enter your email.';
                                      }
                                      return null;
                                    },
                                    isEmail: true,
                                  ),
                                  _InterRegular14(
                                    "Phone number *",
                                    GlobalVariables.darkGrey,
                                    1,
                                  ),
                                  CustomTextfield(
                                    controller: _phoneNumberController,
                                    hintText: 'Phone number',
                                    validator: (phoneNumber) {
                                      if (phoneNumber == null ||
                                          phoneNumber.isEmpty) {
                                        return 'Please enter your phone number.';
                                      }
                                      return null;
                                    },
                                  ),
                                  _InterRegular14(
                                    "Citizen identification ID *",
                                    GlobalVariables.darkGrey,
                                    1,
                                  ),
                                  CustomTextfield(
                                    controller: _citizenIdController,
                                    hintText: 'Citizen identification ID',
                                    validator: (citizenId) {
                                      if (citizenId == null ||
                                          citizenId.isEmpty) {
                                        return 'Please enter your citizen identification ID.';
                                      }
                                      return null;
                                    },
                                  ),
                                  _InterRegular14(
                                    "Photos of citizen identification card (Includes front and back) *",
                                    GlobalVariables.darkGrey,
                                    2,
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        _buildImagePickerButton(
                                          onTap: _pickFrontCitizenIdImage,
                                          image: _frontCitizenIdImage,
                                          onClear: () {
                                            setState(() {
                                              _frontCitizenIdImage = null;
                                            });
                                          },
                                        ),
                                        SizedBox(width: 8),
                                        _buildImagePickerButton(
                                          onTap: _pickBackCitizenIdImage,
                                          image: _backCitizenIdImage,
                                          onClear: () {
                                            setState(() {
                                              _backCitizenIdImage = null;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  _InterRegular14(
                                    "Photos of bank card (Includes front and back) *",
                                    GlobalVariables.darkGrey,
                                    2,
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        _buildImagePickerButton(
                                          onTap: _pickFrontBankCardImage,
                                          image: _frontBankCardImage,
                                          onClear: () {
                                            setState(() {
                                              _frontBankCardImage = null;
                                            });
                                          },
                                        ),
                                        SizedBox(width: 8),
                                        _buildImagePickerButton(
                                          onTap: _pickBackBankCardImage,
                                          image: _backBankCardImage,
                                          onClear: () {
                                            setState(() {
                                              _backBankCardImage = null;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  _InterRegular14(
                                    "Photos of business license (Maximum 10 photos) *",
                                    GlobalVariables.darkGrey,
                                    2,
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        if (_lisenceImages != null)
                                          _buildSelectedImages(_lisenceImages!),
                                        _buildMultipleImagePickerButton(),
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
}
