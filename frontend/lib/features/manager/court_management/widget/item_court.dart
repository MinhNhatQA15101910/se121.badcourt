import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_container.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/court_management/services/court_management_service.dart';
import 'package:frontend/features/manager/court_management/widget/add_update_court_btm_sheet.dart';
import 'package:frontend/models/court.dart';
import 'package:google_fonts/google_fonts.dart';

class ItemCourt extends StatefulWidget {
  final Court court;
  final Function(bool) onUpdateSuccess;

  const ItemCourt({
    Key? key,
    required this.court,
    required this.onUpdateSuccess,
  }) : super(key: key);

  @override
  _ItemCourtState createState() => _ItemCourtState();
}

class _ItemCourtState extends State<ItemCourt> {
  final _courtManagementService = CourtManagementService();

  Future<void> deleteCourt() async {
    try {
      await _courtManagementService.deleteCourt(
        context,
        widget.court.id,
      );
      // Gọi callback để cập nhật lại danh sách sau khi xóa thành công
      widget.onUpdateSuccess(true);
    } catch (e) {
      // Xử lý lỗi nếu cần thiết
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        GlobalVariables.court = widget.court;
        showModalBottomSheet<dynamic>(
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
      },
      onLongPress: deleteCourt,
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
            _boldSizeText(widget.court.pricePerHour.toString() + ' đ/h'),
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
