import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_textfield.dart';
import 'package:frontend/common/widgets/loader.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/auth/widgets/forgot_password_form.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ResetPasswordForm extends StatefulWidget {
  const ResetPasswordForm({super.key});

  @override
  State<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  final _authService = AuthService();
  var _isChangePasswordLoading = false;

  final _loginFormKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  final _passwordConfirmedController = TextEditingController();

  void _updatePassword() {
    if (_loginFormKey.currentState!.validate()) {
      setState(() {
        _isChangePasswordLoading = true;
      });

      Future.delayed(Duration(seconds: 2), () async {
        final email = Provider.of<AuthProvider>(
          context,
          listen: false,
        ).resentEmail;

        await _authService.changePassword(
          context: context,
          email: email,
          newPassword: _passwordController.text.trim(),
        );

        setState(() {
          _isChangePasswordLoading = false;
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
      authProvider.previousForm,
    );

    authProvider.setPreviousForm(
      ForgotPasswordForm(),
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
        vertical: 20,
        horizontal: 14,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Form(
        key: _loginFormKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Set a new password text
              Text(
                'Set a new password',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  color: GlobalVariables.darkGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Long text
              Text(
                'Create a new password. Ensure it is different from previous ones.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: GlobalVariables.blackGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // Password text form field
              CustomTextfield(
                controller: _passwordController,
                isPassword: true,
                hintText: 'Password',
                validator: (password) {
                  if (password == null || password.isEmpty) {
                    return 'Please enter your password.';
                  }

                  if (password.length < 8) {
                    return 'Password must be at least 8 characters long.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirm password text form field
              CustomTextfield(
                controller: _passwordConfirmedController,
                isPassword: true,
                hintText: 'Confirm password',
                validator: (password) {
                  if (password == null || password.isEmpty) {
                    return 'Please enter your password.';
                  }

                  if (password != _passwordController.text.trim()) {
                    return 'Password not match.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Update password button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 150,
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
                    width: 150,
                    height: 40,
                    child: _isChangePasswordLoading
                        ? const Loader()
                        : ElevatedButton(
                            onPressed: _updatePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: GlobalVariables.green,
                              elevation: 0,
                            ),
                            child: Text(
                              'Update',
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
    _passwordController.dispose();
    _passwordConfirmedController.dispose();
    super.dispose();
  }
}
