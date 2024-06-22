import 'package:flutter/material.dart';

class Separator extends StatelessWidget {
  final double thickness;
  final Color color;
  final EdgeInsetsGeometry margin;
  final Text? text;

  const Separator({
    super.key,
    this.thickness = 0.3,
    this.color = Colors.black,
    this.margin = const EdgeInsets.symmetric(vertical: 4.0),
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10.0),
        Row(
          children: [
            Expanded(
              child: Container(
                height: thickness,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: thickness,
                      color: color,
                    ),
                  ),
                ),
              ),
            ),
            if (text != null) SizedBox(width: 8),
            if (text != null) text!,
            if (text != null) SizedBox(width: 8),
            Expanded(
              child: Container(
                height: thickness,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: thickness,
                      color: color,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.0),
      ],
    );
  }
}
