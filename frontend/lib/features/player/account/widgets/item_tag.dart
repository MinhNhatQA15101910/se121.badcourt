import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';

class ItemTag extends StatelessWidget {
  final String title;
  final String description;
  final String? imgPath;
  final IconData? iconData;
  final bool isVisibleArrow;
  final VoidCallback onTap;

  const ItemTag({
    super.key,
    required this.title,
    required this.description,
    required this.onTap,
    this.isVisibleArrow = false,
    this.imgPath,
    this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          if (imgPath != null)
            Image.asset(
              imgPath!,
              width: 40,
              height: 40,
            ),
          if (iconData != null)
            SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: Icon(
                  iconData,
                  size: 24,
                  color: Colors.black,
                ),
              ),
            ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _semiBoldSizeText(title),
                SizedBox(height: 4),
                _detailText(description),
              ],
            ),
          ),
          if (isVisibleArrow)
            SizedBox(
              width: 24,
              height: 40,
              child: Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.navigate_next,
                  size: 20,
                  color: GlobalVariables.darkGrey,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _semiBoldSizeText(String text) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _detailText(String text) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: GlobalVariables.darkGrey,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
