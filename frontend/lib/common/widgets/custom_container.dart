import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final Widget? child;

  CustomContainer({this.child});

  static Widget customContainer({Widget? child}) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 12.0,
        left: 16.0,
        right: 16.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
        ),
        child: Container(
          margin: const EdgeInsets.only(
            top: 12.0,
            left: 16.0,
            right: 16.0,
            bottom: 12,
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return customContainer(child: child);
  }
}
