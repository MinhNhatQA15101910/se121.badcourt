import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_button.dart';
import 'package:frontend/common/widgets/custom_textfield.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/court_management/services/court_management_service.dart';
import 'package:google_fonts/google_fonts.dart';

class AddUpdateCourtBottomSheet extends StatefulWidget {
  final String stateText;
  final Function(bool) onUpdateSuccess; // Callback to update parent widget

  const AddUpdateCourtBottomSheet({
    Key? key,
    required this.stateText,
    required this.onUpdateSuccess,
  }) : super(key: key);

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

  Future<void> _addUpdateFacility() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {});

    try {
      if (widget.stateText == 'Add') {
        await _courtManagementService.addCourt(
          context: context,
          facilityId: GlobalVariables.facility.id,
          name: _courtNameController.text,
          description: _courtDescController.text,
          pricePerHour: int.parse(_pricePerHourController.text),
        );
      } else if (widget.stateText == 'Update') {
        await _courtManagementService.updateCourt(
          context: context,
          courtId: GlobalVariables.court.id,
          name: _courtNameController.text,
          description: _courtDescController.text,
          pricePerHour: int.parse(_pricePerHourController.text),
        );
      }

      // Notify parent widget of success
      widget.onUpdateSuccess(true);

      Navigator.pop(context);
    } finally {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      if (widget.stateText == 'Update') {
        _courtNameController.text = GlobalVariables.court.name;
        _courtDescController.text = GlobalVariables.court.description;
        _pricePerHourController.text =
            GlobalVariables.court.pricePerHour.toString();
      } else {
        _courtNameController.text = '';
        _courtDescController.text = '';
        _pricePerHourController.text = '';
      }
    });
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
                      child: Expanded(
                        child: _BoldSizeText(widget.stateText + ' a court'),
                      ),
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
                    _InterRegular14(
                      "Court name *",
                      GlobalVariables.darkGrey,
                      1,
                    ),
                    CustomTextfield(
                      controller: _courtNameController,
                      hintText: 'Court name',
                      validator: (courtName) {
                        if (courtName == null || courtName.isEmpty) {
                          return 'Court name is required';
                        }
                        return null;
                      },
                    ),
                    _InterRegular14(
                      "Description",
                      GlobalVariables.darkGrey,
                      1,
                    ),
                    CustomTextfield(
                      controller: _courtDescController,
                      hintText: 'Description',
                      validator: (description) {
                        // Optional validation, can be adjusted as needed
                        return null;
                      },
                    ),
                    _InterRegular14(
                      'Price per hour (\đ)',
                      GlobalVariables.darkGrey,
                      1,
                    ),
                    CustomTextfield(
                      controller: _pricePerHourController,
                      hintText: '0',
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
                        onTap: _addUpdateFacility,
                        buttonText: widget.stateText,
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

  Widget _BoldSizeText(String text) {
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
