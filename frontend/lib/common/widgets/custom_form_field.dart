import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_textfield.dart';
import 'package:frontend/common/widgets/label_display.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomFormField extends StatefulWidget {
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
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onTap,
    this.enabled = true,
    this.showCounter = false,
    this.maxLength,
    this.helperText,
    this.errorText,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autovalidateMode,
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
  final bool isPassword;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final bool enabled;
  final bool showCounter;
  final int? maxLength;
  final String? helperText;
  final String? errorText;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;
  final AutovalidateMode? autovalidateMode;

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  String? _errorText;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Listen to controller changes for real-time validation
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (widget.validator != null && mounted) {
      final error = widget.validator!(widget.controller.text);
      if (error != _errorText) {
        setState(() {
          _errorText = error;
          _hasError = error != null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with required indicator
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 12),
          child: Row(
            children: [
              LabelDisplay(
                label: widget.label,
                isRequired: widget.validator != null,
              ),
              if (widget.helperText != null) ...[
                const SizedBox(width: 8),
                Tooltip(
                  message: widget.helperText!,
                  child: Icon(
                    Icons.help_outline,
                    size: 16,
                    color: GlobalVariables.darkGrey,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Custom TextField with enhanced integration
        CustomTextfield(
          controller: widget.controller,
          hintText: widget.hintText,
          isEmail: widget.isEmail,
          isNumber: widget.isNumber,
          isPhoneNumber: widget.isPhoneNumber,
          isPassword: widget.isPassword,
          maxLines: widget.maxLines,
          readOnly: widget.readOnly,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          onChanged: (value) {
            widget.onChanged?.call(value);
            _onTextChanged();
          },
          onTap: widget.onTap,
          enabled: widget.enabled,
          maxLength: widget.maxLength,
          focusNode: widget.focusNode,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onFieldSubmitted,
          autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.onUserInteraction,
          // Override error styling to prevent conflicts
          errorText: widget.errorText ?? _errorText,
          hasError: _hasError,
        ),

        // Character counter
        if (widget.showCounter && widget.maxLength != null) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${widget.controller.text.length}/${widget.maxLength}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: widget.controller.text.length > widget.maxLength!
                    ? Colors.red
                    : GlobalVariables.darkGrey,
              ),
            ),
          ),
        ],

        // Helper text
        if (widget.helperText != null && !_hasError) ...[
          const SizedBox(height: 4),
          Text(
            widget.helperText!,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: GlobalVariables.darkGrey,
            ),
          ),
        ],
      ],
    );
  }
}