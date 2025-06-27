import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/constants/utils.dart';
import 'package:frontend/features/manager/add_facility/models/detail_address.dart';
import 'package:frontend/features/manager/add_facility/providers/new_facility_provider.dart';
import 'package:frontend/features/manager/add_facility/screens/manager_info_screen.dart';
import 'package:frontend/common/widgets/custom_form_field.dart';
import 'package:frontend/features/manager/add_facility/widgets/location_selector.dart';
import 'package:frontend/models/facility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FacilityInfo extends StatefulWidget {
  static const String routeName = 'manager/facility-info';
  final Facility? existingFacility; // Optional parameter for edit mode
  
  const FacilityInfo({super.key, this.existingFacility});

  @override
  State<FacilityInfo> createState() => _FacilityInfoState();
}

class _FacilityInfoState extends State<FacilityInfo>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _facilityNameController = TextEditingController();
  final _streetNameController = TextEditingController();
  final _wardNameController = TextEditingController();
  final _districtNameController = TextEditingController();
  final _provinceNameController = TextEditingController();
  final _facebookUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _policyController = TextEditingController();

  DetailAddress? _selectedAddress;
  List<File> _images = [];
  List<String> _facilityInfo = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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

  void _populateFieldsFromFacility(Facility facility) {
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
    _facilityInfo = facility.facilityImages.map((img) => img.url).toList();
    
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
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

  void _clearImage(int index, bool isFile) {
    setState(() {
      if (isFile) {
        _images.removeAt(index);
      } else {
        _facilityInfo.removeAt(index);
      }
    });
  }

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

  void _navigateToManagerInfoScreen() {
    if (_formKey.currentState!.validate()) {
      if (_images.isEmpty && _facilityInfo.isEmpty) {
        _showValidationSnackBar('Please add at least one facility image');
        return;
      }
      if (_selectedAddress == null && widget.existingFacility == null) {
        _showValidationSnackBar('Please select a location on the map');
        return;
      }
      Navigator.of(context).pushNamed(ManagerInfoScreen.routeName);
    }
  }

  void _showValidationSnackBar(String message) {
    IconSnackBar.show(
      context,
      label: message,
      snackBarType: SnackBarType.fail,
    );
  }

  void _saveFacilityInfo() {
    if (_formKey.currentState!.validate()) {
      if (_images.isEmpty && _facilityInfo.isEmpty) {
        _showValidationSnackBar('Please add at least one facility image');
        return;
      }
      if (_selectedAddress == null && widget.existingFacility == null) {
        _showValidationSnackBar('Please select a location on the map');
        return;
      }

      final newFacilityProvider = Provider.of<NewFacilityProvider>(
        context,
        listen: false,
      );

      // Use existing coordinates if no new address selected
      double lat = _selectedAddress?.lng ?? widget.existingFacility?.lat ?? 0.0;
      double lon = _selectedAddress?.lat ?? widget.existingFacility?.lon ?? 0.0;
      String province = _selectedAddress?.city ?? widget.existingFacility?.province ?? _provinceNameController.text;

      Facility facility = newFacilityProvider.newFacility.copyWith(
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

      newFacilityProvider.setFacility(facility);
      newFacilityProvider.setFacilityImageUrls(_images);

      _navigateToManagerInfoScreen();
    }
  }

  void _selectMultipleImages() async {
    if (_images.length + _facilityInfo.length >= 10) {
      _showValidationSnackBar('Maximum 10 images allowed');
      return;
    }

    List<File>? res = await pickMultipleImages();
    if (res.isNotEmpty) {
      setState(() {
        int remainingSlots = 10 - (_images.length + _facilityInfo.length);
        _images.addAll(res.take(remainingSlots));
      });
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
                    provider.isEditMode ? 'Edit Facility' : 'Facility Information',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.isEditMode 
                        ? 'Update facility details'
                        : 'Step 1 of 3 - Basic facility details',
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

  // ... (rest of the widget methods remain the same as in the original file)
  // I'll include the key parts that need modification

  Widget _buildImageSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
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
                          'Facility Images',
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: GlobalVariables.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_images.length + _facilityInfo.length}/10',
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
            
            // Main image display logic (handles both new files and existing URLs)
            GestureDetector(
              onTap: _selectMultipleImages,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: (_images.isNotEmpty)
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _images.first,
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
                                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                  onPressed: () => _clearImage(0, true),
                                ),
                              ),
                            ),
                          ],
                        )
                      : (_facilityInfo.isNotEmpty)
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    _facilityInfo.first,
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
                                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                      onPressed: () => _clearImage(0, false),
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
            if (_images.length > 1 || _facilityInfo.length > 1)
              Container(
                height: 80,
                margin: const EdgeInsets.all(16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: (_images.length - 1) + (_facilityInfo.length > 1 ? _facilityInfo.length - 1 : 0) + 1,
                  itemBuilder: (context, index) {
                    if (index < _images.length - 1) {
                      return _buildThumbnail(_images[index + 1], index + 1, true);
                    } else if (index < (_images.length - 1) + (_facilityInfo.length > 1 ? _facilityInfo.length - 1 : 0)) {
                      int facilityIndex = index - (_images.length - 1) + 1;
                      return _buildNetworkThumbnail(_facilityInfo[facilityIndex], facilityIndex);
                    } else {
                      return _buildAddButton();
                    }
                  },
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildAddButton(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(File image, int index, bool isFile) {
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
                onTap: () => _clearImage(index, isFile),
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

  Widget _buildNetworkThumbnail(String imageUrl, int index) {
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
                onTap: () => _clearImage(index, false),
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

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _selectMultipleImages,
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

  @override
  Widget build(BuildContext context) {
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildImageSection(),
                      
                      Container(
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
                                  'Basic Information',
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
                              validator: (value) => value?.isEmpty == true ? 'Please select location' : null,
                            ),

                            CustomFormField(
                              controller: _districtNameController,
                              label: 'District *',
                              hintText: 'District',
                              readOnly: true,
                              validator: (value) => value?.isEmpty == true ? 'Please select location' : null,
                            ),

                            CustomFormField(
                              controller: _wardNameController,
                              label: 'Ward *',
                              hintText: 'Ward',
                              readOnly: true,
                              validator: (value) => value?.isEmpty == true ? 'Please select location' : null,
                            ),

                            CustomFormField(
                              controller: _streetNameController,
                              label: 'Street / House Number *',
                              hintText: 'Enter street address',
                              validator: (value) => value?.trim().isEmpty == true ? 'Street address is required' : null,
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
                      ),
                      
                      const SizedBox(height: 100), // Space for button
                    ],
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
              onPressed: _saveFacilityInfo,
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
