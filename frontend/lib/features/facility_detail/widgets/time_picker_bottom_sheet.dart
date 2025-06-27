import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';

class TimePickerBottomSheet extends StatelessWidget {
  final String title;
  final List<int> values;
  final int selectedValue;
  final Function(int) onSelected;
  final String Function(int) formatValue;

  const TimePickerBottomSheet({
    super.key,
    required this.title,
    required this.values,
    required this.selectedValue,
    required this.onSelected,
    required this.formatValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: GlobalVariables.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 16),
          
          // Title
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: GlobalVariables.blackGrey,
            ),
          ),
          SizedBox(height: 16),
          
          // Grid of values
          Container(
            constraints: BoxConstraints(maxHeight: 300),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2,
              ),
              itemCount: values.length,
              itemBuilder: (context, index) {
                final value = values[index];
                final isSelected = value == selectedValue;
                
                return GestureDetector(
                  onTap: () => onSelected(value),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? GlobalVariables.green 
                          : GlobalVariables.white,
                      border: Border.all(
                        color: isSelected 
                            ? GlobalVariables.green 
                            : GlobalVariables.grey,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        formatValue(value),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected 
                              ? Colors.white 
                              : GlobalVariables.blackGrey,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
