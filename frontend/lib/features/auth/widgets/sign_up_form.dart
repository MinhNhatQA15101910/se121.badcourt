import 'package:dotted_line/dotted_line.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_textfield.dart';
import 'package:frontend/common/widgets/loader.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/auth/widgets/login_form.dart';
import 'package:frontend/features/auth/widgets/oauth_button.dart';
import 'package:frontend/providers/auth_form_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _authService = AuthService();
  var _isLoading = false;
  var _isLoginWithGoogleLoading = false;

  final _signUpFormKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmedController = TextEditingController();

  void _signUpUser() async {
    if (_signUpFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      bool isSuccessful = await _authService.signUpUser(
        context: context,
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (isSuccessful) {
        _usernameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _passwordConfirmedController.clear();
      }
    }
  }

  void _loginWithGoogle() async {
    setState(() {
      _isLoginWithGoogleLoading = true;
    });

    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email'],
    );
    GoogleSignInAccount? account = await googleSignIn.signIn();
    if (account != null) {
      await _authService.logInWithGoogle(
        context: context,
        account: account,
      );
    }

    setState(() {
      _isLoginWithGoogleLoading = false;
    });
  }

  void _moveToLoginForm() {
    final authFormProvider = Provider.of<AuthFormProvider>(
      context,
      listen: false,
    );

    authFormProvider.setForm(LoginForm());
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
        key: _signUpFormKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sign up text
              Text(
                'Sign up',
                style: GoogleFonts.inter(
                    fontSize: 26,
                    color: GlobalVariables.darkGreen,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 36),

              // Username text form field
              CustomTextfield(
                controller: _usernameController,
                hintText: 'Username',
                validator: (username) {
                  if (username == null || username.isEmpty) {
                    return 'Please enter your username.';
                  }

                  if (username.length < 6) {
                    return 'Username must be at least 6 characters long.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),

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

              // Password confirm text form field
              CustomTextfield(
                controller: _passwordConfirmedController,
                isPassword: true,
                hintText: 'Confirm password',
                validator: (password) {
                  if (password == null || password.isEmpty) {
                    return 'Please enter your password.';
                  }

                  if (password.trim() != _passwordController.text.trim()) {
                    return 'Password confirm does not match.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 36),

              // Sign up button
              Align(
                alignment: Alignment.center,
                child: _isLoading
                    ? const Loader()
                    : SizedBox(
                        width: 216,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: _signUpUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GlobalVariables.green,
                            elevation: 0,
                          ),
                          child: Text(
                            'Sign up',
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
                  _isLoginWithGoogleLoading
                      ? Container(
                          width: 120,
                          height: 48,
                          child: const Loader(),
                        )
                      : OAuthButton(
                          assetName: 'assets/vectors/vector-google.svg',
                          onPressed: _loginWithGoogle,
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
                      text: 'Already have an account? ',
                      style: GoogleFonts.inter(
                        color: GlobalVariables.darkGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                      children: [
                        TextSpan(
                          text: 'Log in',
                          style: GoogleFonts.inter(
                              color: GlobalVariables.darkGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = _moveToLoginForm,
                        )
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
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmedController.dispose();
    super.dispose();
  }
}
