import 'package:dotted_line/dotted_line.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/common/widgets/custom_textfield.dart';
import 'package:frontend/common/widgets/loader.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/auth/widgets/login_form.dart';
import 'package:frontend/features/auth/widgets/pinput_form.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
  });

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _authService = AuthService();
  var _isLoginWithGoogleLoading = false;
  var _isMoveToPinputFormLoading = false;

  final _signUpFormKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmedController = TextEditingController();

  // Password requirements validation
  Map<String, bool> _getPasswordRequirements(String password) {
    return {
      'minLength': password.length >= 8,
      'hasUppercase': password.contains(RegExp(r'[A-Z]')),
      'hasLowercase': password.contains(RegExp(r'[a-z]')),
      'hasNumber': password.contains(RegExp(r'[0-9]')),
      'hasSpecialChar': password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
    };
  }

  // Enhanced password validator
  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter your password.';
    }

    final requirements = _getPasswordRequirements(password);
    
    if (!requirements['minLength']!) {
      return 'Password must be at least 8 characters long.';
    }
    
    if (!requirements['hasUppercase']!) {
      return 'Password must contain at least 1 uppercase letter.';
    }
    
    if (!requirements['hasLowercase']!) {
      return 'Password must contain at least 1 lowercase letter.';
    }
    
    if (!requirements['hasNumber']!) {
      return 'Password must contain at least 1 number.';
    }
    
    if (!requirements['hasSpecialChar']!) {
      return 'Password must contain at least 1 special character.';
    }

    return null;
  }

  // Enhanced email validator
  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please enter your email.';
    }

    // Check basic email format
    if (!EmailValidator.validate(email)) {
      return 'Please enter a valid email address.';
    }

    // Additional email validation rules
    if (email.length > 254) {
      return 'Email too long (maximum 254 characters).';
    }

    // Check for consecutive dots
    if (email.contains('..')) {
      return 'Email cannot contain consecutive periods.';
    }

    // Check for valid domain
    final parts = email.split('@');
    if (parts.length != 2) {
      return 'Invalid email.';
    }

    final domain = parts[1];
    if (domain.isEmpty || domain.startsWith('.') || domain.endsWith('.')) {
      return 'Invalid email domain.';
    }

    return null;
  }

  // Enhanced username validator
  String? _validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'Please enter your username.';
    }

    if (username.length < 6) {
      return 'Username must be at least 6 characters long.';
    }

    if (username.length > 30) {
      return 'Username cannot exceed 30 characters.';
    }

    // Check for valid characters (letters, numbers, underscore, hyphen)
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(username)) {
      return 'Username can only contain letters, numbers, underscores and hyphens.';
    }

    // Cannot start or end with special characters
    if (username.startsWith('_') || username.startsWith('-') || 
        username.endsWith('_') || username.endsWith('-')) {
      return 'Username cannot start or end with special characters.';
    }

    return null;
  }

  void _loginWithGoogle() {
    setState(() {
      _isLoginWithGoogleLoading = true;
    });

    Future.delayed(Duration(seconds: 2), () async {
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
    });
  }

  void _moveToLoginForm() {
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    authProvider.setForm(LoginForm());
  }

  void _moveToPinputForm() {
    if (_signUpFormKey.currentState!.validate()) {
      setState(() {
        _isMoveToPinputFormLoading = true;
      });

      Future.delayed(
        Duration(seconds: 2),
        () async {
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );

          final isSignUpValid = await _authService.validateSignUp(
            context: context,
            username: _usernameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

          if (isSignUpValid) {
            authProvider.setResentEmail(_emailController.text.trim());
            authProvider.setPreviousForm(SignUpForm());
            authProvider.setSignUpUser(User.empty());
            authProvider.setForm(
              PinputForm(
                isMoveBack: false,
                isValidateSignUpEmail: true,
              ),
            );
          } else {
            IconSnackBar.show(
              context,
              label: 'Sign up failed!',
              snackBarType: SnackBarType.fail,
            );
          }

          setState(() {
            _isMoveToPinputFormLoading = false;
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

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
                validator: _validateUsername,
              ),
              const SizedBox(height: 16),

              // Email text form field
              CustomTextfield(
                controller: _emailController,
                hintText: 'Email address',
                isEmail: true,
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),

              // Password text form field
              CustomTextfield(
                controller: _passwordController,
                isPassword: true,
                hintText: 'Password',
                validator: _validatePassword,
              ),
              const SizedBox(height: 16),

              // Password confirm text form field
              CustomTextfield(
                controller: _passwordConfirmedController,
                isPassword: true,
                hintText: 'Confirm password',
                validator: (password) {
                  if (password == null || password.isEmpty) {
                    return 'Please confirm your password.';
                  }

                  if (password.trim() != _passwordController.text.trim()) {
                    return 'Password confirmation does not match.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 36),

              // Sign up button
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 216,
                  height: 40,
                  child: _isMoveToPinputFormLoading
                      ? const Loader()
                      : ElevatedButton(
                          onPressed: _moveToPinputForm,
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
              if (authProvider.isPlayer)
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
              if (authProvider.isPlayer) const SizedBox(height: 16),

              // Sign up with Google button
              if (authProvider.isPlayer)
                Align(
                  alignment: Alignment.center,
                  child: _isLoginWithGoogleLoading
                      ? const Loader()
                      : SizedBox(
                          width: 216,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: _loginWithGoogle,
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
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/vectors/vector-google.svg',
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Sign up with Google',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: GlobalVariables.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              if (authProvider.isPlayer) const SizedBox(height: 16),

              // OR Separator
              if (authProvider.isPlayer)
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
              if (authProvider.isPlayer) const SizedBox(height: 16),

              // Continue as a guest button
              if (authProvider.isPlayer)
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
              if (authProvider.isPlayer) const SizedBox(height: 16),

              // Navigate to Login form text
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