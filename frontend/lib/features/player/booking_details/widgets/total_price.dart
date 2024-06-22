import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_container.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';

class TotalPrice extends StatelessWidget {
  final double promotionPrice;
  final double subTotalPrice;

  const TotalPrice({
    required this.promotionPrice,
    required this.subTotalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: _semiBoldSizeText('Price'),
                ),
                SizedBox(
                  width: 8,
                ),
                _boldSizeText('\$' + subTotalPrice.toStringAsFixed(2))
              ],
            ),
          ),
          Container(
            height: 1,
            color: GlobalVariables.lightGrey,
          ),
          Container(
            height: 1,
            color: GlobalVariables.lightGrey,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: _semiBoldSizeText('Promotion'),
                ),
                SizedBox(
                  width: 8,
                ),
                _boldGreenSizeText('- \$' + promotionPrice.toStringAsFixed(2))
              ],
            ),
          ),
          Container(
            height: 1,
            color: GlobalVariables.lightGrey,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _semiBoldSizeText('Total price'),
                      SizedBox(
                        height: 4,
                      ),
                      _detailText('Included VAT'),
                    ],
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                _boldSizeText(
                    '\$' + (subTotalPrice - promotionPrice).toStringAsFixed(2))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _boldSizeText(String text) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _boldGreenSizeText(String text) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: GlobalVariables.green,
        fontSize: 14,
        fontWeight: FontWeight.w700,
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
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
