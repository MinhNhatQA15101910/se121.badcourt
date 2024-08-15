import 'dart:io';

import 'package:flutter/material.dart';

class SelectedImages extends StatefulWidget {
  const SelectedImages({
    super.key,
    required this.images,
  });

  final List<File> images;

  @override
  State<SelectedImages> createState() => _SelectedImagesState();
}

class _SelectedImagesState extends State<SelectedImages> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: widget.images
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Stack(
                children: [
                  Image.file(
                    entry.value,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          widget.images.removeAt(entry.key);
                        });
                      },
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
              ),
            ),
          )
          .toList(),
    );
  }
}
