import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/common/widgets/loader.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/auth/widgets/reset_password_form.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class PinputForm extends StatefulWidget {
  static bool isUserChangePassword = false;

  const PinputForm({
    super.key,
    required this.isMoveBack,
    required this.isValidateSignUpEmail,
    this.isFromChangePassword = false,
  });

  final bool isMoveBack;
  final bool isValidateSignUpEmail;
  final bool isFromChangePassword;

  @override
  State<PinputForm> createState() => _PinputFormState();
}

class _PinputFormState extends State<PinputForm> {
  final _authService = AuthService();
  var _isSignUpLoading = false;
  var _isResendLoading = false;

  Timer? _timer;
  var _remainingSeconds = 60;
  var _canResend = false;

  final _pinController = TextEditingController();
  final _focusNode = FocusNode();

  final _defaultPinTheme = PinTheme(
    width: 45,
    height: 50,
    textStyle: GoogleFonts.inter(
      fontSize: 20,
      color: GlobalVariables.darkGreen,
      fontWeight: FontWeight.w600,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: GlobalVariables.lightGreen,
        width: 1.5,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
  );

  @override
  void initState() {
    super.initState();
    _startTimer();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    _remainingSeconds = 60;
    _canResend = false;
    
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_remainingSeconds == 0) {
          setState(() {
            _canResend = true;
          });
          timer.cancel();
        } else {
          setState(() {
            _remainingSeconds--;
          });
        }
      },
    );
  }

  void _handleResendEmail() async {
    if (!_canResend || _isResendLoading) return;

    setState(() {
      _isResendLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final email = authProvider.resentEmail;

      bool success;
      if (widget.isValidateSignUpEmail) {
        success = await _authService.validateSignUp(
          context: context,
          username: '',
          email: email,
          password: '',
        );
      } else {
        success = await _authService.validateEmail(
          context: context,
          email: email,
        );
      }

      if (success) {
        _pinController.clear();
        _startTimer();
        
        IconSnackBar.show(
          context,
          maxLines: 2,
          label: 'Verification code sent successfully!',
          snackBarType: SnackBarType.success,
        );
        
        _focusNode.requestFocus();
      }
    } catch (error) {
      IconSnackBar.show(
        context,
        maxLines: 2,
        label: 'Failed to resend code. Please try again.',
        snackBarType: SnackBarType.fail,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResendLoading = false;
        });
      }
    }
  }

  void _verifyPincode(String pin) {
    if (pin.isEmpty || pin.length < 6) return;

    FocusScope.of(context).unfocus();
    _timer?.cancel();

    setState(() {
      _isSignUpLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () async {
      try {
        if (widget.isValidateSignUpEmail) {
          await _signUpUser(pin);
        } else {
          bool isSuccessful = await _authService.verifyCode(
            context: context,
            isSignUp: PinputForm.isUserChangePassword ? false : true,
            pincode: pin,
          );

          if (isSuccessful) {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            
            if (PinputForm.isUserChangePassword || widget.isFromChangePassword) {
              // If from change password, navigate back to previous screen
              PinputForm.isUserChangePassword = false;
              Navigator.of(context).pop();
              return;
            } else {
              // Normal flow - go to reset password
              authProvider.setPreviousForm(
                PinputForm(
                  isMoveBack: true,
                  isValidateSignUpEmail: false,
                ),
              );
              authProvider.setForm(ResetPasswordForm());
            }
          } else {
            _pinController.clear();
            _focusNode.requestFocus();
          }
        }
      } catch (error) {
        IconSnackBar.show(
          context,
          maxLines: 2,
          label: 'Verification failed. Please try again.',
          snackBarType: SnackBarType.fail,
        );
        _pinController.clear();
        _focusNode.requestFocus();
      } finally {
        if (mounted) {
          setState(() {
            _isSignUpLoading = false;
          });
        }
      }
    });
  }

  Future<void> _signUpUser(String pin) async {
    try {
      bool isSuccessful = await _authService.verifyCode(
        context: context,
        isSignUp: !PinputForm.isUserChangePassword,
        pincode: pin,
      );

      if (isSuccessful) {
        _moveToLoginForm();
      } else {
        IconSnackBar.show(
          context,
          maxLines: 2,
          label: 'Invalid verification code. Please try again.',
          snackBarType: SnackBarType.fail,
        );
      }
    } catch (error) {
      IconSnackBar.show(
        context,
        maxLines: 2,
        label: 'Verification failed. Please try again.',
        snackBarType: SnackBarType.fail,
      );
    }
  }

  void _moveToPreviousForm() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Handle different back navigation scenarios
    if (PinputForm.isUserChangePassword || widget.isFromChangePassword) {
      // If from change password, pop the current screen
      PinputForm.isUserChangePassword = false;
      Navigator.of(context).pop();
      return;
    }

    // Use the new handlePinputBack method
    authProvider.handlePinputBack();
  }

  void _moveToLoginForm() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Reset all states and go to login
    PinputForm.isUserChangePassword = false;
    authProvider.forceResetToLogin();
  }

  // Handle system back button
  Future<bool> _onWillPop() async {
    _moveToPreviousForm();
    return false; // Prevent default back behavior
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with context info
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: GlobalVariables.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.email_outlined,
                    color: GlobalVariables.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isFromChangePassword || PinputForm.isUserChangePassword
                            ? 'Verify Identity'
                            : 'Check your email',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          color: GlobalVariables.darkGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.isFromChangePassword || PinputForm.isUserChangePassword
                            ? 'Enter code to change password'
                            : 'Enter the 6-digit code',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: GlobalVariables.blackGrey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Close button for change password flow
                if (widget.isFromChangePassword || PinputForm.isUserChangePassword)
                  IconButton(
                    onPressed: () {
                      PinputForm.isUserChangePassword = false;
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.close,
                      color: GlobalVariables.blackGrey,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 24),

            // Email info
            if (authProvider.resentEmail.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: GlobalVariables.lightGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: GlobalVariables.lightGreen.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: 'We sent a verification code to ',
                        style: GoogleFonts.inter(
                          color: GlobalVariables.blackGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text: authProvider.resentEmail,
                            style: GoogleFonts.inter(
                              color: GlobalVariables.darkGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: _remainingSeconds > 10 
                            ? GlobalVariables.green 
                            : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _canResend 
                            ? 'Code expired' 
                            : 'Code expires in ${_remainingSeconds}s',
                          style: GoogleFonts.inter(
                            color: _remainingSeconds > 10 
                              ? GlobalVariables.green 
                              : Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // PIN Input
            Pinput(
              controller: _pinController,
              focusNode: _focusNode,
              length: 6,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              defaultPinTheme: _defaultPinTheme,
              focusedPinTheme: _defaultPinTheme.copyDecorationWith(
                border: Border.all(
                  color: GlobalVariables.green,
                  width: 2,
                ),
              ),
              submittedPinTheme: _defaultPinTheme.copyDecorationWith(
                border: Border.all(
                  color: GlobalVariables.green,
                  width: 1.5,
                ),
                color: GlobalVariables.green.withOpacity(0.1),
              ),
              showCursor: true,
              onCompleted: _verifyPincode,
            ),

            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _moveToPreviousForm,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: GlobalVariables.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      widget.isFromChangePassword || PinputForm.isUserChangePassword
                          ? 'Cancel'
                          : 'Back',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: GlobalVariables.green,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _isSignUpLoading
                      ? const Center(child: Loader())
                      : ElevatedButton(
                          onPressed: _pinController.text.length == 6
                              ? () => _verifyPincode(_pinController.text)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GlobalVariables.green,
                            disabledBackgroundColor: GlobalVariables.lightGrey,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'Verify',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Resend section (only show if not from change password)
            if (!widget.isFromChangePassword && !PinputForm.isUserChangePassword)
              Center(
                child: Column(
                  children: [
                    if (!_canResend) ...[
                      Text(
                        "Didn't receive the code?",
                        style: GoogleFonts.inter(
                          color: GlobalVariables.blackGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You can resend in ${_remainingSeconds}s',
                        style: GoogleFonts.inter(
                          color: GlobalVariables.blackGrey.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ] else ...[
                      _isResendLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      GlobalVariables.green,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Sending code...',
                                  style: GoogleFonts.inter(
                                    color: GlobalVariables.green,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : GestureDetector(
                              onTap: _handleResendEmail,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: GlobalVariables.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: GlobalVariables.green,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.refresh,
                                      size: 16,
                                      color: GlobalVariables.green,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Resend Code',
                                      style: GoogleFonts.inter(
                                        color: GlobalVariables.green,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
