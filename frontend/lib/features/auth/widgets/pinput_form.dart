import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/auth/widgets/login_form.dart';
import 'package:frontend/features/auth/widgets/reset_password_form.dart';
import 'package:frontend/providers/auth_form_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class PinputForm extends StatefulWidget {
  const PinputForm({super.key});

  @override
  State<PinputForm> createState() => _PinputFormState();
}

class _PinputFormState extends State<PinputForm> {
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

  void _verifyPincode(String pin) {
    // TODO: Verify pincode and navigate to reset password form.

    if (pin.isEmpty) {
      return;
    }

    final authFormProvider = Provider.of<AuthFormProvider>(
      context,
      listen: false,
    );

    authFormProvider.setPreviousForm(
      PinputForm(),
    );

    authFormProvider.setForm(
      ResetPasswordForm(),
    );
  }

  void _moveToPreviousForm() {
    final authFormProvider = Provider.of<AuthFormProvider>(
      context,
      listen: false,
    );

    authFormProvider.setForm(
      authFormProvider.previousForm,
    );

    authFormProvider.setPreviousForm(
      LoginForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authFormProvider = Provider.of<AuthFormProvider>(
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
                    text: authFormProvider.resentEmail,
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
                    text: '60s',
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
                  child: ElevatedButton(
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
