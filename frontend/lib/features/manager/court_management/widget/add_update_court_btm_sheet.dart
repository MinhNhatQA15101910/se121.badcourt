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

  void _addUpdateCourt() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Court? court = null;
    if (widget.court == null) {
      court = await _courtManagementService.addCourt(
        context: context,
        name: _courtNameController.text,
        description: _courtDescController.text,
        pricePerHour: int.parse(_pricePerHourController.text),
      );
    } else {
      court = await _courtManagementService.updateCourt(
        context: context,
        courtId: widget.court!.id,
        name: _courtNameController.text,
        description: _courtDescController.text,
        pricePerHour: int.parse(_pricePerHourController.text),
      );
    }

    Navigator.of(context).pop(court);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    if (widget.court != null) {
      _courtNameController.text = widget.court!.name;
      _courtDescController.text = widget.court!.description;
      _pricePerHourController.text = widget.court!.pricePerHour.toString();
    }

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
                    // Court name text
                    CustomFormField(
                      controller: _courtNameController,
                      label: 'Court name',
                      hintText: 'Court name',
                      validator: (courtName) {
                        if (courtName == null || courtName.isEmpty) {
                          return 'Court name is required';
                        }
                        return null;
                      },
                    ),

                    // Court description text
                    CustomFormField(
                      controller: _courtDescController,
                      label: 'Description',
                      hintText: 'Description',
                      maxLines: 5,
                      validator: (description) {
                        if (description == null || description.isEmpty) {
                          return 'Description is required';
                        }
                        return null;
                      },
                    ),

                    // Price per hour text
                    CustomFormField(
                      controller: _pricePerHourController,
                      label: 'Price per hour (đ)',
                      hintText: '0',
                      isNumber: true,
                      validator: (price) {
                        if (price == null || price.isEmpty) {
                          return 'Price per hour is required';
                        }
                        if (int.tryParse(price) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
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
