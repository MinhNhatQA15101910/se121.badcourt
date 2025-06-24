import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/constants/utils.dart';
import 'package:frontend/features/manager/add_facility/providers/new_facility_provider.dart';
import 'package:frontend/features/manager/add_facility/screens/contracts_screen.dart';
import 'package:frontend/common/widgets/custom_form_field.dart';
import 'package:frontend/common/widgets/label_display.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/models/manager_info.dart';
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

class _ManagerInfoScreenState extends State<ManagerInfoScreen>
    with TickerProviderStateMixin {
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

  // Existing images from server
  String? _existingFrontCitizenIdUrl;
  String? _existingBackCitizenIdUrl;
  String? _existingFrontBankCardUrl;
  String? _existingBackBankCardUrl;
  List<String> _existingLicenseUrls = [];

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();

    // Populate fields if in edit mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NewFacilityProvider>(context, listen: false);
      if (provider.isEditMode && provider.originalFacility != null) {
        _populateFieldsFromManagerInfo(provider.originalFacility!.managerInfo);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _citizenIdController.dispose();
    super.dispose();
  }

  void _populateFieldsFromManagerInfo(ManagerInfo managerInfo) {
    _fullNameController.text = managerInfo.fullName;
    _emailController.text = managerInfo.email;
    _phoneNumberController.text = managerInfo.phoneNumber;
    _citizenIdController.text = managerInfo.citizenId;
    
    // Load existing image URLs
    _existingFrontCitizenIdUrl = managerInfo.citizenImageFront.url.isNotEmpty 
        ? managerInfo.citizenImageFront.url 
        : null;
    _existingBackCitizenIdUrl = managerInfo.citizenImageBack.url.isNotEmpty 
        ? managerInfo.citizenImageBack.url 
        : null;
    _existingFrontBankCardUrl = managerInfo.bankCardFront.url.isNotEmpty 
        ? managerInfo.bankCardFront.url 
        : null;
    _existingBackBankCardUrl = managerInfo.bankCardBack.url.isNotEmpty 
        ? managerInfo.bankCardBack.url 
        : null;
    _existingLicenseUrls = managerInfo.businessLicenseImages
        .where((img) => img.url.isNotEmpty)
        .map((img) => img.url)
        .toList();
    
    setState(() {});
  }

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
        case ImagePickerOption.frontCitizenId:
          setState(() {
            _frontCitizenIdImage = image;
            _existingFrontCitizenIdUrl = null; // Clear existing when new image selected
          });
          break;
        case ImagePickerOption.backCitizenId:
          setState(() {
            _backCitizenIdImage = image;
            _existingBackCitizenIdUrl = null; // Clear existing when new image selected
          });
          break;
        case ImagePickerOption.frontBankCard:
          setState(() {
            _frontBankCardImage = image;
            _existingFrontBankCardUrl = null; // Clear existing when new image selected
          });
          break;
        case ImagePickerOption.backBankCard:
          setState(() {
            _backBankCardImage = image;
            _existingBackBankCardUrl = null; // Clear existing when new image selected
          });
          break;
        default:
          break;
      }
    }
  }

  bool _hasRequiredImages() {
    final provider = Provider.of<NewFacilityProvider>(context, listen: false);
    final bool isEditMode = provider.isEditMode;

    if (!isEditMode) {
      // In create mode, all new images are required
      return _frontCitizenIdImage != null &&
             _backCitizenIdImage != null &&
             _frontBankCardImage != null &&
             _backBankCardImage != null &&
             _licenseImages != null &&
             _licenseImages!.isNotEmpty;
    } else {
      // In edit mode, either existing or new images are required
      bool hasFrontCitizen = _frontCitizenIdImage != null || _existingFrontCitizenIdUrl != null;
      bool hasBackCitizen = _backCitizenIdImage != null || _existingBackCitizenIdUrl != null;
      bool hasFrontBank = _frontBankCardImage != null || _existingFrontBankCardUrl != null;
      bool hasBackBank = _backBankCardImage != null || _existingBackBankCardUrl != null;
      bool hasLicense = (_licenseImages != null && _licenseImages!.isNotEmpty) || _existingLicenseUrls.isNotEmpty;

      return hasFrontCitizen && hasBackCitizen && hasFrontBank && hasBackBank && hasLicense;
    }
  }

  void _clearExistingImage(String type) {
    setState(() {
      switch (type) {
        case 'frontCitizen':
          _existingFrontCitizenIdUrl = null;
          break;
        case 'backCitizen':
          _existingBackCitizenIdUrl = null;
          break;
        case 'frontBank':
          _existingFrontBankCardUrl = null;
          break;
        case 'backBank':
          _existingBackBankCardUrl = null;
          break;
      }
    });
  }

  void _clearExistingLicenseImage(int index) {
    setState(() {
      if (index < _existingLicenseUrls.length) {
        _existingLicenseUrls.removeAt(index);
      }
    });
  }

  void _handleNextButton() {
    if (_formKey.currentState!.validate()) {
      if (!_hasRequiredImages()) {
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

      // Set images only if new ones are selected
      if (_frontCitizenIdImage != null) {
        newFacilityProvider.setFrontCitizenIdImage(_frontCitizenIdImage!);
      }
      if (_backCitizenIdImage != null) {
        newFacilityProvider.setBackCitizenIdImage(_backCitizenIdImage!);
      }
      if (_frontBankCardImage != null) {
        newFacilityProvider.setFrontBankCardImage(_frontBankCardImage!);
      }
      if (_backBankCardImage != null) {
        newFacilityProvider.setBackBankCardImage(_backBankCardImage!);
      }
      if (_licenseImages != null && _licenseImages!.isNotEmpty) {
        newFacilityProvider.setLicenseImages(_licenseImages!);
      }

      ManagerInfo managerInfo = newFacilityProvider.newFacility.managerInfo.copyWith(
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

  Widget _buildHeader() {
    final provider = Provider.of<NewFacilityProvider>(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GlobalVariables.green,
            GlobalVariables.green.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.isEditMode ? 'Edit Manager Info' : 'Manager Information',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.isEditMode 
                        ? 'Update manager details and documents'
                        : 'Step 2 of 3 - Manager details and documents',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerWithExisting({
    required String label,
    required File? newImage,
    required String? existingImageUrl,
    required VoidCallback onPickImage,
    required VoidCallback onClearNew,
    required VoidCallback onClearExisting,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelDisplay(
          label: label,
          isRequired: true,
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Show existing image if available
              if (existingImageUrl != null)
                Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          existingImageUrl,
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.error,
                                color: Colors.grey.shade600,
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: GestureDetector(
                            onTap: onClearExisting,
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Current',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Show new image if selected
              if (newImage != null)
                Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          newImage,
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: GestureDetector(
                            onTap: onClearNew,
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'New',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Add button
              GestureDetector(
                onTap: onPickImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: GlobalVariables.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: GlobalVariables.green.withOpacity(0.3),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        color: GlobalVariables.green,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        newImage != null || existingImageUrl != null ? 'Replace' : 'Add',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: GlobalVariables.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLicenseImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelDisplay(
          label: 'Photos of business license (Maximum 10 photos) *',
          isRequired: true,
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Show existing license images
              ...List.generate(_existingLicenseUrls.length, (index) {
                return Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _existingLicenseUrls[index],
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.error,
                                color: Colors.grey.shade600,
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: GestureDetector(
                            onTap: () => _clearExistingLicenseImage(index),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        left: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            'Current',
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              
              // Show new license images
              if (_licenseImages != null && _licenseImages!.isNotEmpty)
                ...List.generate(_licenseImages!.length, (index) {
                  return Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _licenseImages![index],
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _licenseImages!.removeAt(index);
                                });
                              },
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          left: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              'New',
                              style: GoogleFonts.inter(
                                fontSize: 8,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              
              // Add button for license images
              GestureDetector(
                onTap: () => _pickImage(ImagePickerOption.licenses),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: GlobalVariables.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: GlobalVariables.green.withOpacity(0.3),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: GlobalVariables.green,
                        size: 20,
                      ),
                      Text(
                        'Add',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: GlobalVariables.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NewFacilityProvider>(context);
    final bool isEditMode = provider.isEditMode;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Form(
                    key: _formKey,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header section
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: GlobalVariables.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.person_outline,
                                  color: GlobalVariables.green,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Manager Information',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Manager full name text
                          CustomFormField(
                            controller: _fullNameController,
                            label: 'Manager full name *',
                            hintText: 'Enter manager full name',
                            validator: (fullName) {
                              if (fullName == null || fullName.trim().isEmpty) {
                                return 'Please enter manager full name.';
                              }
                              if (fullName.trim().length < 2) {
                                return 'Name must be at least 2 characters.';
                              }
                              return null;
                            },
                          ),

                          // Email text
                          CustomFormField(
                            controller: _emailController,
                            label: 'Email *',
                            hintText: 'Enter email address',
                            validator: (email) {
                              if (email == null || email.trim().isEmpty) {
                                return 'Please enter email address.';
                              }
                              final emailRegex = RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                              );
                              if (!emailRegex.hasMatch(email.trim())) {
                                return 'Please enter a valid email address.';
                              }
                              return null;
                            },
                            isEmail: true,
                          ),

                          // Phone number text
                          CustomFormField(
                            controller: _phoneNumberController,
                            label: 'Phone number *',
                            isPhoneNumber: true,
                            hintText: 'Enter phone number',
                            validator: (phoneNumber) {
                              if (phoneNumber == null || phoneNumber.trim().isEmpty) {
                                return 'Please enter phone number.';
                              } else if (phoneNumber.trim().length != 10) {
                                return 'Phone number must be 10 digits.';
                              }
                              return null;
                            },
                          ),

                          // Citizen ID text
                          CustomFormField(
                            controller: _citizenIdController,
                            label: 'Citizen ID *',
                            hintText: 'Enter citizen ID',
                            isNumber: true,
                            validator: (citizenId) {
                              if (citizenId == null || citizenId.trim().isEmpty) {
                                return 'Please enter citizen ID.';
                              } else if (citizenId.trim().length != 12) {
                                return 'Citizen ID must be 12 digits.';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Document upload section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.upload_file_outlined,
                                      color: GlobalVariables.green,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Document Upload',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                if (isEditMode)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'Current images are shown with green labels. Upload new images to replace them.',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),

                                // Citizen ID images
                                _buildImagePickerWithExisting(
                                  label: 'Citizen ID - Front *',
                                  newImage: _frontCitizenIdImage,
                                  existingImageUrl: _existingFrontCitizenIdUrl,
                                  onPickImage: () => _pickImage(ImagePickerOption.frontCitizenId),
                                  onClearNew: () {
                                    setState(() {
                                      _frontCitizenIdImage = null;
                                    });
                                  },
                                  onClearExisting: () => _clearExistingImage('frontCitizen'),
                                ),

                                _buildImagePickerWithExisting(
                                  label: 'Citizen ID - Back *',
                                  newImage: _backCitizenIdImage,
                                  existingImageUrl: _existingBackCitizenIdUrl,
                                  onPickImage: () => _pickImage(ImagePickerOption.backCitizenId),
                                  onClearNew: () {
                                    setState(() {
                                      _backCitizenIdImage = null;
                                    });
                                  },
                                  onClearExisting: () => _clearExistingImage('backCitizen'),
                                ),

                                // Bank card images
                                _buildImagePickerWithExisting(
                                  label: 'Bank Card - Front *',
                                  newImage: _frontBankCardImage,
                                  existingImageUrl: _existingFrontBankCardUrl,
                                  onPickImage: () => _pickImage(ImagePickerOption.frontBankCard),
                                  onClearNew: () {
                                    setState(() {
                                      _frontBankCardImage = null;
                                    });
                                  },
                                  onClearExisting: () => _clearExistingImage('frontBank'),
                                ),

                                _buildImagePickerWithExisting(
                                  label: 'Bank Card - Back *',
                                  newImage: _backBankCardImage,
                                  existingImageUrl: _existingBackBankCardUrl,
                                  onPickImage: () => _pickImage(ImagePickerOption.backBankCard),
                                  onClearNew: () {
                                    setState(() {
                                      _backBankCardImage = null;
                                    });
                                  },
                                  onClearExisting: () => _clearExistingImage('backBank'),
                                ),

                                // Business license images
                                _buildLicenseImagesSection(),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _handleNextButton,
              icon: const Icon(Icons.arrow_forward, size: 24),
              label: Text(
                'Next Step',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: GlobalVariables.green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}