import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/court_management/services/court_management_service.dart';
import 'package:frontend/features/manager/court_management/widget/add_update_court_btm_sheet.dart';
import 'package:frontend/features/manager/court_management/widget/day_picker.dart';
import 'package:frontend/features/manager/court_management/widget/item_court.dart';
import 'package:frontend/features/manager/court_management/widget/time_slot_btm_sheet.dart';
import 'package:frontend/models/court.dart';
import 'package:google_fonts/google_fonts.dart';

class CourtManagementScreen extends StatefulWidget {
  const CourtManagementScreen({Key? key}) : super(key: key);

  @override
  State<CourtManagementScreen> createState() => _CourtManagementScreenState();
}

class _CourtManagementScreenState extends State<CourtManagementScreen> {
  final _courtManagementService = CourtManagementService();
  List<Court> _courts = [];

  void _updateSuccessCallback(bool success) {
    if (success) {
      fetchCourtByFacilityId(); // Cập nhật danh sách sân sau khi xóa thành công
    }
    setState(() {});
  }

  Future<void> fetchCourtByFacilityId() async {
    final courts = await _courtManagementService.fetchCourtByFacilityId(
      context,
      GlobalVariables.facility.id,
    );
    setState(() {
      _courts = courts;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCourtByFacilityId(); // Lấy danh sách sân khi khởi động màn hình
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: GlobalVariables.green,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'COURTS',
                  style: GoogleFonts.alfaSlabOne(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none,
                    color: GlobalVariables.white,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                iconSize: 24,
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: GlobalVariables.white,
                ),
              ),
              IconButton(
                onPressed: () {},
                iconSize: 24,
                icon: const Icon(
                  Icons.message_outlined,
                  color: GlobalVariables.white,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: double.maxFinite,
            color: GlobalVariables.defaultColor,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            GlobalVariables.facility.imageUrls.first),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: AspectRatio(
                      aspectRatio: 2 / 1,
                    ),
                  ),
                  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.only(
                      bottom: 12,
                      left: 16,
                      right: 16,
                    ),
                    color: GlobalVariables.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InterRegular18(
                          GlobalVariables.facility.name,
                          GlobalVariables.blackGrey,
                          1,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 1,
                    color: GlobalVariables.grey,
                  ),
                  DayPicker(),
                  GestureDetector(
                    onTap: () {
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
                            child: TimeSlotBottomSheet(),
                          );
                        },
                      );
                    },
                    child: Container(
                      color: GlobalVariables.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: _semiBoldSizeText('Time range:'),
                          ),
                          _boldSizeText('7:30 to 19:30'),
                          SizedBox(
                            width: 8,
                          ),
                          Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 12, left: 16, right: 16),
                    child: _titleText('Number of courts'),
                  ),
                  ..._courts
                      .map((court) => ItemCourt(
                            court: court,
                            onUpdateSuccess: _updateSuccessCallback,
                          ))
                      .toList(),
                  const SizedBox(
                    height: 12,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: GlobalVariables.green,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.library_add_outlined,
                    color: GlobalVariables.white,
                    size: 24,
                  ),
                  onPressed: () {
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
                            stateText: 'Add',
                            onUpdateSuccess: _updateSuccessCallback,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _InterRegular18(String text, Color color, int maxLines) {
    return Container(
      padding: const EdgeInsets.only(
        top: 12,
      ),
      child: Text(
        text,
        textAlign: TextAlign.start,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.w400,
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
        fontSize: 16,
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

  Widget _titleText(String text) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
