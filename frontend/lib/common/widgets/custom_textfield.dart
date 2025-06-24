import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextfield extends StatefulWidget {
  const CustomTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
    this.onChanged,
    this.isPassword = false,
    this.isNumber = false,
    this.isPhoneNumber = false,
    this.isEmail = false,
    this.maxLines = 1,
    this.readOnly = false,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final bool isPassword;
  final bool isNumber;
  final bool isPhoneNumber;
  final bool isEmail;
  final int maxLines;
  final bool readOnly;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;

  @override
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  var _showPassword = false;
  var _isFocused = false;

  void _toggleVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: widget.controller,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            readOnly: widget.readOnly,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onFieldSubmitted,
            obscureText: widget.isPassword && !_showPassword,
            enableSuggestions: !widget.isPassword,
            keyboardType: widget.isNumber
                ? TextInputType.number
                : widget.isPhoneNumber
                    ? TextInputType.phone
                    : widget.isEmail
                        ? TextInputType.emailAddress
                        : widget.maxLines > 1
                            ? TextInputType.multiline
                            : TextInputType.text,
            autocorrect: !widget.isPassword,
            textCapitalization: widget.isEmail 
                ? TextCapitalization.none 
                : TextCapitalization.sentences,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: widget.enabled 
                  ? GlobalVariables.darkGreen 
                  : GlobalVariables.darkGrey,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: GoogleFonts.inter(
                color: GlobalVariables.darkGrey.withOpacity(0.6),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: widget.maxLines > 1 ? 16 : 14,
              ),
              
              // Prefix icon
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: widget.prefixIcon,
                    )
                  : null,
              prefixIconConstraints: widget.prefixIcon != null
                  ? const BoxConstraints(minWidth: 40, minHeight: 40)
                  : null,

              // Suffix icon (password toggle or custom)
              suffixIcon: _buildSuffixIcon(),
              suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),

              // Counter text (hide default counter)
              counterText: widget.maxLength != null ? null : '',

              // Border styling
              border: _buildBorder(GlobalVariables.lightGreen),
              enabledBorder: _buildBorder(
                widget.enabled 
                    ? GlobalVariables.lightGreen 
                    : GlobalVariables.darkGrey.withOpacity(0.3)
              ),
              focusedBorder: _buildBorder(GlobalVariables.green, width: 2),
              errorBorder: _buildBorder(Colors.red.shade400),
              focusedErrorBorder: _buildBorder(Colors.red.shade400, width: 2),
              disabledBorder: _buildBorder(GlobalVariables.darkGrey.withOpacity(0.3)),

              // Fill color
              filled: true,
              fillColor: widget.enabled
                  ? (_isFocused 
                      ? GlobalVariables.lightGreen.withOpacity(0.1)
                      : GlobalVariables.lightGrey.withOpacity(0.3))
                  : GlobalVariables.darkGrey.withOpacity(0.1),

              // Error styling
              errorStyle: GoogleFonts.inter(
                color: Colors.red.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              errorMaxLines: 2,
            ),
            onChanged: widget.onChanged,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          
          // Custom character counter for better styling
          if (widget.maxLength != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${widget.controller.text.length}/${widget.maxLength}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: widget.controller.text.length > (widget.maxLength! * 0.9)
                        ? Colors.orange.shade600
                        : GlobalVariables.darkGrey.withOpacity(0.7),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return GestureDetector(
        onTap: widget.enabled ? _toggleVisibility : null,
        child: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Icon(
            _showPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: widget.enabled
                ? (_isFocused 
                    ? GlobalVariables.green 
                    : GlobalVariables.darkGrey.withOpacity(0.7))
                : GlobalVariables.darkGrey.withOpacity(0.4),
            size: 20,
          ),
        ),
      );
    } else if (widget.suffixIcon != null) {
      return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: widget.suffixIcon,
      );
    }
    return null;
  }

  OutlineInputBorder _buildBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Listen to controller changes for character counter
    if (widget.maxLength != null) {
      widget.controller.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }
}