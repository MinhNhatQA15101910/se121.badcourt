import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/constants/utils.dart';
import 'package:frontend/features/manager/add_facility/models/detail_address.dart';
import 'package:frontend/features/manager/add_facility/providers/new_facility_provider.dart';
import 'package:frontend/features/manager/add_facility/services/add_facility_service.dart';
import 'package:frontend/features/manager/intro_manager/screens/intro_manager_screen.dart';
import 'package:frontend/common/widgets/custom_form_field.dart';
import 'package:frontend/common/widgets/label_display.dart';
import 'package:frontend/features/manager/add_facility/widgets/location_selector.dart';
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

class FacilityRegistrationScreen extends StatefulWidget {
  static const String routeName = '/manager/unified-facility-registration';
  final Facility? existingFacility;

  const FacilityRegistrationScreen({super.key, this.existingFacility});

  @override
  State<FacilityRegistrationScreen> createState() =>
      _FacilityRegistrationScreenState();
}

class _FacilityRegistrationScreenState extends State<FacilityRegistrationScreen>
    with TickerProviderStateMixin {
  // Services
  final _addFacilityService = AddFacilityService();

  // Form key
  final _formKey = GlobalKey<FormState>();

  // Facility Info Controllers
  final _facilityNameController = TextEditingController();
  final _streetNameController = TextEditingController();
  final _wardNameController = TextEditingController();
  final _districtNameController = TextEditingController();
  final _provinceNameController = TextEditingController();
  final _facebookUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _policyController = TextEditingController();

  // Manager Info Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _citizenIdController = TextEditingController();

  // Facility Images
  DetailAddress? _selectedAddress;
  List<File> _facilityImages = [];
  List<String> _existingFacilityImageUrls = [];

  // Manager Document Images
  File? _frontCitizenIdImage;
  File? _backCitizenIdImage;
  File? _frontBankCardImage;
  File? _backBankCardImage;
  List<File>? _licenseImages = [];

  // Existing manager images from server
  String? _existingFrontCitizenIdUrl;
  String? _existingBackCitizenIdUrl;
  String? _existingFrontBankCardUrl;
  String? _existingBackBankCardUrl;
  List<String> _existingLicenseUrls = [];

  // Contract Screen State
  final ScrollController _scrollController = ScrollController();
  bool _checkBoxValue = false;
  bool _isLoading = false;
  bool _hasScrolledToBottom = false;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _animationController.forward();

    _scrollController.addListener(_scrollListener);

    // Initialize provider based on mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NewFacilityProvider>(context, listen: false);
      if (widget.existingFacility != null) {
        provider.initializeForEdit(widget.existingFacility!);
        _populateFieldsFromFacility(widget.existingFacility!);
      } else {
        provider.initializeForCreate();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();

    // Facility controllers
    _facilityNameController.dispose();
    _streetNameController.dispose();
    _wardNameController.dispose();
    _districtNameController.dispose();
    _provinceNameController.dispose();
    _facebookUrlController.dispose();
    _descriptionController.dispose();
    _policyController.dispose();

    // Manager controllers
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _citizenIdController.dispose();

    super.dispose();
  }

  void _populateFieldsFromFacility(Facility facility) {
    // Facility info
    _facilityNameController.text = facility.facilityName;
    _facebookUrlController.text = facility.facebookUrl;
    _descriptionController.text = facility.description;
    _policyController.text = facility.policy;

    // Parse address
    final addressParts = facility.detailAddress.split(', ');
    if (addressParts.length >= 4) {
      _streetNameController.text = addressParts[0];
      _wardNameController.text = addressParts[1];
      _districtNameController.text = addressParts[2];
      _provinceNameController.text = addressParts[3];
    }

    // Set existing facility images
    _existingFacilityImageUrls =
        facility.facilityImages.map((img) => img.url).toList();

    // Manager info
    _populateFieldsFromManagerInfo(facility.managerInfo);

    setState(() {});
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

  void _scrollListener() {
    // Check if scrolled to terms section (approximately 80% of content)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_hasScrolledToBottom) {
        setState(() {
          _hasScrolledToBottom = true;
        });
      }
    }
  }

  void _changeAddress(DetailAddress detailAddress) {
    setState(() {
      _selectedAddress = detailAddress;
      _provinceNameController.text = detailAddress.city;
      _districtNameController.text = detailAddress.district;
      _wardNameController.text = detailAddress.ward;
      _streetNameController.text = detailAddress.hsNum.isEmpty
          ? detailAddress.name
          : '${detailAddress.hsNum} ${detailAddress.street}';
    });
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
            _existingFrontCitizenIdUrl = null;
          });
          break;
        case ImagePickerOption.backCitizenId:
          setState(() {
            _backCitizenIdImage = image;
            _existingBackCitizenIdUrl = null;
          });
          break;
        case ImagePickerOption.frontBankCard:
          setState(() {
            _frontBankCardImage = image;
            _existingFrontBankCardUrl = null;
          });
          break;
        case ImagePickerOption.backBankCard:
          setState(() {
            _backBankCardImage = image;
            _existingBackBankCardUrl = null;
          });
          break;
        default:
          break;
      }
    }
  }

  void _selectMultipleFacilityImages() async {
    if (_facilityImages.length + _existingFacilityImageUrls.length >= 10) {
      _showValidationSnackBar('Maximum 10 images allowed');
      return;
    }

    List<File>? res = await pickMultipleImages();
    if (res.isNotEmpty) {
      setState(() {
        int remainingSlots =
            10 - (_facilityImages.length + _existingFacilityImageUrls.length);
        _facilityImages.addAll(res.take(remainingSlots));
      });
    }
  }

  bool _hasRequiredManagerImages() {
    final provider = Provider.of<NewFacilityProvider>(context, listen: false);
    final bool isEditMode = provider.isEditMode;

    if (!isEditMode) {
      return _frontCitizenIdImage != null &&
          _backCitizenIdImage != null &&
          _frontBankCardImage != null &&
          _backBankCardImage != null &&
          _licenseImages != null &&
          _licenseImages!.isNotEmpty;
    } else {
      bool hasFrontCitizen =
          _frontCitizenIdImage != null || _existingFrontCitizenIdUrl != null;
      bool hasBackCitizen =
          _backCitizenIdImage != null || _existingBackCitizenIdUrl != null;
      bool hasFrontBank =
          _frontBankCardImage != null || _existingFrontBankCardUrl != null;
      bool hasBackBank =
          _backBankCardImage != null || _existingBackBankCardUrl != null;
      bool hasLicense =
          (_licenseImages != null && _licenseImages!.isNotEmpty) ||
              _existingLicenseUrls.isNotEmpty;

      return hasFrontCitizen &&
          hasBackCitizen &&
          hasFrontBank &&
          hasBackBank &&
          hasLicense;
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

  void _clearFacilityImage(int index, bool isFile) {
    setState(() {
      if (isFile) {
        _facilityImages.removeAt(index);
      } else {
        _existingFacilityImageUrls.removeAt(index);
      }
    });
  }

  void _showValidationSnackBar(String message) {
    IconSnackBar.show(
      context,
      label: message,
      snackBarType: SnackBarType.fail,
    );
  }

  Future<void> _submitFacility() async {
    if (!_formKey.currentState!.validate()) {
      _showValidationSnackBar('Please fill in all required fields correctly.');
      return;
    }

    // Validate facility images
    if (_facilityImages.isEmpty && _existingFacilityImageUrls.isEmpty) {
      _showValidationSnackBar('Please add at least one facility image');
      return;
    }

    // Validate location
    if (_selectedAddress == null && widget.existingFacility == null) {
      _showValidationSnackBar('Please select a location on the map');
      return;
    }

    // Validate manager images
    if (!_hasRequiredManagerImages()) {
      _showValidationSnackBar('Please add all required manager documents.');
      return;
    }

    // Validate terms acceptance
    if (!_checkBoxValue) {
      _showValidationSnackBar(
          'Please accept the terms and conditions to continue.');
      return;
    }

    if (!_hasScrolledToBottom) {
      _showValidationSnackBar('Please read through all terms and conditions.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<NewFacilityProvider>(context, listen: false);

      // Save facility info
      double lat = _selectedAddress?.lng ?? widget.existingFacility?.lat ?? 0.0;
      double lon = _selectedAddress?.lat ?? widget.existingFacility?.lon ?? 0.0;
      String province = _selectedAddress?.city ??
          widget.existingFacility?.province ??
          _provinceNameController.text;

      Facility facility = provider.newFacility.copyWith(
        facilityName: _facilityNameController.text.trim(),
        facebookUrl: _facebookUrlController.text.trim(),
        description: _descriptionController.text.trim(),
        policy: _policyController.text.trim(),
        detailAddress:
            '${_streetNameController.text}, ${_wardNameController.text}, ${_districtNameController.text}, ${_provinceNameController.text}',
        province: province,
        lat: lat,
        lon: lon,
      );

      provider.setFacility(facility);
      provider.setFacilityImageUrls(_facilityImages);

      // Save manager info
      if (_frontCitizenIdImage != null) {
        provider.setFrontCitizenIdImage(_frontCitizenIdImage!);
      }
      if (_backCitizenIdImage != null) {
        provider.setBackCitizenIdImage(_backCitizenIdImage!);
      }
      if (_frontBankCardImage != null) {
        provider.setFrontBankCardImage(_frontBankCardImage!);
      }
      if (_backBankCardImage != null) {
        provider.setBackBankCardImage(_backBankCardImage!);
      }
      if (_licenseImages != null && _licenseImages!.isNotEmpty) {
        provider.setLicenseImages(_licenseImages!);
      }

      ManagerInfo managerInfo = provider.newFacility.managerInfo.copyWith(
        fullName: _fullNameController.text,
        email: _emailController.text,
        phoneNumber: _phoneNumberController.text,
        citizenId: _citizenIdController.text,
      );

      facility = provider.newFacility.copyWith(
        managerInfo: managerInfo,
      );

      provider.setFacility(facility);

      // Submit to server
      if (provider.isEditMode && provider.originalFacility != null) {
        await _addFacilityService.updateFacility(
          context: context,
          facility: provider.originalFacility!,
        );
      } else {
        await _addFacilityService.registerFacility(context: context);
      }

      Navigator.of(context).pushNamedAndRemoveUntil(
        IntroManagerScreen.routeName,
        (route) => false,
      );
    } catch (e) {
      _showValidationSnackBar('Operation failed. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Validation methods
  String? _validateFacilityName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Facility name is required';
    }
    if (value.trim().length < 3) {
      return 'Facility name must be at least 3 characters';
    }
    if (value.trim().length > 100) {
      return 'Facility name must not exceed 100 characters';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    if (value.trim().length < 20) {
      return 'Description must be at least 20 characters';
    }
    if (value.trim().length > 1000) {
      return 'Description must not exceed 1000 characters';
    }
    return null;
  }

  String? _validatePolicy(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Policy is required';
    }
    if (value.trim().length < 10) {
      return 'Policy must be at least 10 characters';
    }
    if (value.trim().length > 500) {
      return 'Policy must not exceed 500 characters';
    }
    return null;
  }

  String? _validateFacebookUrl(String? value) {
    if (value != null && value.isNotEmpty) {
      final urlRegex = RegExp(
        r'^https?:\/\/(www\.)?facebook\.com\/[a-zA-Z0-9.]+\/?$',
        caseSensitive: false,
      );
      if (!urlRegex.hasMatch(value)) {
        return 'Please enter a valid Facebook URL';
      }
    }
    return null;
  }

  Widget _buildFacilityImageSection() {
    return Container(
      margin: const EdgeInsets.all(16),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: GlobalVariables.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.photo_library_outlined,
                    color: GlobalVariables.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Facility Images *',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Text(
                        'Add up to 10 high-quality images',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: GlobalVariables.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_facilityImages.length + _existingFacilityImageUrls.length}/10',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: GlobalVariables.green,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main image display
          GestureDetector(
            onTap: _selectMultipleFacilityImages,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: (_facilityImages.isNotEmpty)
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _facilityImages.first,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.white, size: 20),
                                onPressed: () => _clearFacilityImage(0, true),
                              ),
                            ),
                          ),
                        ],
                      )
                    : (_existingFacilityImageUrls.isNotEmpty)
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _existingFacilityImageUrls.first,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.white, size: 20),
                                    onPressed: () =>
                                        _clearFacilityImage(0, false),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: Colors.grey.shade400,
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to add images',
                                  style: GoogleFonts.inter(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
              ),
            ),
          ),

          // Additional images thumbnail view
          if (_facilityImages.length > 1 ||
              _existingFacilityImageUrls.length > 1)
            Container(
              height: 80,
              margin: const EdgeInsets.all(16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (_facilityImages.length > 1
                        ? _facilityImages.length - 1
                        : 0) +
                    (_existingFacilityImageUrls.length > 1
                        ? _existingFacilityImageUrls.length - 1
                        : 0) +
                    1,
                itemBuilder: (context, index) {
                  if (index <
                      (_facilityImages.length > 1
                          ? _facilityImages.length - 1
                          : 0)) {
                    return _buildFacilityThumbnail(
                        _facilityImages[index + 1], index + 1, true);
                  } else if (index <
                      (_facilityImages.length > 1
                              ? _facilityImages.length - 1
                              : 0) +
                          (_existingFacilityImageUrls.length > 1
                              ? _existingFacilityImageUrls.length - 1
                              : 0)) {
                    int urlIndex = index -
                        (_facilityImages.length > 1
                            ? _facilityImages.length - 1
                            : 0) +
                        1;
                    return _buildFacilityNetworkThumbnail(
                        _existingFacilityImageUrls[urlIndex], urlIndex);
                  } else {
                    return _buildFacilityAddButton();
                  }
                },
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildFacilityAddButton(),
            ),
        ],
      ),
    );
  }

  Widget _buildFacilityThumbnail(File image, int index, bool isFile) {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              image,
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
                onTap: () => _clearFacilityImage(index, isFile),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityNetworkThumbnail(String imageUrl, int index) {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
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
                onTap: () => _clearFacilityImage(index, false),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityAddButton() {
    return GestureDetector(
      onTap: _selectMultipleFacilityImages,
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
        child: Icon(
          Icons.add,
          color: GlobalVariables.green,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildFacilityBasicInfoSection() {
    return Container(
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GlobalVariables.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: GlobalVariables.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Facility Information',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CustomFormField(
            controller: _facilityNameController,
            label: 'Badminton Facility Name *',
            hintText: 'Enter facility name',
            validator: _validateFacilityName,
          ),
          LocationSelector(
            selectedAddress: _selectedAddress,
            onAddressSelected: _changeAddress,
            lat: widget.existingFacility?.lat ?? 0.0,
            lng: widget.existingFacility?.lon ?? 0.0,
          ),
          CustomFormField(
            controller: _provinceNameController,
            label: 'Province *',
            hintText: 'Province',
            readOnly: true,
            validator: (value) =>
                value?.isEmpty == true ? 'Please select location' : null,
          ),
          CustomFormField(
            controller: _districtNameController,
            label: 'District *',
            hintText: 'District',
            readOnly: true,
            validator: (value) =>
                value?.isEmpty == true ? 'Please select location' : null,
          ),
          CustomFormField(
            controller: _wardNameController,
            label: 'Ward *',
            hintText: 'Ward',
            readOnly: true,
            validator: (value) =>
                value?.isEmpty == true ? 'Please select location' : null,
          ),
          CustomFormField(
            controller: _streetNameController,
            label: 'Street / House Number *',
            hintText: 'Enter street address',
            validator: (value) => value?.trim().isEmpty == true
                ? 'Street address is required'
                : null,
          ),
          CustomFormField(
            controller: _facebookUrlController,
            label: 'Facebook URL (Optional)',
            hintText: 'https://facebook.com/yourpage',
            validator: _validateFacebookUrl,
          ),
          CustomFormField(
            controller: _descriptionController,
            label: 'Facility Description *',
            hintText: 'Describe your facility, amenities, and features...',
            maxLines: 5,
            validator: _validateDescription,
          ),
          CustomFormField(
            controller: _policyController,
            label: 'Facility Policy *',
            hintText: 'Enter your facility rules and policies...',
            maxLines: 5,
            validator: _validatePolicy,
          ),
        ],
      ),
    );
  }

  Widget _buildManagerInfoSection() {
    final provider = Provider.of<NewFacilityProvider>(context);
    final bool isEditMode = provider.isEditMode;

    return Container(
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
                  onPickImage: () =>
                      _pickImage(ImagePickerOption.frontCitizenId),
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
                  onPickImage: () =>
                      _pickImage(ImagePickerOption.backCitizenId),
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
                  onPickImage: () =>
                      _pickImage(ImagePickerOption.frontBankCard),
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
        ],
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
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
                        newImage != null || existingImageUrl != null
                            ? 'Replace'
                            : 'Add',
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
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

  Widget _buildTermsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
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
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: GlobalVariables.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: GlobalVariables.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Terms & Conditions',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Text(
                        'Please read carefully before proceeding',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _hasScrolledToBottom
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _hasScrolledToBottom
                            ? Icons.check_circle
                            : Icons.info_outline,
                        color:
                            _hasScrolledToBottom ? Colors.green : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _hasScrolledToBottom ? 'Read' : 'Reading',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _hasScrolledToBottom
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Article 1
          _buildTermsContentSection(
            'ARTICLE 1: INTERPRETATION',
            'In this Agreement, the following terms will be interpreted as:\n\n'
                '1.1. Terms of Service: means terms and conditions which are applicable to Seller, Buyer as making a transaction on Bad Court Platform.\n\n'
                '1.2. Order: means confirmation of transaction between Buyer and the parties of making order of Products on Bad Court Platform.\n\n'
                '1.3. Cash Merchant: means a Seller who only receives payment in cash.\n\n'
                '1.4. Bad Court Policy: means criteria, policies, rules, regulations, standards and/or any other provisions which Bad Court may issue from time to time to control the management, operation of Bad Court Platform and/or provide E-commerce service for Seller and/or Buyer.\n\n'
                '1.5. Agreement: means this Agreement includes all Appendices, guidelines, regulations and all amendments or additions to relevant instruments.\n\n'
                '1.6. Working day: means days (excluding Saturday and Sunday) that Banks open to work in Viet Nam.\n\n'
                '1.7. Buyers or Users: means person, individual who buys Product on Bad Court Platform.\n\n'
                '1.8. Bad Court Merchant: means Seller who uses Bad Court Merchant Wallet account to manage, control and request payment of Purchase amount from Bad Court.',
            Icons.article_outlined,
          ),

          const Divider(height: 1),

          // Partnership Terms
          _buildTermsContentSection(
            'PARTNERSHIP TERMS',
            'I acknowledge that I have thoroughly read and consent to all the terms and conditions outlined above. I hereby agree to enter into a contract with Bad Court with the following fees to become an official partner:\n\n'
                '• Commission Fee of 10%: Bad Court will deduct a commission fee of 10% for each successful booking and pay the remaining amount to the Partner.\n\n'
                '• Within 7 days from the successful registration of the store on the system, the Partner needs to complete the signing of the cooperation agreement with Bad Court.\n\n'
                '• If the deadline is missed, the registration request will be canceled. In this case, the Partner please send an email to merchantsupport@badcourt.vn for assistance.\n\n'
                '• By continuing with the registration, the Partner agrees to bear all legal responsibilities related to listing prohibited items on Bad Court.',
            Icons.handshake_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildTermsContentSection(
      String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GlobalVariables.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: GlobalVariables.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: GlobalVariables.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _checkBoxValue ? GlobalVariables.green : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: _checkBoxValue,
                  onChanged: _hasScrolledToBottom
                      ? (newValue) {
                          setState(() {
                            _checkBoxValue = newValue ?? false;
                          });
                        }
                      : null,
                  activeColor: GlobalVariables.green,
                  checkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agreement Confirmation',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'I have read and agree to all terms and conditions, including the 10% commission fee and partnership requirements.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!_hasScrolledToBottom)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber,
                      color: Colors.orange.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please scroll through all terms before accepting',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final provider = Provider.of<NewFacilityProvider>(context);

    return Container(
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: (_checkBoxValue && _hasScrolledToBottom && !_isLoading)
                ? [
                    BoxShadow(
                      color: GlobalVariables.green.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: (_checkBoxValue && _hasScrolledToBottom && !_isLoading)
                  ? _submitFacility
                  : null,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.check_circle_outline, size: 24),
              label: Text(
                _isLoading
                    ? 'Processing...'
                    : provider.isEditMode
                        ? 'Update Facility'
                        : 'Register Facility',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    (_checkBoxValue && _hasScrolledToBottom && !_isLoading)
                        ? GlobalVariables.green
                        : Colors.grey.shade400,
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NewFacilityProvider>(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: GlobalVariables.green,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  provider.isEditMode
                      ? 'Edit Facility Registration'
                      : 'Facility Registration',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                    color: GlobalVariables.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Facility Images Section
                      _buildFacilityImageSection(),

                      // Facility Basic Info Section
                      _buildFacilityBasicInfoSection(),

                      // Manager Info Section
                      _buildManagerInfoSection(),

                      // Terms & Conditions Section
                      _buildTermsSection(),

                      // Agreement Section
                      _buildAgreementSection(),

                      const SizedBox(height: 100), // Space for button
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildSubmitButton(),
    );
  }
}
