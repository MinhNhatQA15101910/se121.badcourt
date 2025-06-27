import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _FilterBtmSheetState extends State<FilterBtmSheet>
    with TickerProviderStateMixin {
  final _searchService = SearchService();
  final _formKey = GlobalKey<FormState>();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  String _selectedProvince = '';

  late List<bool> _selectedPriceRange;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  bool _isToggleSelected = false;

  List<String>? _provinceList;

  static const List<Map<String, dynamic>> _priceRangeList = [
    {
      'label': 'Under 100K',
      'subtitle': '< 100,000đ',
    },
    {
      'label': '100K - 200K',
      'subtitle': '100,000đ - 200,000đ',
    },
    {
      'label': '200K - 300K',
      'subtitle': '200,000đ - 300,000đ',
    },
    {
      'label': 'Over 300K',
      'subtitle': '> 300,000đ',
    },
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
              widget.filterProvider.setMaxPrice(1000000000);
              break;
            default:
              break;
          }
        }
      }
      widget.filterProvider.setUsingTag(true);
    } else {
      if (_formKey.currentState!.validate()) {
        widget.filterProvider.setMinPrice(int.parse(_fromController.text));
        widget.filterProvider.setMaxPrice(int.parse(_toController.text));
        widget.filterProvider.setUsingTag(false);
      }
    }

    widget.filterProvider.setProvince(_selectedProvince);
    widget.onDoneFilter();
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();

    _selectedPriceRange = List.generate(_priceRangeList.length, (_) => false);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();

    _fetchAllProvinces();
    _selectedProvince = widget.filterProvider.province;

    if (widget.filterProvider.usingTag) {
      _selectedPriceRange[widget.filterProvider.tagIndex] = true;
      _isToggleSelected = true;
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
  void dispose() {
    _slideController.dispose();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.only(bottom: keyboardSpace),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                _buildContent(),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: GlobalVariables.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.tune,
              color: GlobalVariables.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Filter Options',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.black54),
              iconSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPriceSection(),
          const SizedBox(height: 32),
          _buildLocationSection(),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.payments_outlined,
              color: GlobalVariables.green,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Price Range',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Price range buttons
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: _priceRangeList.length,
          itemBuilder: (context, index) => _buildPriceRangeCard(index),
        ),

        const SizedBox(height: 20),

        // Custom price inputs
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isToggleSelected
                  ? Colors.grey.shade300
                  : GlobalVariables.green.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Or enter custom range',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _isToggleSelected ? Colors.grey : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Form(
                key: _formKey,
                child: Row(
                  children: [
                    Expanded(
                        child: _buildPriceInput(
                            _fromController, 'From (đ)', 'Min price')),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: Colors.grey.shade400,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildPriceInput(
                            _toController, 'To (đ)', 'Max price')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRangeCard(int index) {
    final isSelected = _selectedPriceRange[index];
    final priceRange = _priceRangeList[index];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              _selectedPriceRange[index] = !_selectedPriceRange[index];
              for (var i = 0; i < _selectedPriceRange.length; i++) {
                if (i != index) {
                  _selectedPriceRange[i] = false;
                }
              }

              _toController.clear();
              _fromController.clear();

              _isToggleSelected =
                  _selectedPriceRange.any((selected) => selected);
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? GlobalVariables.green.withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isSelected ? GlobalVariables.green : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: GlobalVariables.green.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 4),
                Text(
                  priceRange['label'],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? GlobalVariables.green : Colors.black87,
                  ),
                ),
                Text(
                  priceRange['subtitle'],
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: isSelected
                        ? GlobalVariables.green
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceInput(
      TextEditingController controller, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _isToggleSelected ? Colors.grey : Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: !_isToggleSelected,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly, // Chỉ cho phép số
            LengthLimitingTextInputFormatter(10), // Giới hạn độ dài
          ],
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: GlobalVariables.green, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            filled: true,
            fillColor: _isToggleSelected ? Colors.grey.shade100 : Colors.white,
          ),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: _isToggleSelected ? Colors.grey.shade400 : Colors.black87,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a price';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: GlobalVariables.green,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Location',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _provinceList == null
                  ? Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Center(child: Loader()),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: CustomDropdownButton(
                        items: _provinceList,
                        initialSelectedItem:
                            widget.filterProvider.province == ''
                                ? _provinceList![0]
                                : widget.filterProvider.province,
                        onChanged: (selectedProvince) {
                          _selectedProvince = selectedProvince;
                        },
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: GlobalVariables.green, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: GlobalVariables.green,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 48,
              child: ElevatedButton(
                onPressed: _confirmFilter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlobalVariables.green,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Apply Filter',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
