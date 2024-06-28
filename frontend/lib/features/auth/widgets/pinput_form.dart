import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/common/widgets/loader.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/auth/widgets/login_form.dart';
import 'package:frontend/features/auth/widgets/reset_password_form.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class PinputForm extends StatefulWidget {
  const PinputForm({
    super.key,
    required this.isMoveBack,
    required this.isValidateSignUpEmail,
  });

  final bool isMoveBack;
  final bool isValidateSignUpEmail;

  @override
  State<PinputForm> createState() => _PinputFormState();
}

class _PinputFormState extends State<PinputForm> {
  final _authService = AuthService();
  var _isSignUpLoading = false;

  Timer? _timer;
  var _remainingSeconds = 60;

  String? _pincode;
  final _pinController = TextEditingController();

  final _defaultPinTheme = PinTheme(
    width: 34.5,
    height: 42,
    textStyle: GoogleFonts.inter(
      fontSize: 18,
      color: GlobalVariables.pinputColor,
      fontWeight: FontWeight.w600,
    ),
    decoration: BoxDecoration(
      border: Border.all(
        color: GlobalVariables.blackGrey,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
  );

  String _generateRandomNumberString() {
    Random random = Random();

    String randomNumberString = '';
    for (int i = 0; i < 6; i++) {
      int randomNumber = random.nextInt(10);
      randomNumberString += randomNumber.toString();
    }

    return randomNumberString;
  }

  void _verifyPincode(String pin) {
    if (pin.isEmpty) {
      return;
    }

    if (pin != _pincode) {
      IconSnackBar.show(
        context,
        label: 'Incorrect pincode.',
        snackBarType: SnackBarType.fail,
      );
      return;
    }

    _timer!.cancel();

    setState(() {
      _isSignUpLoading = true;
    });

    Future.delayed(Duration(seconds: 2), () async {
      if (widget.isValidateSignUpEmail) {
        _signUpUser();
      } else {
        final authProvider = Provider.of<AuthProvider>(
          context,
          listen: false,
        );

        authProvider.setPreviousForm(
          PinputForm(
            isMoveBack: true,
            isValidateSignUpEmail: false,
          ),
        );

        authProvider.setForm(
          ResetPasswordForm(),
        );
      }

      setState(() {
        _isSignUpLoading = false;
      });
    });
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
      LoginForm(),
    );
  }

  void _moveToLoginForm() {
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    authProvider.setForm(LoginForm());
  }

  void _sendVerifyEmail() async {
    _pincode = _generateRandomNumberString();
    var email = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).resentEmail;

    await _authService.sendVerifyEmail(
      context: context,
      email: email,
      pincode: _pincode!,
    );
  }

  void _startTimer() {
    const duration = Duration(seconds: 1);
    _timer = Timer.periodic(
      duration,
      (timer) {
        if (_remainingSeconds == 0) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Email verify timeout'),
              content: const Text(
                'You must enter your verify code before the time is over.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          _moveToPreviousForm();
        } else {
          setState(() {
            _remainingSeconds--;
          });
        }
      },
    );
  }

  void _signUpUser() {
    Future.delayed(Duration(seconds: 2), () async {
      User signUpUser = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).signUpUser;

      bool isSuccessful = await _authService.signUpUser(
        context: context,
        username: signUpUser.username,
        email: signUpUser.email,
        password: signUpUser.password,
      );

      if (isSuccessful) {
        _moveToLoginForm();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (!widget.isMoveBack) {
      _sendVerifyEmail();
    }
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Check your email text
            Text(
              'Check your email',
              style: GoogleFonts.inter(
                fontSize: 26,
                color: GlobalVariables.darkGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),

            // Long text 1
            RichText(
              text: TextSpan(
                text: 'We sent a reset email to ',
                style: GoogleFonts.inter(
                  color: GlobalVariables.blackGrey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: authProvider.resentEmail,
                    style: GoogleFonts.inter(
                      color: GlobalVariables.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 8),

            RichText(
              text: TextSpan(
                text: 'enter 6 digits code mentioned in the email - ',
                style: GoogleFonts.inter(
                  color: GlobalVariables.blackGrey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: '${_remainingSeconds}s',
                    style: GoogleFonts.inter(
                      color: GlobalVariables.green,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Pinput
            Pinput(
              controller: _pinController,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              length: 6,
              defaultPinTheme: _defaultPinTheme,
              focusedPinTheme: _defaultPinTheme.copyDecorationWith(
                border: Border.all(
                  color: GlobalVariables.green,
                ),
              ),
              submittedPinTheme: _defaultPinTheme.copyDecorationWith(
                border: Border.all(
                  color: GlobalVariables.green,
                ),
              ),
              showCursor: true,
              onCompleted: (pin) => _verifyPincode(pin),
            ),
            const SizedBox(height: 36),

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
                  child: _isSignUpLoading
                      ? const Loader()
                      : ElevatedButton(
                          onPressed: () => _verifyPincode(_pinController.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GlobalVariables.green,
                            elevation: 0,
                          ),
                          child: Text(
                            'Verify',
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
            const SizedBox(height: 16),

            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {},
                child: RichText(
                  textAlign: TextAlign.right,
                  text: TextSpan(
                    text: 'Haven\'t received the code yet? ',
                    style: GoogleFonts.inter(
                      color: GlobalVariables.darkGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                    children: [
                      TextSpan(
                        text: 'Resend email',
                        style: GoogleFonts.inter(
                          color: GlobalVariables.darkGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = _sendVerifyEmail,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}
