import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/common/widgets/custom_button.dart';
import 'package:frontend/constants/global_variables.dart'; // Sửa tên import cho đúng
import 'package:google_fonts/google_fonts.dart';

class SortBtmSheet extends StatefulWidget {
  const SortBtmSheet({
    Key? key,
  }) : super(key: key);

  @override
  State<SortBtmSheet> createState() => _SortBtmSheetState();
}

class _SortBtmSheetState extends State<SortBtmSheet> {
  int? _selectedValue = 1;

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        bottom: keyboardSpace,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 24,
                  ),
                  Expanded(
                    child: Container(
                      child: _BoldSizeText('Sort'),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    iconSize: 24,
                    icon: const Icon(
                      Icons.clear,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: GlobalVariables.lightGrey,
              height: 1,
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCustomRadioOption(1, 'Popular'),
                        _buildCustomRadioOption(2, 'Top rating'),
                        _buildCustomRadioOption(3, 'Price: Low to High'),
                        _buildCustomRadioOption(4, 'Price: High to Low'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _BoldSizeText(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _PaddingText(String text) {
    return Container(
      padding: EdgeInsets.only(
        bottom: 8,
        top: 12,
      ),
      child: Text(
        text,
        textAlign: TextAlign.start,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: GlobalVariables.blackGrey,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _PaddingDescription(String text) {
    return Container(
      child: Text(
        text,
        textAlign: TextAlign.start,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: GlobalVariables.darkGrey,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildCustomRadioOption(int value, String title) {
    bool isSelected = _selectedValue == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedValue = value;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? GlobalVariables.lightGreen : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: GlobalVariables.grey,
              width: 1.0,
            ),
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16.0,
                color: GlobalVariables.blackGrey,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: GlobalVariables.green,
              ),
          ],
        ),
      ),
    );
  }
}
