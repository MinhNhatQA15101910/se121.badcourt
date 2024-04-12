import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextfield extends StatefulWidget {
  const CustomTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.validator,
    this.isPassword = false,
  });

  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final bool isPassword;

  @override
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  var _showPassword = false;

  void _toggleVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && !_showPassword,
      enableSuggestions: !widget.isPassword,
      autocorrect: !widget.isPassword,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: GoogleFonts.inter(
          color: GlobalVariables.darkGrey,
          fontSize: 16,
        ),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: GlobalVariables.lightGreen,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: GlobalVariables.lightGreen,
          ),
        ),
        suffixIcon: GestureDetector(
          onTap: _toggleVisibility,
          child: Icon(
            !widget.isPassword
                ? null
                : _showPassword
                    ? Icons.visibility
                    : Icons.visibility_off,
          ),
        ),
      ),
      style: GoogleFonts.inter(
        fontSize: 16,
      ),
      validator: widget.validator,
    );
  }
}
