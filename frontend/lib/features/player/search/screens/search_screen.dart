import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/player/search/screens/search_by_location_screen.dart';
import 'package:frontend/features/player/search/widgets/filter_btm_sheet.dart';
import 'package:frontend/features/player/search/widgets/sort_btm_sheet.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  
  void _navigateToSearchByLocationScreen() {
    Navigator.of(context).pushNamed(SearchByLocationScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: GlobalVariables.green,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'SEARCH',
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
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 12,
                        left: 16,
                        right: 16,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Find badminton facilities',
                                hintStyle: GoogleFonts.inter(
                                  color: GlobalVariables.darkGrey,
                                  fontSize: 16,
                                ),
                                contentPadding: const EdgeInsets.all(16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: GlobalVariables.lightGreen,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: GlobalVariables.lightGreen,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: GlobalVariables.darkGrey,
                                ),
                              ),
                              style: GoogleFonts.inter(
                                fontSize: 16,
                              ),
                              validator: (facilityName) {
                                if (facilityName == null ||
                                    facilityName.isEmpty) {
                                  return 'Please enter your facility name.';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          GestureDetector(
                            onTap: _navigateToSearchByLocationScreen,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: GlobalVariables.grey,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.location_on_outlined,
                                  size: 32,
                                  color: GlobalVariables.green,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        top: 12,
                        left: 16,
                        right: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => {
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
                                    child: FilterBtmSheet(),
                                  );
                                },
                              ),
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: GlobalVariables.grey,
                                ),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.filter_alt_outlined,
                                    size: 24,
                                    color: GlobalVariables.darkGrey,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  _InterRegular14(
                                    'Filter',
                                    GlobalVariables.blackGrey,
                                    1,
                                  )
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => {
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
                                    child: SortBtmSheet(),
                                  );
                                },
                              ),
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: GlobalVariables.green,
                                ),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                children: [
                                  Transform.rotate(
                                    angle: 90 * 3.1415926535897932 / 180,
                                    child: Icon(
                                      Icons.sync_alt_outlined,
                                      size: 20,
                                      color: GlobalVariables.green,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  _InterRegular14(
                                    'Popular',
                                    GlobalVariables.green,
                                    1,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    )
                  ],
                ),
              ),
              Container(
                height: 12,
                color: GlobalVariables.defaultColor,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                /*child: GridView.builder(
                  itemCount: 10,
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3 / 5,
                  ),
                  itemBuilder: (context, index) {
                    return const SingleFacilityCard();
                  },
                  physics: const NeverScrollableScrollPhysics(),
                ),*/
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _InterRegular14(String text, Color color, int maxLines) {
    return Container(
      padding: EdgeInsets.only(
        top: 4,
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
