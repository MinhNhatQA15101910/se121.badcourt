import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextfield extends StatefulWidget {
  const CustomTextfield({
    super.key,
    required this.controller,
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
    this.maxLength,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autovalidateMode,
    this.errorText,
    this.hasError = false,
    this.showLabel = true, // Control whether to show internal label
  });

  final TextEditingController controller;
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
  final int? maxLength;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;
  final AutovalidateMode? autovalidateMode;
  final String? errorText;
  final bool hasError;
  final bool showLabel;

  @override
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  bool _obscureText = false;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText || widget.isPassword;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  TextInputType _getKeyboardType() {
    if (widget.isEmail) return TextInputType.emailAddress;
    if (widget.isNumber) return TextInputType.number;
    if (widget.isPhoneNumber) return TextInputType.phone;
    return widget.keyboardType;
  }

  List<TextInputFormatter> _getInputFormatters() {
    List<TextInputFormatter> formatters = [];
    
    if (widget.isNumber) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    }
    
    if (widget.isPhoneNumber) {
      formatters.add(FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s$$$$]')));
    }
    
    if (widget.maxLength != null) {
      formatters.add(LengthLimitingTextInputFormatter(widget.maxLength));
    }
    
    return formatters;
  }

  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: GlobalVariables.darkGrey,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    return widget.suffixIcon;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.hasError 
              ? Colors.red 
              : _isFocused 
                  ? GlobalVariables.green 
                  : GlobalVariables.darkGrey,
          width: _isFocused ? 2 : 1,
        ),
        color: widget.readOnly 
            ? GlobalVariables.darkGrey.withOpacity(0.3)
            : GlobalVariables.defaultColor,
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        maxLines: widget.maxLines,
        readOnly: widget.readOnly,
        enabled: widget.enabled,
        obscureText: _obscureText,
        keyboardType: _getKeyboardType(),
        inputFormatters: _getInputFormatters(),
        textInputAction: widget.textInputAction,
        autovalidateMode: widget.autovalidateMode,
        validator: widget.validator,
        onChanged: widget.onChanged,
        onTap: widget.onTap,
        onFieldSubmitted: widget.onFieldSubmitted,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: widget.enabled 
              ? GlobalVariables.darkGreen 
              : GlobalVariables.darkGrey,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: GlobalVariables.darkGrey,
            fontWeight: FontWeight.w300,
          ),
          prefixIcon: widget.prefixIcon,
          suffixIcon: _buildSuffixIcon(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: InputBorder.none,
          errorBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          errorStyle: const TextStyle(height: 0), // Hide default error text
        ),
      ),
    );
  }
}