import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDropdownButton extends StatefulWidget {
  final List<String>? items;
  final String initialSelectedItem;
  final ValueChanged<String> onChanged;

  const CustomDropdownButton({
    Key? key,
    required this.items,
    required this.initialSelectedItem,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<CustomDropdownButton> createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {
  late String dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.initialSelectedItem;
  }

  @override
  Widget build(BuildContext context) {
    List<String> items = widget.items ?? ['No Item found'];
    return Container(
      height: 48,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: GlobalVariables.darkGrey,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: dropdownValue,
          icon: Icon(Icons.keyboard_arrow_down, size: 24),
          elevation: 16,
          style: GoogleFonts.inter(
            color: GlobalVariables.darkGrey,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          onChanged: (String? value) {
            setState(() {
              dropdownValue = value!;
              widget.onChanged(value);
            });
          },
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: SizedBox(
                child: Center(
                  child: Text(
                    value,
                    style: GoogleFonts.inter(
                      color: GlobalVariables.darkGrey,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
