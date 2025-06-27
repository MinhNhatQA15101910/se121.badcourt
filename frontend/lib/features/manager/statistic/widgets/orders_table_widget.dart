import 'package:excel/excel.dart' as ex;
import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/statistic/services/statistic_service.dart';
import 'package:frontend/models/order.dart';
import 'package:frontend/models/court.dart';
import 'package:frontend/providers/manager/current_facility_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:share_plus/share_plus.dart';

class OrdersTableWidget extends StatefulWidget {
  const OrdersTableWidget({Key? key}) : super(key: key);

  @override
  State<OrdersTableWidget> createState() => _OrdersTableWidgetState();
}

class _OrdersTableWidgetState extends State<OrdersTableWidget> {
  final StatisticService _statisticService = StatisticService();
  List<Order>? _orders;
  List<Court>? _courts;
  bool _isLoading = true;
  bool _isLoadingCourts = false;
  bool _isExporting = false;
  
  String? _selectedCourtId;
  String? _selectedState = 'All';

  final List<String> _states = ['All', 'NotPlay', 'Played', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _loadCourts();
    _loadOrders();
  }

  Future<void> _loadCourts() async {
    setState(() => _isLoadingCourts = true);
    
    final currentFacilityProvider = Provider.of<CurrentFacilityProvider>(context, listen: false);
    final facilityId = currentFacilityProvider.currentFacility.id;
    
    if (facilityId.isNotEmpty) {
      final courts = await _statisticService.fetchCourtByFacilityId(context, facilityId);
      setState(() {
        _courts = courts;
        _isLoadingCourts = false;
      });
    } else {
      setState(() => _isLoadingCourts = false);
    }
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    
    // Convert display state to query parameter
    String? queryState;
    if (_selectedState != null && _selectedState != 'All') {
      switch (_selectedState) {
        case 'NotPlay':
          queryState = 'notPlay';
          break;
        case 'Played':
          queryState = 'played';
          break;
        case 'Cancelled':
          queryState = 'cancelled';
          break;
        default:
          queryState = null;
      }
    }
    
    final orders = await _statisticService.getOrders(
      context,
      courtId: _selectedCourtId,
      state: queryState,
    );
    
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  Future<void> _exportToExcel() async {
    if (_orders == null || _orders!.isEmpty) {
      IconSnackBar.show(
        context,
        label: 'No data to export',
        snackBarType: SnackBarType.fail,
      );
      return;
    }

    setState(() => _isExporting = true);
    
    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        IconSnackBar.show(
          context,
          label: 'Storage permission is required to save the file',
          snackBarType: SnackBarType.fail,
        );
        return;
      }

      // Create Excel file
      var excel = ex.Excel.createExcel();
      ex.Sheet sheetObject = excel['Orders'];
      
      // Add headers
      sheetObject.cell(ex.CellIndex.indexByString("A1")).value = ex.TextCellValue('Order ID');
      sheetObject.cell(ex.CellIndex.indexByString("B1")).value = ex.TextCellValue('Facility Name');
      sheetObject.cell(ex.CellIndex.indexByString("C1")).value = ex.TextCellValue('Address');
      sheetObject.cell(ex.CellIndex.indexByString("D1")).value = ex.TextCellValue('Date');
      sheetObject.cell(ex.CellIndex.indexByString("E1")).value = ex.TextCellValue('Start Time');
      sheetObject.cell(ex.CellIndex.indexByString("F1")).value = ex.TextCellValue('End Time');
      sheetObject.cell(ex.CellIndex.indexByString("G1")).value = ex.TextCellValue('Price (VND)');
      sheetObject.cell(ex.CellIndex.indexByString("H1")).value = ex.TextCellValue('Status');
      sheetObject.cell(ex.CellIndex.indexByString("I1")).value = ex.TextCellValue('Created At');

      // Style headers
      for (int i = 0; i < 9; i++) {
        var cell = sheetObject.cell(ex.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.cellStyle = ex.CellStyle(
          bold: true,
          backgroundColorHex: ex.ExcelColor.green,
          fontColorHex: ex.ExcelColor.white,
        );
      }

      // Add data rows
      for (int i = 0; i < _orders!.length; i++) {
        final order = _orders![i];
        final rowIndex = i + 1;
        
        sheetObject.cell(ex.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).value = ex.TextCellValue(order.id);
        sheetObject.cell(ex.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex)).value = ex.TextCellValue(order.facilityName);
        sheetObject.cell(ex.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex)).value = ex.TextCellValue(order.address);
        sheetObject.cell(ex.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex)).value = ex.TextCellValue(DateFormat('dd/MM/yyyy').format(order.timePeriod.hourFrom));
        sheetObject.cell(ex.CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex)).value = ex.TextCellValue(DateFormat('HH:mm').format(order.timePeriod.hourFrom));
        sheetObject.cell(ex.CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex)).value = ex.TextCellValue(DateFormat('HH:mm').format(order.timePeriod.hourTo));
        sheetObject.cell(ex.CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex)).value = ex.DoubleCellValue(order.price);
        sheetObject.cell(ex.CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex)).value = ex.TextCellValue(_getDisplayState(order.state));
        sheetObject.cell(ex.CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex)).value = ex.TextCellValue(DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt));
      }

      // Add summary row
      final summaryRowIndex = _orders!.length + 2;
      sheetObject.cell(ex.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: summaryRowIndex)).value = ex.TextCellValue('SUMMARY');
      sheetObject.cell(ex.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: summaryRowIndex)).value = ex.TextCellValue('Total Orders: ${_orders!.length}');
      sheetObject.cell(ex.CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: summaryRowIndex)).value = ex.DoubleCellValue(_orders!.fold(0.0, (sum, order) => sum + order.price));

      // Style summary row
      for (int i = 0; i < 9; i++) {
        var cell = sheetObject.cell(ex.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: summaryRowIndex));
        cell.cellStyle = ex.CellStyle(
          bold: true,
          backgroundColorHex: ex.ExcelColor.grey300,
        );
      }

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${directory.path}/orders_export_$timestamp.xlsx';
      
      List<int>? fileBytes = excel.save();
      if (fileBytes != null) {
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
        
        // Share the file
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Orders Export - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
        );
        
        IconSnackBar.show(
          context,
          label: 'Excel file exported successfully!',
          snackBarType: SnackBarType.success,
        );
      }
    } catch (e) {
      IconSnackBar.show(
        context,
        label: 'Failed to export Excel: ${e.toString()}',
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
                              Icons.table_chart,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Orders Revenue',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: GlobalVariables.blackGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage and track all booking orders',
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
                    // Export Excel Button
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
                            : Icon(Icons.file_download, color: GlobalVariables.green),
                        onPressed: _isExporting ? null : _exportToExcel,
                        tooltip: 'Export to Excel',
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Refresh Button
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
                        icon: Icon(Icons.refresh, color: GlobalVariables.green),
                        onPressed: () {
                          _loadCourts();
                          _loadOrders();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Enhanced Filters - Horizontal Scrollable
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filters',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: GlobalVariables.blackGrey,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Order Status Filter
                      Container(
                        width: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Status',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: GlobalVariables.darkGrey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: GlobalVariables.lightGrey),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade50,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedState,
                                  isExpanded: true,
                                  icon: Icon(Icons.keyboard_arrow_down, color: GlobalVariables.green),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: GlobalVariables.blackGrey,
                                  ),
                                  items: _states.map((state) {
                                    return DropdownMenuItem(
                                      value: state,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: _getStateColor(state),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              state,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() => _selectedState = value);
                                    _loadOrders();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Court Selection Filter
                      Container(
                        width: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Court Selection',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: GlobalVariables.darkGrey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: GlobalVariables.lightGrey),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade50,
                              ),
                              child: _isLoadingCourts
                                  ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    )
                                  : DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        hint: const Text('All Courts'),
                                        value: _selectedCourtId,
                                        isExpanded: true,
                                        icon: Icon(Icons.keyboard_arrow_down, color: GlobalVariables.green),
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: GlobalVariables.blackGrey,
                                        ),
                                        items: [
                                          const DropdownMenuItem(
                                            value: null,
                                            child: Text('All Courts'),
                                          ),
                                          if (_courts != null)
                                            ..._courts!.map((court) {
                                              return DropdownMenuItem(
                                                value: court.id,
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.sports_tennis,
                                                      size: 16,
                                                      color: GlobalVariables.green,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        court.courtName,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                        ],
                                        onChanged: (value) {
                                          setState(() => _selectedCourtId = value);
                                          _loadOrders();
                                        },
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Enhanced Table - Horizontal Scrollable
          if (_isLoading)
            Container(
              height: 200,
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
                      'Loading orders...',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: GlobalVariables.darkGrey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_orders == null || _orders!.isEmpty)
            Container(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: GlobalVariables.lightGrey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No orders found',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: GlobalVariables.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Orders will appear here once customers make bookings',
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
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                width: MediaQuery.of(context).size.width > 800 
                    ? MediaQuery.of(context).size.width - 40
                    : 800, // Minimum width for table
                child: Column(
                  children: [
                    // Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: GlobalVariables.green.withOpacity(0.1),
                        border: Border(
                          top: BorderSide(color: GlobalVariables.lightGrey),
                          bottom: BorderSide(color: GlobalVariables.lightGrey),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 1, child: _buildHeaderCell('Order')),
                          Expanded(flex: 4, child: _buildHeaderCell('Facility')),
                          Expanded(flex: 1, child: _buildHeaderCell('Schedule')),
                          Expanded(flex: 1, child: _buildHeaderCell('Price')),
                          Expanded(flex: 1, child: _buildHeaderCell('Status')),
                        ],
                      ),
                    ),
                    
                    // Table Rows
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _orders!.length,
                      itemBuilder: (context, index) {
                        final order = _orders![index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: GlobalVariables.lightGrey.withOpacity(0.5),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.id.length > 8 
                                          ? '${order.id.substring(0, 8)}...'
                                          : order.id,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: GlobalVariables.blackGrey,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      DateFormat('dd/MM/yyyy').format(order.createdAt),
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: GlobalVariables.darkGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.facilityName,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: GlobalVariables.blackGrey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      order.address,
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: GlobalVariables.darkGrey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat('dd/MM').format(order.timePeriod.hourFrom),
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: GlobalVariables.blackGrey,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${DateFormat('HH:mm').format(order.timePeriod.hourFrom)} - ${DateFormat('HH:mm').format(order.timePeriod.hourTo)}',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: GlobalVariables.darkGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '${NumberFormat('#,###').format(order.price)}đ',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: GlobalVariables.green,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getOrderStateColor(order.state).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _getOrderStateColor(order.state).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    _getDisplayState(order.state),
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: _getOrderStateColor(order.state),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          
          // Enhanced Summary - Horizontal Scrollable
          if (_orders != null && _orders!.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        GlobalVariables.green.withOpacity(0.1),
                        GlobalVariables.green.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: GlobalVariables.green.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      _buildSummaryItem(
                        'Total Orders',
                        '${_orders!.length}',
                        Icons.receipt_long,
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        color: GlobalVariables.lightGrey,
                      ),
                      _buildSummaryItem(
                        'Total Revenue',
                        '${NumberFormat('#,###').format(_orders!.fold(0.0, (sum, order) => sum + order.price))}đ',
                        Icons.account_balance_wallet,
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        color: GlobalVariables.lightGrey,
                      ),
                      _buildSummaryItem(
                        'Avg Order',
                        '${NumberFormat('#,###').format(_orders!.fold(0.0, (sum, order) => sum + order.price) / _orders!.length)}đ',
                        Icons.trending_up,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: GlobalVariables.blackGrey,
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Container(
      width: 120, // Fixed width to prevent overflow
      child: Column(
        children: [
          Icon(icon, color: GlobalVariables.green, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: GlobalVariables.blackGrey,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
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

  // Color for filter dropdown (display states)
  Color _getStateColor(String state) {
    switch (state.toLowerCase()) {
      case 'notplay':
        return Colors.orange;
      case 'played':
        return GlobalVariables.green;
      case 'cancelled':
        return Colors.red;
      case 'all':
        return GlobalVariables.darkGrey;
      default:
        return GlobalVariables.darkGrey;
    }
  }

  // Color for order badges (actual order states from API)
  Color _getOrderStateColor(String orderState) {
    switch (orderState.toLowerCase()) {
      case 'notplay':
        return Colors.orange; // Badge vàng
      case 'played':
        return GlobalVariables.green; // Badge xanh lá
      case 'cancelled':
        return Colors.red; // Badge đỏ
      case 'pending':
        return Colors.grey; // Badge xám
      default:
        return Colors.grey; // Badge xám cho các state khác
    }
  }

  // Convert API state to display text
  String _getDisplayState(String orderState) {
    switch (orderState.toLowerCase()) {
      case 'notplay':
        return 'NotPlay';
      case 'played':
        return 'Played';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
        return 'Pending';
      default:
        return orderState; // Giữ nguyên nếu không match
    }
  }
}
