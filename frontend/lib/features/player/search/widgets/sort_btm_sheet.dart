import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_button.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/providers/sort_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class SortBtmSheet extends StatefulWidget {
  const SortBtmSheet({
    super.key,
    required this.sortProvider,
    required this.onDoneSort,
  });

  final SortProvider sortProvider;
  final VoidCallback onDoneSort;

  @override
  State<SortBtmSheet> createState() => _SortBtmSheetState();
}

class _SortBtmSheetState extends State<SortBtmSheet> {
  Sort _selectedValue = Sort.location_asc;

  void _confirmSort() {
    Navigator.of(context).pop();

    widget.sortProvider.setSort(_selectedValue);
    widget.onDoneSort();
  }

  @override
  void initState() {
    _selectedValue = widget.sortProvider.sort;
    super.initState();
  }

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
                      child: _boldSizeText('Sort'),
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
                        _buildCustomRadioOption(
                          Sort.location_asc,
                        ),
                        _buildCustomRadioOption(
                          Sort.location_desc,
                        ),
                        _buildCustomRadioOption(
                          Sort.registered_at_asc,
                        ),
                        _buildCustomRadioOption(
                          Sort.registered_at_desc,
                        ),
                        _buildCustomRadioOption(
                          Sort.price_asc,
                        ),
                        _buildCustomRadioOption(
                          Sort.price_desc,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      child: CustomButton(
                        onTap: () => Navigator.pop(context),
                        buttonText: 'Cancel',
                        borderColor: GlobalVariables.green,
                        fillColor: Colors.white,
                        textColor: GlobalVariables.green,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      child: CustomButton(
                        onTap: _confirmSort,
                        buttonText: 'Confirm',
                        borderColor: GlobalVariables.green,
                        fillColor: GlobalVariables.green,
                        textColor: Colors.white,
                      ),
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

  Widget _boldSizeText(String text) {
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

  Widget _buildCustomRadioOption(Sort value) {
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
              value.value,
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
