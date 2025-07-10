import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
import 'package:email_validator/email_validator.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm>
    with TickerProviderStateMixin {
  final _authService = AuthService();
  var _isLoginWithGoogleLoading = false;
  var _isMoveToPinputFormLoading = false;

  final _signUpFormKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmedController = TextEditingController();

  late AnimationController _formAnimationController;
  late Animation<double> _formFadeAnimation;

  @override
  void initState() {
    super.initState();
    _formAnimationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _formFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeInOut,
    ));

    _formAnimationController.forward();
  }

  @override
  void dispose() {
    _formAnimationController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmedController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'Please enter your username.';
    }
    if (username.length < 3) {
      return 'Username must be at least 3 characters long.';
    }
    if (username.length > 30) {
      return 'Username cannot exceed 30 characters.';
    }
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(username)) {
      return 'Username can only contain letters, numbers, underscores and hyphens.';
    }
    return null;
  }

  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please enter your email.';
    }
    if (!EmailValidator.validate(email)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter your password.';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least 1 uppercase letter.';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least 1 lowercase letter.';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least 1 number.';
    }
    return null;
  }

  void _loginWithGoogle() {
    setState(() {
      _isLoginWithGoogleLoading = true;
    });

    Future.delayed(Duration(seconds: 2), () async {
      GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
      GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account != null) {
        await _authService.logInWithGoogle(
          context: context,
          account: account,
        );
      }

      if (mounted) {
        setState(() {
          _isLoginWithGoogleLoading = false;
        });
      }
    });
  }

  void _moveToLoginForm() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.setForm(LoginForm());
  }

  void _moveToPinputForm() {
    if (_signUpFormKey.currentState!.validate()) {
      setState(() {
        _isMoveToPinputFormLoading = true;
      });

      Future.delayed(Duration(seconds: 2), () async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        final isSignUpValid = await _authService.validateSignUp(
          context: context,
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (mounted) {
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
          }

          setState(() {
            _isMoveToPinputFormLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return AnimatedBuilder(
      animation: _formAnimationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _formFadeAnimation,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Form(
              key: _signUpFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Welcome text
                  Text(
                    'Create Account',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      color: GlobalVariables.darkGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Join as a ${authProvider.isPlayer ? 'player' : 'manager'} today',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: GlobalVariables.blackGrey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 32),

                  // Username field
                  CustomTextfield(
                    controller: _usernameController,
                    hintText: 'Username',
                    validator: _validateUsername,
                  ),
                  SizedBox(height: 16),

                  // Email field
                  CustomTextfield(
                    controller: _emailController,
                    hintText: 'Email address',
                    isEmail: true,
                    validator: _validateEmail,
                  ),
                  SizedBox(height: 16),

                  // Password field
                  CustomTextfield(
                    controller: _passwordController,
                    isPassword: true,
                    hintText: 'Password',
                    validator: _validatePassword,
                  ),
                  SizedBox(height: 16),

                  // Confirm password field
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
                  SizedBox(height: 32),

                  // Sign up button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: _isMoveToPinputFormLoading
                        ? Center(child: Loader())
                        : ElevatedButton(
                            onPressed: _moveToPinputForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: GlobalVariables.green,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Create Account',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),

                  // Google signup for players only
                  if (authProvider.isPlayer) ...[
                    SizedBox(height: 16),
                    
                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: GlobalVariables.lightGreen)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or',
                            style: GoogleFonts.inter(
                              color: GlobalVariables.blackGrey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: GlobalVariables.lightGreen)),
                      ],
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Google signup button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: _isLoginWithGoogleLoading
                          ? Center(child: Loader())
                          : OutlinedButton(
                              onPressed: _loginWithGoogle,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: GlobalVariables.lightGreen),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/vectors/vector-google.svg',
                                    width: 20,
                                    height: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Sign up with Google',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: GlobalVariables.darkGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],

                  SizedBox(height: 24),

                  // Login link
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: GoogleFonts.inter(
                          color: GlobalVariables.blackGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign in',
                            style: GoogleFonts.inter(
                              color: GlobalVariables.green,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = _moveToLoginForm,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
