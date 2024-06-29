import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/court_management/screen/court_management_detail_screen.dart';
import 'package:frontend/features/manager/court_management/widget/add_update_court_btm_sheet.dart';
import 'package:frontend/features/manager/court_management/widget/item_court.dart';
import 'package:google_fonts/google_fonts.dart';

class CourtManagementScreen extends StatefulWidget {
  const CourtManagementScreen({super.key});

  @override
  State<CourtManagementScreen> createState() => _CourtManagementScreenState();
}

class _CourtManagementScreenState extends State<CourtManagementScreen> {
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
                onPressed: () => {},
                iconSize: 24,
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: GlobalVariables.white,
                ),
              ),
              IconButton(
                onPressed: () => {},
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
                    padding: EdgeInsets.only(
                      bottom: 12,
                      left: 16,
                      right: 16,
                    ),
                    color: GlobalVariables.white,
                    child: Expanded(
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
                  ),
                  ItemCourt(
                    title: "Court 1",
                    description: 'With covered',
                  ),
                  ItemCourt(
                    title: "Court 2",
                    description: 'With covered',
                  ),
                  ItemCourt(
                    title: "Court 3",
                    description: 'With covered',
                  ),
                  ItemCourt(title: "Court 4", description: 'With covered'),
                  SizedBox(
                    height: 12,
                  )
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
                  icon: Icon(
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
                            StateText: 'Add',
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
      padding: EdgeInsets.only(
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
}
