import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/statistic/services/statistic_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';

class RevenueChartWidget extends StatefulWidget {
  const RevenueChartWidget({Key? key}) : super(key: key);

  @override
  State<RevenueChartWidget> createState() => _RevenueChartWidgetState();
}

class _RevenueChartWidgetState extends State<RevenueChartWidget> {
  final StatisticService _statisticService = StatisticService();
  final ScreenshotController _screenshotController = ScreenshotController();
  List<Map<String, dynamic>>? _revenueData;
  bool _isLoading = true;
  bool _isExporting = false;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadRevenueData();
  }

  Future<void> _loadRevenueData() async {
    setState(() => _isLoading = true);
    
    final data = await _statisticService.getMonthlyRevenue(context, _selectedYear);
    
    setState(() {
      _revenueData = data;
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
        final imagePath = '${directory.path}/revenue_chart_$_selectedYear.png';
        
        // Save image to file
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(image);
        
        // Share the image
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: 'Revenue Chart for $_selectedYear',
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
                              Icons.trending_up,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Monthly Revenue',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: GlobalVariables.blackGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Track your facility\'s monthly performance',
                        style: GoogleFonts.inter(
                          fontSize: 14,
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
                            : Icon(Icons.download, color: GlobalVariables.green),
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
                        border: Border.all(color: GlobalVariables.green.withOpacity(0.3)),
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
                          icon: Icon(Icons.keyboard_arrow_down, color: GlobalVariables.green),
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
                              _loadRevenueData();
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
                              'Loading revenue data...',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: GlobalVariables.darkGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _revenueData == null || _revenueData!.isEmpty
                      ? Container(
                          height: 300,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bar_chart,
                                  size: 64,
                                  color: GlobalVariables.lightGrey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No revenue data available',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: GlobalVariables.darkGrey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Revenue data will appear here once you have bookings',
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
                                      margin: const EdgeInsets.symmetric(horizontal: 20),
                                      color: GlobalVariables.lightGrey,
                                    ),
                                    _buildSummaryItem(
                                      'Avg/Month',
                                      '${NumberFormat('#,###').format(_getAverageRevenue())} đ',
                                      Icons.trending_up,
                                    ),
                                    Container(
                                      height: 40,
                                      width: 1,
                                      margin: const EdgeInsets.symmetric(horizontal: 20),
                                      color: GlobalVariables.lightGrey,
                                    ),
                                    _buildSummaryItem(
                                      'Peak Month',
                                      _getPeakMonth(),
                                      Icons.star,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Chart - Horizontal Scrollable
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                width: MediaQuery.of(context).size.width > 600 
                                    ? MediaQuery.of(context).size.width - 80
                                    : 600, // Minimum width for chart
                                height: 320,
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: _getMaxRevenue() * 1.2,
                                    barTouchData: BarTouchData(
                                      enabled: true,
                                      touchTooltipData: BarTouchTooltipData(
                                        tooltipPadding: const EdgeInsets.all(8),
                                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                          final month = _getMonthName(group.x.toInt());
                                          final revenue = NumberFormat('#,###').format(rod.toY);
                                          return BarTooltipItem(
                                            '$month $_selectedYear\n$revenue đ',
                                            GoogleFonts.inter(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          getTitlesWidget: (value, meta) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Text(
                                                _getMonthName(value.toInt()),
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: GlobalVariables.darkGrey,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 60,
                                          getTitlesWidget: (value, meta) {
                                            return Text(
                                              NumberFormat.compact().format(value),
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                                color: GlobalVariables.darkGrey,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    borderData: FlBorderData(
                                      show: true,
                                      border: Border(
                                        bottom: BorderSide(color: GlobalVariables.lightGrey, width: 1),
                                        left: BorderSide(color: GlobalVariables.lightGrey, width: 1),
                                      ),
                                    ),
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval: _getMaxRevenue() / 5,
                                      getDrawingHorizontalLine: (value) {
                                        return FlLine(
                                          color: GlobalVariables.lightGrey.withOpacity(0.5),
                                          strokeWidth: 1,
                                          dashArray: [5, 5],
                                        );
                                      },
                                    ),
                                    barGroups: _buildBarGroups(),
                                  ),
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
      width: 120, // Fixed width to prevent overflow
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

  List<BarChartGroupData> _buildBarGroups() {
    return _revenueData!.asMap().entries.map((entry) {
      final data = entry.value;
      final month = data['month'] as int;
      final revenue = (data['revenue'] as num).toDouble();
      
      return BarChartGroupData(
        x: month,
        barRods: [
          BarChartRodData(
            toY: revenue,
            gradient: LinearGradient(
              colors: [
                GlobalVariables.green,
                GlobalVariables.green.withOpacity(0.7),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 24,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
    }).toList();
  }

  double _getMaxRevenue() {
    if (_revenueData == null || _revenueData!.isEmpty) return 0;
    return _revenueData!
        .map((data) => (data['revenue'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
  }

  double _getTotalRevenue() {
    if (_revenueData == null || _revenueData!.isEmpty) return 0;
    return _revenueData!
        .map((data) => (data['revenue'] as num).toDouble())
        .reduce((a, b) => a + b);
  }

  double _getAverageRevenue() {
    if (_revenueData == null || _revenueData!.isEmpty) return 0;
    return _getTotalRevenue() / _revenueData!.length;
  }

  String _getPeakMonth() {
    if (_revenueData == null || _revenueData!.isEmpty) return 'N/A';
    final maxData = _revenueData!.reduce((a, b) => 
        (a['revenue'] as num) > (b['revenue'] as num) ? a : b);
    return _getMonthName(maxData['month'] as int);
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}
