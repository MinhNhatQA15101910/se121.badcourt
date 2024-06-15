import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_buttom.dart';
import 'package:frontend/common/widgets/custom_textfield.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numberpicker/numberpicker.dart';

class AddUpdateCourtBottomSheet extends StatefulWidget {
  const AddUpdateCourtBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddUpdateCourtBottomSheet> createState() =>
      _AddUpdateCourtBottomSheetState();
}

class _AddUpdateCourtBottomSheetState extends State<AddUpdateCourtBottomSheet> {
  final _courtNameController = TextEditingController();
  final _courtDescController = TextEditingController();

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 24,
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      top: 8,
                    ),
                    child: Expanded(
                      child: _BoldSizeText('Add a court'),
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
            Divider(
              color: GlobalVariables.lightGrey,
              thickness: 1.0,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InterRegular14(
                    "Court name *",
                    GlobalVariables.darkGrey,
                    1,
                  ),
                  CustomTextfield(
                    controller: _courtNameController,
                    hintText: 'Court name',
                    validator: (streetName) {
                      if (streetName == null || streetName.isEmpty) {
                        return 'Court name is empty';
                      }
                      return null;
                    },
                  ),
                  _InterRegular14(
                    "Description",
                    GlobalVariables.darkGrey,
                    1,
                  ),
                  CustomTextfield(
                    controller: _courtDescController,
                    hintText: 'Description',
                    validator: (streetName) {
                      if (streetName == null || streetName.isEmpty) {
                        return '';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 12,
                  )
                ],
              ),
            ),
            Divider(
              color: GlobalVariables.grey,
              thickness: 1,
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      onTap: () => Navigator.pop(context),
                      buttonText: 'Cancel',
                      borderColor: GlobalVariables.green,
                      fillColor: Colors.white,
                      textColor: GlobalVariables.green,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: CustomButton(
                      onTap: () {},
                      buttonText: 'Add',
                      borderColor: GlobalVariables.green,
                      fillColor: GlobalVariables.green,
                      textColor: Colors.white,
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

  Widget _SemiBoldBlack40(String text) {
    return Container(
      padding: EdgeInsets.only(
        bottom: 14,
        top: 8,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: GlobalVariables.blackGrey,
          fontSize: 40,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _InterRegular14(String text, Color color, int maxLines) {
    return Container(
      padding: EdgeInsets.only(
        bottom: 8,
        top: 12,
      ),
      child: Text(
        text,
        textAlign: TextAlign.start,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
