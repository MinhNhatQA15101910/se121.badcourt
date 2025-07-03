import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_button.dart';
import 'package:frontend/common/widgets/custom_form_field.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/court_management/services/court_management_service.dart';
import 'package:frontend/models/court.dart';
import 'package:google_fonts/google_fonts.dart';

class AddUpdateCourtBottomSheet extends StatefulWidget {
  const AddUpdateCourtBottomSheet({
    super.key,
    this.court,
  });

  final Court? court;

  @override
  State<AddUpdateCourtBottomSheet> createState() =>
      _AddUpdateCourtBottomSheetState();
}

class _AddUpdateCourtBottomSheetState extends State<AddUpdateCourtBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _courtNameController = TextEditingController();
  final _courtDescController = TextEditingController();
  final _pricePerHourController = TextEditingController();
  final _courtManagementService = CourtManagementService();

  // Constants for validation
  static const int MIN_PRICE = 10000;
  static const int MAX_COURT_NAME_LENGTH = 50;
  static const int MIN_COURT_NAME_LENGTH = 3;
  static const int MAX_DESCRIPTION_LENGTH = 200;
  static const int MIN_DESCRIPTION_LENGTH = 10;
  static const int MAX_PRICE = 10000000; // 10 million VND

  void _addUpdateCourt() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Court? court = null;

    if (widget.court == null) {
      court = await _courtManagementService.addCourt(
        context: context,
        name: _courtNameController.text.trim(),
        description: _courtDescController.text.trim(),
        pricePerHour: int.parse(_pricePerHourController.text),
      );
    } else {
      court = await _courtManagementService.updateCourt(
        context: context,
        courtId: widget.court!.id,
        name: _courtNameController.text.trim(),
        description: _courtDescController.text.trim(),
        pricePerHour: int.parse(_pricePerHourController.text),
      );
    }

    Navigator.of(context).pop(court);
  }

  @override
  void initState() {
    super.initState();
    if (widget.court != null) {
      _courtNameController.text = widget.court!.courtName;
      _courtDescController.text = widget.court!.description;
      _pricePerHourController.text = widget.court!.pricePerHour.toString();
    }
  }

  // Enhanced validation methods
  String? _validateCourtName(String? courtName) {
    if (courtName == null || courtName.trim().isEmpty) {
      return 'Court name is required';
    }
    
    final trimmedName = courtName.trim();
    
    if (trimmedName.length < MIN_COURT_NAME_LENGTH) {
      return 'Court name must be at least $MIN_COURT_NAME_LENGTH characters';
    }
    
    if (trimmedName.length > MAX_COURT_NAME_LENGTH) {
      return 'Court name must not exceed $MAX_COURT_NAME_LENGTH characters';
    }
    
    // Check for valid characters (letters, numbers, spaces, and common punctuation)
    if (!RegExp(r'^[a-zA-Z0-9\s\-_\.]+$').hasMatch(trimmedName)) {
      return 'Court name contains invalid characters';
    }
    
    return null;
  }

  String? _validateDescription(String? description) {
    if (description == null || description.trim().isEmpty) {
      return 'Description is required';
    }
    
    final trimmedDesc = description.trim();
    
    if (trimmedDesc.length < MIN_DESCRIPTION_LENGTH) {
      return 'Description must be at least $MIN_DESCRIPTION_LENGTH characters';
    }
    
    if (trimmedDesc.length > MAX_DESCRIPTION_LENGTH) {
      return 'Description must not exceed $MAX_DESCRIPTION_LENGTH characters';
    }
    
    return null;
  }

  String? _validatePrice(String? price) {
    if (price == null || price.trim().isEmpty) {
      return 'Price per hour is required';
    }
    
    final trimmedPrice = price.trim();
    final parsedPrice = int.tryParse(trimmedPrice);
    
    if (parsedPrice == null) {
      return 'Please enter a valid number';
    }
    
    if (parsedPrice < MIN_PRICE) {
      return 'Price must be at least ${_formatCurrency(MIN_PRICE)}';
    }
    
    if (parsedPrice > MAX_PRICE) {
      return 'Price must not exceed ${_formatCurrency(MAX_PRICE)}';
    }
    
    return null;
  }

  // Helper method to format currency
  String _formatCurrency(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        bottom: keyboardSpace,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 32,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 24,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        top: 8,
                      ),
                      child: _boldSizeText(
                          '${widget.court != null ? 'Update' : 'Add'} a court'),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      iconSize: 24,
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: GlobalVariables.lightGrey,
                thickness: 1.0,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Court name text with enhanced validation
                    CustomFormField(
                      controller: _courtNameController,
                      label: 'Court name',
                      hintText: 'Enter court name (3-50 characters)',
                      validator: _validateCourtName,
                    ),
                    // Court description text with enhanced validation
                    CustomFormField(
                      controller: _courtDescController,
                      label: 'Description',
                      hintText: 'Enter description (10-200 characters)',
                      maxLines: 5,
                      validator: _validateDescription,
                    ),
                    // Price per hour text with enhanced validation
                    CustomFormField(
                      controller: _pricePerHourController,
                      label: 'Price per hour (đ)',
                      hintText: 'Minimum ${_formatCurrency(MIN_PRICE)}',
                      isNumber: true,
                      validator: _validatePrice,
                    ),
                    // Helper text for price
                    Padding(
                      padding: EdgeInsets.only(top: 4, left: 4),
                      child: Text(
                        'Price must be between ${_formatCurrency(MIN_PRICE)} and ${_formatCurrency(MAX_PRICE)}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: GlobalVariables.darkGrey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    )
                  ],
                ),
              ),
              Divider(
                color: GlobalVariables.grey,
                thickness: 1,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        onTap: () => Navigator.pop(context),
                        buttonText: 'Cancel',
                        borderColor: GlobalVariables.green,
                        fillColor: Colors.white,
                        textColor: GlobalVariables.green,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: CustomButton(
                        onTap: _addUpdateCourt,
                        buttonText: widget.court != null ? 'Update' : 'Add',
                        borderColor: GlobalVariables.green,
                        fillColor: GlobalVariables.green,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _courtNameController.dispose();
    _courtDescController.dispose();
    _pricePerHourController.dispose();
    super.dispose();
  }

  Widget _boldSizeText(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
