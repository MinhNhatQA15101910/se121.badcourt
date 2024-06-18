import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_button.dart';
import 'package:frontend/common/widgets/drop_down_button.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterBtmSheet extends StatefulWidget {
  const FilterBtmSheet({
    Key? key,
  }) : super(key: key);

  @override
  State<FilterBtmSheet> createState() => _FilterBtmSheetState();
}

class _FilterBtmSheetState extends State<FilterBtmSheet> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  late List<bool> _selectedPriceRange;

  @override
  void initState() {
    super.initState();
    _selectedPriceRange = List.generate(priceRangeList.length, (_) => false);
  }

  List<String> provinceList = [
    'TP Hồ Chí Minh',
    'Hà Nội',
    'Đà Nẵng',
    'Cần Thơ',
    'Đồng Nai',
  ];
  List<String> districtList = [
    'TP Hồ Chí Minh',
    'Hà Nội',
    'Đà Nẵng',
    'Cần Thơ',
    'Đồng Nai',
  ];
  List<String> wardList = [
    'TP Hồ Chí Minh',
    'Hà Nội',
    'Đà Nẵng',
    'Cần Thơ',
    'Đồng Nai',
  ];

  static const List<Widget> priceRangeList = [
    Text('Under 100.000đ'),
    Text('100.000đ - 200.000đ'),
    Text('200.000đ - 750.000đ'),
    Text('Over 750.000đ'),
  ];
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
                      child: _BoldSizeText('Filter'),
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
              padding: EdgeInsets.only(
                bottom: 12,
                left: 16,
                right: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PaddingText('Price'),
                  Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    runAlignment: WrapAlignment.spaceEvenly,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: List.generate(
                      priceRangeList.length,
                      (index) => _buildToggleButton(
                          index, priceRangeList, _selectedPriceRange),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  _PaddingDescription('Or enter a price range'),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _PaddingText('From'),
                            TextFormField(
                              controller: _fromController,
                              decoration: InputDecoration(
                                hintText: 'Lowest price',
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
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    ' \$',
                                    style: GoogleFonts.inter(
                                      color: GlobalVariables.blackGrey,
                                      fontSize: 16,
                                    ),
                                  ),
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
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _PaddingText('To'),
                            TextFormField(
                              controller: _toController,
                              decoration: InputDecoration(
                                hintText: 'Highest price',
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
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    ' \$',
                                    style: GoogleFonts.inter(
                                      color: GlobalVariables.blackGrey,
                                      fontSize: 16,
                                    ),
                                  ),
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
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      top: 12,
                    ),
                    child: Container(
                      height: 1,
                      color: GlobalVariables.grey,
                    ),
                  ),
                  _PaddingText('Choose location'),
                  _PaddingDescription('Province'),
                  SizedBox(
                    height: 8,
                  ),
                  CustomDropdownButton(
                    items: provinceList,
                    initialSelectedItem: provinceList[0],
                    onChanged: (selectedItem) {
                      print('Selected item: $selectedItem');
                    },
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  _PaddingDescription('District'),
                  SizedBox(
                    height: 8,
                  ),
                  CustomDropdownButton(
                    items: districtList,
                    initialSelectedItem: districtList[0],
                    onChanged: (selectedItem) {
                      print('Selected item: $selectedItem');
                    },
                  ),
                ],
              ),
            ),
            Divider(
              color: GlobalVariables.defaultColor,
              thickness: 12.0,
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
                        onTap: () {},
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

  Widget _PaddingText(String text) {
    return Container(
      padding: EdgeInsets.only(
        bottom: 8,
        top: 12,
      ),
      child: Text(
        text,
        textAlign: TextAlign.start,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: GlobalVariables.blackGrey,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _PaddingDescription(String text) {
    return Container(
      child: Text(
        text,
        textAlign: TextAlign.start,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: GlobalVariables.darkGrey,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildToggleButton(
      int index, List<Widget> selectedList, List<bool> selectedListState) {
    return Container(
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            selectedListState[index] = !selectedListState[index];
          });
        },
        style: OutlinedButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
          foregroundColor: selectedListState[index]
              ? GlobalVariables.green
              : GlobalVariables.blackGrey,
          side: BorderSide(
            width: 1.5,
            color: selectedListState[index]
                ? GlobalVariables.green
                : GlobalVariables.grey,
          ),
        ),
        child: selectedList[index],
      ),
    );
  }
}
