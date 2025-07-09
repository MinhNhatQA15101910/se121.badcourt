// ignore_for_file: deprecated_member_use

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_textfield.dart';
import 'package:frontend/common/widgets/loader.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _authService = AuthService();
  var _isValidateLoading = false;

  final _forgotPasswordFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  void _validateEmailAndNavigate() {
    if (_forgotPasswordFormKey.currentState!.validate()) {
      setState(() {
        _isValidateLoading = true;
      });

      Future.delayed(Duration(seconds: 2), () async { 
        await _authService.validateEmail(
          context: context,
          email: _emailController.text.trim(),
        );

        setState(() {
          _isValidateLoading = false;
        });
      });
    }
  }

  void _moveToPreviousForm() {
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    authProvider.setForm(
      authProvider.previousForm!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GlobalVariables.defaultColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: GlobalVariables.lightGreen.withOpacity(0.5),
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 16,
      ),
      child: Form(
        key: _forgotPasswordFormKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Forgot your password text
              Text(
                'Forgot your password',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  color: GlobalVariables.darkGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 28),

              // Long text
              Text(
                'Please enter your email to reset the password',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: GlobalVariables.blackGrey,
                ),
              ),
              const SizedBox(height: 14),

              // Email text form field
              CustomTextfield(
                controller: _emailController,
                hintText: 'Email address',
                isEmail: true,
                validator: (email) {
                  if (email == null || email.isEmpty) {
                    return 'Please enter your email.';
                  }

                  if (!EmailValidator.validate(email)) {
                    return 'Please enter a valid email address.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _moveToPreviousForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GlobalVariables.lightGrey,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: GlobalVariables.green,
                          ),
                        ),
                      ),
                      child: Text(
                        'Previous',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: GlobalVariables.green,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: _isValidateLoading
                        ? const Loader()
                        : ElevatedButton(
                            onPressed: _validateEmailAndNavigate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: GlobalVariables.green,
                              elevation: 0,
                            ),
                            child: Text(
                              '     Next     ',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: GlobalVariables.white,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
