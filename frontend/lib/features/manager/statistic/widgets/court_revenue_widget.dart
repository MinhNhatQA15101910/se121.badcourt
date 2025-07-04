import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/statistic/services/statistic_service.dart';
import 'package:frontend/providers/manager/current_facility_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';

class CourtRevenueWidget extends StatefulWidget {
  const CourtRevenueWidget({Key? key}) : super(key: key);

  @override
  State<CourtRevenueWidget> createState() => _CourtRevenueWidgetState();
}

class _CourtRevenueWidgetState extends State<CourtRevenueWidget> {
  final StatisticService _statisticService = StatisticService();
  final ScreenshotController _screenshotController = ScreenshotController();
  List<Map<String, dynamic>>? _courtRevenueData;
  bool _isLoading = true;
  bool _isExporting = false;
  int _selectedYear = DateTime.now().year;

  // Different colors for each court - similar to RevenueChartWidget style
  final List<Color> _chartColors = [
    const Color(0xFF4CAF50), // Green
    const Color(0xFF2196F3), // Blue
    const Color(0xFFFF9800), // Orange
    const Color(0xFF9C27B0), // Purple
    const Color(0xFFE91E63), // Pink
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFFFF5722), // Deep Orange
    const Color(0xFF795548), // Brown
    const Color(0xFF607D8B), // Blue Grey
    const Color(0xFF8BC34A), // Light Green
    const Color(0xFF3F51B5), // Indigo
    const Color(0xFFFFEB3B), // Yellow
  ];

  @override
  void initState() {
    super.initState();
    _loadCourtRevenueData();
  }

  Future<void> _loadCourtRevenueData() async {
    setState(() => _isLoading = true);
    final facilityProvider =
        Provider.of<CurrentFacilityProvider>(context, listen: false);
    final facilityId = facilityProvider.currentFacility.id;
    
    final data = await _statisticService.getCourtRevenue(
        context, facilityId, _selectedYear);

    setState(() {
      _courtRevenueData = data;
      _isLoading = false;
    });
  }

  Future<void> _exportChartAsImage() async {
    setState(() => _isExporting = true);

    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        IconSnackBar.show(
          context,
          label: 'Storage permission is required to save the chart',
          snackBarType: SnackBarType.fail,
        );
        return;
      }

      // Capture screenshot
      final image = await _screenshotController.capture();
      if (image != null) {
        // Get directory to save file
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = '${directory.path}/court_revenue_chart_$_selectedYear.png';

        // Save image to file
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(image);

        // Share the image
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: 'Court Revenue Chart for $_selectedYear',
        );

        IconSnackBar.show(
          context,
          label: 'Chart exported successfully!',
          snackBarType: SnackBarType.success,
        );
      }
    } catch (e) {
      IconSnackBar.show(
        context,
        label: 'Failed to export chart: ${e.toString()}',
        snackBarType: SnackBarType.fail,
      );
    } finally {
      setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Header with Export Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GlobalVariables.green.withOpacity(0.1),
                  GlobalVariables.green.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: GlobalVariables.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.sports_tennis,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Court Revenue',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: GlobalVariables.blackGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Revenue breakdown by court',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: GlobalVariables.darkGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    // Export Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: _isExporting
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: GlobalVariables.green,
                                ),
                              )
                            : Icon(Icons.download,
                                color: GlobalVariables.green),
                        onPressed: _isExporting ? null : _exportChartAsImage,
                        tooltip: 'Export Chart as Image',
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Year Selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: GlobalVariables.green.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedYear,
                          icon: Icon(Icons.keyboard_arrow_down,
                              color: GlobalVariables.green),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: GlobalVariables.blackGrey,
                          ),
                          items: List.generate(5, (index) {
                            final year = DateTime.now().year - index;
                            return DropdownMenuItem(
                              value: year,
                              child: Text('$year'),
                            );
                          }),
                          onChanged: (year) {
                            if (year != null) {
                              setState(() => _selectedYear = year);
                              _loadCourtRevenueData();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Chart Content with Screenshot wrapper
          Screenshot(
            controller: _screenshotController,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: _isLoading
                  ? Container(
                      height: 300,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: GlobalVariables.green,
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading court revenue data...',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: GlobalVariables.darkGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _courtRevenueData == null || _courtRevenueData!.isEmpty
                      ? Container(
                          height: 300,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.sports_tennis,
                                  size: 64,
                                  color: GlobalVariables.lightGrey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No court revenue data available',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: GlobalVariables.darkGrey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Court revenue data will appear here once you have bookings',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: GlobalVariables.darkGrey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            // Revenue Summary - Horizontal Scrollable
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      GlobalVariables.green.withOpacity(0.1),
                                      GlobalVariables.green.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    _buildSummaryItem(
                                      'Total Revenue',
                                      '${NumberFormat('#,###').format(_getTotalRevenue())} đ',
                                      Icons.account_balance_wallet,
                                    ),
                                    Container(
                                      height: 40,
                                      width: 1,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      color: GlobalVariables.lightGrey,
                                    ),
                                    _buildSummaryItem(
                                      'Top Court',
                                      _getTopCourt(),
                                      Icons.emoji_events,
                                    ),
                                    Container(
                                      height: 40,
                                      width: 1,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      color: GlobalVariables.lightGrey,
                                    ),
                                    _buildSummaryItem(
                                      'Active Courts',
                                      '${_courtRevenueData!.length}',
                                      Icons.sports_tennis,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Horizontal Bar Chart
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                width: MediaQuery.of(context).size.width > 600 
                                    ? MediaQuery.of(context).size.width + 200  // Add extra width for larger screens
                                    : 500, // Minimum width for mobile
                                height: _calculateChartHeight(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                  
                                    // Custom Horizontal Bars
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 0),
                                        child: ListView.builder(
                                          physics: const NeverScrollableScrollPhysics(), // Disable vertical scroll inside
                                          itemCount: _courtRevenueData!.length,
                                          itemBuilder: (context, index) {
                                            final courtData = _courtRevenueData![index];
                                            final courtName = courtData['courtName'] as String;
                                            final revenue = (courtData['revenue'] as num).toDouble();
                                            final maxRevenue = _getMaxRevenue();
                                            final barWidth = (revenue / maxRevenue) * 0.75; // 75% of available width
                                            
                                            // Get color for this court (cycle through colors if more courts than colors)
                                            final color = _chartColors[index % _chartColors.length];
                                            
                                            return Container(
                                              margin: const EdgeInsets.only(bottom: 16),
                                              child: Row(
                                                children: [
                                                  // Court Name (Left side) - Wider for better readability
                                                  SizedBox(
                                                    width: 60,
                                                    child: Text(
                                                      courtName,
                                                      maxLines: 2,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: GlobalVariables.blackGrey,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  // Bar and Value - Much wider area
                                                  SizedBox(
                                                    width: MediaQuery.of(context).size.width > 600 
                                                        ? MediaQuery.of(context).size.width - 200
                                                        : 360,
                                                    child: Row(
                                                      children: [
                                                        // Horizontal Bar
                                                        Expanded(
                                                          child: Container(
                                                            height: 24, // Same height as RevenueChartWidget bars
                                                            child: Stack(
                                                              children: [
                                                                // Background bar
                                                                Container(
                                                                  height: 24,
                                                                  decoration: BoxDecoration(
                                                                    color: GlobalVariables.lightGrey.withOpacity(0.3),
                                                                    borderRadius: BorderRadius.circular(0), // No border radius like RevenueChartWidget background
                                                                  ),
                                                                ),
                                                                // Actual revenue bar - styled like RevenueChartWidget
                                                                FractionallySizedBox(
                                                                  widthFactor: barWidth,
                                                                  child: Container(
                                                                    height: 24,
                                                                    decoration: BoxDecoration(
                                                                      gradient: LinearGradient(
                                                                        colors: [
                                                                          color,
                                                                          color.withOpacity(0.7),
                                                                        ],
                                                                        begin: Alignment.centerLeft,
                                                                        end: Alignment.centerRight,
                                                                      ),
                                                                      // Only round the right side (end) like RevenueChartWidget
                                                                      borderRadius: const BorderRadius.only(
                                                                        topRight: Radius.circular(6),
                                                                        bottomRight: Radius.circular(6),
                                                                      ),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: color.withOpacity(0.3),
                                                                          blurRadius: 4,
                                                                          offset: const Offset(0, 2),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 12),
                                                        // Revenue Value - More space for larger numbers
                                                        Container(
                                                          child: Text(
                                                            '${NumberFormat('#,###').format(revenue)}',
                                                            style: GoogleFonts.inter(
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.w600,
                                                              color: GlobalVariables.blackGrey,
                                                            ),
                                                            textAlign: TextAlign.left,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Container(
      width: 120,
      child: Column(
        children: [
          Icon(icon, color: GlobalVariables.green, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: GlobalVariables.blackGrey,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: GlobalVariables.darkGrey,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  double _calculateChartHeight() {
    if (_courtRevenueData == null || _courtRevenueData!.isEmpty) return 300;
    // Calculate height: title + (number of courts * 40) + padding
    return (80 + (_courtRevenueData!.length * 40)).toDouble();
  }

  double _getMaxRevenue() {
    if (_courtRevenueData == null || _courtRevenueData!.isEmpty) return 0;
    return _courtRevenueData!
        .map((data) => (data['revenue'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
  }

  double _getTotalRevenue() {
    if (_courtRevenueData == null || _courtRevenueData!.isEmpty) return 0;
    return _courtRevenueData!
        .map((data) => (data['revenue'] as num).toDouble())
        .reduce((a, b) => a + b);
  }

  String _getTopCourt() {
    if (_courtRevenueData == null || _courtRevenueData!.isEmpty) return 'N/A';
    final maxData = _courtRevenueData!.reduce(
        (a, b) => (a['revenue'] as num) > (b['revenue'] as num) ? a : b);
    return maxData['courtName'] as String;
  }
}
