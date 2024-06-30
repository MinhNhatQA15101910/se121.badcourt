import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_button.dart';
import 'package:frontend/common/widgets/drop_down_button.dart';
import 'package:frontend/common/widgets/loader.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/player/search/services/search_service.dart';
import 'package:frontend/providers/filter_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterBtmSheet extends StatefulWidget {
  const FilterBtmSheet({
    super.key,
    required this.filterProvider,
    required this.onDoneFilter,
  });

  final FilterProvider filterProvider;
  final VoidCallback onDoneFilter;

  @override
  State<FilterBtmSheet> createState() => _FilterBtmSheetState();
}

class _FilterBtmSheetState extends State<FilterBtmSheet> {
  final _searchService = SearchService();
  final _formKey = GlobalKey<FormState>();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  String _selectedProvince = '';

  late List<bool> _selectedPriceRange;

  bool _isToggleSelected = false;

  List<String>? _provinceList;

  static const List<Widget> _priceRangeList = [
    Text(
      'Under 100.000đ',
      style: TextStyle(
        fontSize: 13,
      ),
    ),
    Text(
      '100.000đ - 200.000đ',
      style: TextStyle(
        fontSize: 13,
      ),
    ),
    Text(
      '200.000đ - 750.000đ',
      style: TextStyle(
        fontSize: 13,
      ),
    ),
    Text(
      'Over 750.000đ',
      style: TextStyle(
        fontSize: 13,
      ),
    ),
  ];

  void _confirmFilter() {
    widget.filterProvider.setFirstFilter(false);

    if (_isToggleSelected) {
      for (var i = 0; i < _selectedPriceRange.length; i++) {
        if (_selectedPriceRange[i]) {
          widget.filterProvider.setTagIndex(i);
          switch (i) {
            case 0:
              widget.filterProvider.setMinPrice(0);
              widget.filterProvider.setMaxPrice(100000);
              break;
            case 1:
              widget.filterProvider.setMinPrice(100000);
              widget.filterProvider.setMaxPrice(200000);
              break;
            case 2:
              widget.filterProvider.setMinPrice(200000);
              widget.filterProvider.setMaxPrice(750000);
              break;
            case 3:
              widget.filterProvider.setMinPrice(750000);
              widget.filterProvider.setMaxPrice(double.infinity);
              break;
            default:
              break;
          }
        }
      }
      widget.filterProvider.setUsingTag(true);
    } else {
      if (_formKey.currentState!.validate()) {
        widget.filterProvider.setMinPrice(double.parse(_fromController.text));
        widget.filterProvider.setMaxPrice(double.parse(_toController.text));
        widget.filterProvider.setUsingTag(false);
      }
    }

    widget.filterProvider.setProvince(_selectedProvince);

    widget.onDoneFilter();

    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();

    _selectedPriceRange = List.generate(_priceRangeList.length, (_) => false);

    _fetchAllProvinces();
    _selectedProvince = widget.filterProvider.province;

    if (widget.filterProvider.usingTag) {
      _selectedPriceRange[widget.filterProvider.tagIndex] = true;
    } else if (widget.filterProvider.tagIndex != -1) {
      _fromController.text = widget.filterProvider.minPrice.toString();
      _toController.text = widget.filterProvider.maxPrice.toString();
    }
  }

  void _fetchAllProvinces() async {
    _provinceList = await _searchService.fetchAllProvinces(context: context);
    if (widget.filterProvider.province == '') {
      _provinceList!.insert(0, "Select province");
    }
    setState(() {});
  }

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
                      child: _boldSizeText('Filter'),
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
                  _paddingText('Price'),
                  Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    runAlignment: WrapAlignment.spaceEvenly,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: List.generate(
                      _priceRangeList.length,
                      (index) => _buildToggleButton(
                        index,
                        _priceRangeList,
                        _selectedPriceRange,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  _paddingDescription('Or enter a price range'),
                  Form(
                    key: _formKey,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _paddingText('From'),
                              TextFormField(
                                controller: _fromController,
                                readOnly: _isToggleSelected,
                                decoration: InputDecoration(
                                  hintText: 'Lowest price',
                                  hintStyle: GoogleFonts.inter(
                                    color: GlobalVariables.darkGrey,
                                    fontSize: 14,
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
                                validator: (minPrice) {
                                  if (double.tryParse(minPrice!) == null) {
                                    return 'Please enter a valid price.';
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
                              _paddingText('To'),
                              TextFormField(
                                controller: _toController,
                                readOnly: _isToggleSelected,
                                decoration: InputDecoration(
                                  hintText: 'Highest price',
                                  hintStyle: GoogleFonts.inter(
                                    color: GlobalVariables.darkGrey,
                                    fontSize: 14,
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
                                validator: (maxPrice) {
                                  if (double.tryParse(maxPrice!) == null) {
                                    return 'Please enter a valid price.';
                                  }
                                  return null;
                                },
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
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
                  _paddingText('Choose location'),
                  _paddingDescription('Province'),
                  SizedBox(
                    height: 8,
                  ),
                  _provinceList == null
                      ? const Loader()
                      : CustomDropdownButton(
                          items: _provinceList,
                          initialSelectedItem: widget.filterProvider.province == ''
                              ? _provinceList![0]
                              : widget.filterProvider.province,
                          onChanged: (selectedProvince) {
                            _selectedProvince = selectedProvince;
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
                        onTap: _confirmFilter,
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

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Widget _boldSizeText(String text) {
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

  Widget _paddingText(String text) {
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

  Widget _paddingDescription(String text) {
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
    int index,
    List<Widget> selectedList,
    List<bool> selectedListState,
  ) {
    return Container(
      child: OutlinedButton(
        onPressed: () {
          selectedListState[index] = !selectedListState[index];
          for (var i = 0; i < selectedListState.length; i++) {
            if (i != index) {
              selectedListState[i] = false;
            }
          }

          _toController.text = '';
          _fromController.text = '';

          _isToggleSelected = false;
          for (var i = 0; i < selectedListState.length; i++) {
            if (selectedListState[i]) {
              _isToggleSelected = true;
              break;
            }
          }
          setState(() {});
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
