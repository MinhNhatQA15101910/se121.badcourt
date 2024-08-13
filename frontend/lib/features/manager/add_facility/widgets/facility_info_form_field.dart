import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_textfield.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';

class FacilityInfoFormField extends StatelessWidget {
  const FacilityInfoFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.maxLines = 1,
    this.readOnly = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.text,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool readOnly;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? text;

  @override
  Widget build(BuildContext context) {
    Widget labelDisplay = RichText(
      text: TextSpan(
        text: label,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: GlobalVariables.darkGrey,
        ),
        children: [
          TextSpan(
            text: ' (*)',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ],
      ),
    );

    if (validator == null) {
      labelDisplay = Text(
        '$label (optional)',
        style: GoogleFonts.inter(
          fontSize: 14,
          color: GlobalVariables.darkGrey,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: 8,
            top: 12,
          ),
          child: labelDisplay,
        ),
        CustomTextfield(
          text: text,
          controller: controller,
          hintText: hintText,
          maxLines: maxLines,
          readOnly: readOnly,
          validator: validator,
        ),
      ],
    );
  }
}
