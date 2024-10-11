import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';

class ImagePickerButton extends StatefulWidget {
  const ImagePickerButton({
    super.key,
    required this.image,
    required this.onTap,
    required this.onClear,
  });

  final VoidCallback onTap;
  final File? image;
  final VoidCallback? onClear;

  @override
  State<ImagePickerButton> createState() => _ImagePickerButtonState();
}

class _ImagePickerButtonState extends State<ImagePickerButton> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: GlobalVariables.lightGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: widget.image == null
                ? Center(
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      color: GlobalVariables.darkGrey,
                      size: 36,
                    ),
                  )
                : Image.file(
                    widget.image!,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        if (widget.image != null && widget.onClear != null)
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: widget.onClear,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.clear,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
