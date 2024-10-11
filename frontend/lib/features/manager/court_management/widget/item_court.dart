import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_container.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/court_management/services/court_management_service.dart';
import 'package:frontend/features/manager/court_management/widget/add_update_court_btm_sheet.dart';
import 'package:frontend/models/court.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ItemCourt extends StatefulWidget {
  final Court court;
  final Function(Court) updateCourt;
  final VoidCallback deleteCourt;

  const ItemCourt({
    super.key,
    required this.court,
    required this.updateCourt,
    required this.deleteCourt,
  });

  @override
  State<ItemCourt> createState() => _ItemCourtState();
}

class _ItemCourtState extends State<ItemCourt> {
  void _updateCourt() async {
    Court? updatedCourt = await showModalBottomSheet<Court>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: AddUpdateCourtBottomSheet(
            court: widget.court,
          ),
        );
      },
    );

    if (updatedCourt != null) {
      widget.updateCourt(updatedCourt);
    }
  }

  void _deleteCourt() async {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Delete court confirm'),
          content: const Text('Are you sure to delete this court?'),
          actions: [
            // The "Yes" button
            TextButton(
              onPressed: () async {
                final courtManagementService = CourtManagementService();
                courtManagementService.deleteCourt(
                  context,
                  widget.court.id,
                );
                widget.deleteCourt();

                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
            // The "No" button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _updateCourt,
      onLongPress: _deleteCourt,
      child: CustomContainer(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _semiBoldSizeText(widget.court.name),
                  _detailText(widget.court.description),
                ],
              ),
            ),
            SizedBox(
              width: 8,
            ),
            _boldSizeText(
              '${NumberFormat.currency(
                locale: 'vi_VN',
                symbol: 'đ',
              ).format(widget.court.pricePerHour)}/h',
            ),
          ],
        ),
      ),
    );
  }

  Widget _semiBoldSizeText(String text) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _boldSizeText(String text) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _detailText(String text) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: GlobalVariables.darkGrey,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
