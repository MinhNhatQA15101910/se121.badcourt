import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_textfield.dart';
import 'package:frontend/common/widgets/label_display.dart';

class CustomFormField extends StatelessWidget {
  const CustomFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.maxLines = 1,
    this.readOnly = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.isEmail = false,
    this.isNumber = false,
    this.isPhoneNumber = false,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool readOnly;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool isEmail;
  final bool isNumber;
  final bool isPhoneNumber;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: 8,
            top: 12,
          ),
          child: LabelDisplay(
            label: label,
            isRequired: validator != null,
          ),
        ),
        CustomTextfield(
          controller: controller,
          hintText: hintText,
          isEmail: isEmail,
          isNumber: isNumber,
          isPhoneNumber: isPhoneNumber,
          maxLines: maxLines,
          readOnly: readOnly,
          validator: validator,
        ),
      ],
    );
  }
}
