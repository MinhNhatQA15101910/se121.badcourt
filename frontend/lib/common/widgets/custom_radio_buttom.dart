import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomRadioButton extends StatelessWidget {
  final List<String> choices;
  final ValueChanged<String> onSelected;
  final String selectedChoice;

  CustomRadioButton({
    required this.choices,
    required this.onSelected,
    required this.selectedChoice,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: choices.map((choice) {
          bool isSelected = selectedChoice == choice;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: InkWell(
              onTap: () {
                onSelected(choice);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isSelected
                      ? GlobalVariables.green
                      : GlobalVariables.white,
                  border: Border.all(color: GlobalVariables.green),
                ),
                child: Text(
                  choice,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: isSelected
                        ? GlobalVariables.white
                        : GlobalVariables.black,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
