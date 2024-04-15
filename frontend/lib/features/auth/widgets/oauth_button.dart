import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/constants/global_variables.dart';

class OAuthButton extends StatelessWidget {
  const OAuthButton({
    super.key,
    required this.assetName,
    required this.onPressed,
  });

  final String assetName;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        child: SvgPicture.asset(
          assetName,
          width: 32,
          height: 32,
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: GlobalVariables.lightGrey,
          elevation: 0,
        ),
      ),
    );
  }
}
