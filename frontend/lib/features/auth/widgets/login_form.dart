import 'package:dotted_line/dotted_line.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_textfield.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/auth/widgets/forgot_password_form.dart';
import 'package:frontend/features/auth/widgets/oauth_button.dart';
import 'package:frontend/features/auth/widgets/sign_up_form.dart';
import 'package:frontend/providers/auth_form_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _loginFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _logInUser() {
    if (_loginFormKey.currentState!.validate()) {
      // TODO: Log in user
    }
  }

  void _moveToSignUpForm() {
    final authFormProvider = Provider.of<AuthFormProvider>(
      context,
      listen: false,
    );

    authFormProvider.setForm(SignUpForm());
  }

  void _moveToForgotPasswordForm() {
    final authFormProvider = Provider.of<AuthFormProvider>(
      context,
      listen: false,
    );

    authFormProvider.setPreviousForm(
      LoginForm(),
    );

    authFormProvider.setForm(
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
              // Log in text
              Text(
                'Log in',
                style: GoogleFonts.inter(
                    fontSize: 26,
                    color: GlobalVariables.darkGreen,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 36),

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

              // Forgot your password text
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () {},
                  child: RichText(
                    textAlign: TextAlign.right,
                    text: TextSpan(
                      text: 'Forgot your ',
                      style: GoogleFonts.inter(
                          color: GlobalVariables.darkGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w300),
                      children: [
                        TextSpan(
                            text: 'Password?',
                            style: GoogleFonts.inter(
                                color: GlobalVariables.darkGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = _moveToForgotPasswordForm)
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Log in button
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 216,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _logInUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GlobalVariables.green,
                      elevation: 0,
                    ),
                    child: Text(
                      'Log in',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: GlobalVariables.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Continue with separator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 78,
                    height: 1,
                    color: GlobalVariables.lightGreen,
                  ),
                  Text(
                    'Continue with',
                    style: GoogleFonts.inter(
                      color: GlobalVariables.darkGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Container(
                    width: 78,
                    height: 1,
                    color: GlobalVariables.lightGreen,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // OAuth buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OAuthButton(
                    assetName: 'assets/vectors/vector-google.svg',
                    onPressed: () {},
                  ),
                  OAuthButton(
                    assetName: 'assets/vectors/vector-facebook.svg',
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // OR Separator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DottedLine(
                    lineLength: 120,
                    lineThickness: 1,
                    dashLength: 2,
                    dashGapLength: 2,
                    dashColor: GlobalVariables.lightGreen,
                  ),
                  Text(
                    'OR',
                    style: GoogleFonts.inter(
                      color: GlobalVariables.darkGreen,
                      fontWeight: FontWeight.w500,
                      fontSize: 19,
                    ),
                  ),
                  DottedLine(
                    lineLength: 120,
                    lineThickness: 1,
                    dashLength: 2,
                    dashGapLength: 2,
                    dashColor: GlobalVariables.lightGreen,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Continue as a guess button
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 216,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {},
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
                      'Continue as a guest',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: GlobalVariables.green,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Navigate to Sign Up form text
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {},
                  child: RichText(
                    textAlign: TextAlign.right,
                    text: TextSpan(
                      text: 'Don\'t have an account? ',
                      style: GoogleFonts.inter(
                        color: GlobalVariables.darkGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                      children: [
                        TextSpan(
                            text: 'Sign up',
                            style: GoogleFonts.inter(
                              color: GlobalVariables.darkGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = _moveToSignUpForm)
                      ],
                    ),
                  ),
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
