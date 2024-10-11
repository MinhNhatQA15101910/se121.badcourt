import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';

class MultipleImagePickerButton extends StatelessWidget {
  const MultipleImagePickerButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: GlobalVariables.lightGrey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Icon(
            Icons.add_photo_alternate_outlined,
            color: GlobalVariables.darkGrey,
            size: 36,
          ),
        ),
      ),
    );
  }
}
