import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_buttom.dart';
import 'package:frontend/common/widgets/custom_textfield.dart';
import 'package:frontend/common/widgets/drop_down_button.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/add_facility/screens/contracts_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class ManagerInfo extends StatefulWidget {
  const ManagerInfo({Key? key}) : super(key: key);
  static const String routeName = '/managerInfo';

  @override
  State<ManagerInfo> createState() => _ManagerInfoState();
}

class _ManagerInfoState extends State<ManagerInfo> {
  final _fullNameController = TextEditingController();
  final _streetNameController = TextEditingController();

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
  List<String> bankList = [
    'Ngân Hàng Quân Đội Việt Nam',
    'Hà Nội',
    'Đà Nẵng',
    'Cần Thơ',
    'Đồng Nai',
  ];

  void _navigateToContractScreen() {
    Navigator.of(context).pushNamed(ContractScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: GlobalVariables.green,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Manager infomation',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.none,
                  color: GlobalVariables.white,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _InterRegular14(
                                  "Manager full name *",
                                  GlobalVariables.darkGrey,
                                  1,
                                ),
                                CustomTextfield(
                                  controller: _fullNameController,
                                  hintText: 'Manager full name',
                                  validator: (fullName) {
                                    if (fullName == null || fullName.isEmpty) {
                                      return 'Please enter your Manager full name.';
                                    }
                                    return null;
                                  },
                                ),
                                _InterRegular14(
                                  "Province *",
                                  GlobalVariables.darkGrey,
                                  1,
                                ),
                                CustomDropdownButton(
                                  items: provinceList,
                                  initialSelectedItem: provinceList[0],
                                  onChanged: (selectedItem) {
                                    print('Selected item: $selectedItem');
                                  },
                                ),
                                _InterRegular14(
                                  "District *",
                                  GlobalVariables.darkGrey,
                                  1,
                                ),
                                CustomDropdownButton(
                                  items: districtList,
                                  initialSelectedItem: districtList[0],
                                  onChanged: (selectedItem) {
                                    print('Selected item: $selectedItem');
                                  },
                                ),
                                _InterRegular14(
                                  "Ward *",
                                  GlobalVariables.darkGrey,
                                  1,
                                ),
                                CustomDropdownButton(
                                  items: wardList,
                                  initialSelectedItem: wardList[0],
                                  onChanged: (selectedItem) {
                                    print('Selected item: $selectedItem');
                                  },
                                ),
                                _InterRegular14(
                                  "Street/ House number",
                                  GlobalVariables.darkGrey,
                                  1,
                                ),
                                CustomTextfield(
                                  controller: _streetNameController,
                                  hintText: 'Street/ House number',
                                  validator: (streetName) {
                                    if (streetName == null ||
                                        streetName.isEmpty) {
                                      return '';
                                    }
                                    return null;
                                  },
                                ),
                                _InterRegular14(
                                  "Email *",
                                  GlobalVariables.darkGrey,
                                  1,
                                ),
                                CustomTextfield(
                                  controller: _streetNameController,
                                  hintText: 'Email',
                                  validator: (streetName) {
                                    if (streetName == null ||
                                        streetName.isEmpty) {
                                      return '';
                                    }
                                    return null;
                                  },
                                ),
                                _InterRegular14(
                                  "Phone number *",
                                  GlobalVariables.darkGrey,
                                  1,
                                ),
                                CustomTextfield(
                                  controller: _streetNameController,
                                  hintText: 'Phone number',
                                  validator: (streetName) {
                                    if (streetName == null ||
                                        streetName.isEmpty) {
                                      return '';
                                    }
                                    return null;
                                  },
                                ),
                                _InterRegular14(
                                  "citizen identification ID *",
                                  GlobalVariables.darkGrey,
                                  1,
                                ),
                                CustomTextfield(
                                  controller: _streetNameController,
                                  hintText: 'citizen identification ID',
                                  validator: (streetName) {
                                    if (streetName == null ||
                                        streetName.isEmpty) {
                                      return '';
                                    }
                                    return null;
                                  },
                                ),
                                _InterRegular14(
                                  "Photos of citizen identification card (Includes front and back) *",
                                  GlobalVariables.darkGrey,
                                  2,
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: GestureDetector(
                                          onTap: () {
                                            // Handle button tap
                                            print('Button tapped!');
                                          },
                                          child: Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: GlobalVariables.lightGrey,
                                              borderRadius: BorderRadius.circular(
                                                  10), // Adjust border radius here
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons
                                                    .add_photo_alternate_outlined,
                                                color: GlobalVariables.darkGrey,
                                                size: 36,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: GestureDetector(
                                          onTap: () {
                                            // Handle button tap
                                            print('Button tapped!');
                                          },
                                          child: Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: GlobalVariables.lightGrey,
                                              borderRadius: BorderRadius.circular(
                                                  10), // Adjust border radius here
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons
                                                    .add_photo_alternate_outlined,
                                                color: GlobalVariables.darkGrey,
                                                size: 36,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _InterRegular14(
                                  "Bank name *",
                                  GlobalVariables.darkGrey,
                                  2,
                                ),
                                CustomDropdownButton(
                                  items: bankList,
                                  initialSelectedItem: bankList[0],
                                  onChanged: (selectedItem) {
                                    print('Selected item: $selectedItem');
                                  },
                                ),
                                _InterRegular14(
                                  "Bank account number *",
                                  GlobalVariables.darkGrey,
                                  2,
                                ),
                                CustomTextfield(
                                  controller: _fullNameController,
                                  hintText: '0000 0000 0000 0000',
                                  validator: (fullName) {
                                    if (fullName == null || fullName.isEmpty) {
                                      return '';
                                    }
                                    return null;
                                  },
                                ),
                                _InterRegular14(
                                  "Photos of bank card (Includes front and back) *",
                                  GlobalVariables.darkGrey,
                                  2,
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: GestureDetector(
                                          onTap: () {
                                            // Handle button tap
                                            print('Button tapped!');
                                          },
                                          child: Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: GlobalVariables.lightGrey,
                                              borderRadius: BorderRadius.circular(
                                                  10), // Adjust border radius here
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons
                                                    .add_photo_alternate_outlined,
                                                color: GlobalVariables.darkGrey,
                                                size: 36,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: GestureDetector(
                                          onTap: () {
                                            // Handle button tap
                                            print('Button tapped!');
                                          },
                                          child: Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: GlobalVariables.lightGrey,
                                              borderRadius: BorderRadius.circular(
                                                  10), // Adjust border radius here
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons
                                                    .add_photo_alternate_outlined,
                                                color: GlobalVariables.darkGrey,
                                                size: 36,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _InterRegular14(
                                  "Photos of business license (Maximum 10 photo) *",
                                  GlobalVariables.darkGrey,
                                  2,
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: GestureDetector(
                                          onTap: () {
                                            // Handle button tap
                                            print('Button tapped!');
                                          },
                                          child: Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: GlobalVariables.lightGrey,
                                              borderRadius: BorderRadius.circular(
                                                  10), // Adjust border radius here
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons
                                                    .add_photo_alternate_outlined,
                                                color: GlobalVariables.darkGrey,
                                                size: 36,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _InterRegular14(
                                  "Photo of tax code *",
                                  GlobalVariables.darkGrey,
                                  2,
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: GestureDetector(
                                          onTap: () {
                                            // Handle button tap
                                            print('Button tapped!');
                                          },
                                          child: Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: GlobalVariables.lightGrey,
                                              borderRadius: BorderRadius.circular(
                                                  10), // Adjust border radius here
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons
                                                    .add_photo_alternate_outlined,
                                                color: GlobalVariables.darkGrey,
                                                size: 36,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _InterRegular14(
                                  "Photos of relevant documents",
                                  GlobalVariables.darkGrey,
                                  2,
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: GestureDetector(
                                          onTap: () {
                                            // Handle button tap
                                            print('Button tapped!');
                                          },
                                          child: Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: GlobalVariables.lightGrey,
                                              borderRadius: BorderRadius.circular(
                                                  10), // Adjust border radius here
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons
                                                    .add_photo_alternate_outlined,
                                                color: GlobalVariables.darkGrey,
                                                size: 36,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: CustomButton(
                        onTap: _navigateToContractScreen,
                        buttonText: 'Next',
                        borderColor: GlobalVariables.green,
                        fillColor: GlobalVariables.green,
                        textColor: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
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
