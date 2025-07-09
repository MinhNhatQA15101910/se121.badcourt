import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/common/widgets/custom_textfield.dart';
import 'package:frontend/common/widgets/loader.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/auth/widgets/forgot_password_form.dart';
import 'package:frontend/features/auth/widgets/sign_up_form.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm>
    with TickerProviderStateMixin {
  final _authService = AuthService();
  var _isLoading = false;
  var _isLoginWithGoogleLoading = false;

  final _loginFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
      return 'Password must be at least 8 characters.';
    }
    return null;
  }

  void _logInUser() {
    if (_loginFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(Duration(seconds: 2), () async {
        var isSuccessful = await _authService.logInUser(
          context: context,
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (isSuccessful) {
            _emailController.clear();
            _passwordController.clear();
          }
        }
      });
    }
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

  void _moveToSignUpForm() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.setForm(SignUpForm());
  }

  void _moveToForgotPasswordForm() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.setPreviousForm(LoginForm());
    authProvider.setForm(ForgotPasswordForm());
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
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12,),
            child: Form(
              key: _loginFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Welcome text
                  Text(
                    'Welcome back!',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      color: GlobalVariables.darkGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sign in to your ${authProvider.isPlayer ? 'player' : 'manager'} account',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: GlobalVariables.blackGrey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 32),

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
                  SizedBox(height: 12),

                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _moveToForgotPasswordForm,
                      child: Text(
                        'Forgot password?',
                        style: GoogleFonts.inter(
                          color: GlobalVariables.green,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: _isLoading
                        ? Center(child: Loader())
                        : ElevatedButton(
                            onPressed: _logInUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: GlobalVariables.green,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Sign In',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),

                  // Google login for players only
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
                    
                    // Google login button
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
                                    'Continue with Google',
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
                    
                    SizedBox(height: 16),
                    
                    // Guest option for players
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        onPressed: () {
                          // Handle guest login
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Continue as Guest',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: GlobalVariables.green,
                          ),
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 24),

                  // Sign up link
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: GoogleFonts.inter(
                          color: GlobalVariables.blackGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign up',
                            style: GoogleFonts.inter(
                              color: GlobalVariables.green,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = _moveToSignUpForm,
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
