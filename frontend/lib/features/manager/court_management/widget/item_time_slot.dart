import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_container.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';

class ItemTimeSlot extends StatelessWidget {
  final String timeRange;
  final String price;
  final VoidCallback? onUpdate;
  final VoidCallback? onDelete;

  const ItemTimeSlot({
    super.key,
    required this.timeRange,
    required this.price,
    this.onUpdate,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(timeRange),
      direction: DismissDirection.horizontal,
      background: _buildSwipeActionLeft(),
      secondaryBackground: _buildSwipeActionRight(),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          if (onUpdate != null) {
            onUpdate!();
          }
        } else {
          if (onDelete != null) {
            onDelete!();
          }
        }
      },
      child: GestureDetector(
        child: CustomContainer(
          child: Row(
            children: [
              Expanded(
                child: _mediumSizeText18(timeRange),
              ),
              SizedBox(
                width: 8,
              ),
              _regularSizeText16(price)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeActionLeft() {
    return Container(
      color: GlobalVariables.green,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Icon(
        Icons.edit,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  Widget _buildSwipeActionRight() {
    return Container(
      color: GlobalVariables.red,
      alignment: Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Icon(
        Icons.delete,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  Widget _mediumSizeText18(String text) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: GlobalVariables.blackGrey,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _regularSizeText16(String text) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: GlobalVariables.green,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
