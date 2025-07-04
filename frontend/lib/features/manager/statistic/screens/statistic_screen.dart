import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/statistic/widgets/dashboard_summary_widget.dart';
import 'package:frontend/features/manager/statistic/widgets/revenue_chart_widget.dart';
import 'package:frontend/features/manager/statistic/widgets/court_revenue_widget.dart';
import 'package:frontend/features/manager/statistic/widgets/orders_table_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class StatisticScreen extends StatefulWidget {
  static const String routeName = '/statistic';
  
  const StatisticScreen({Key? key}) : super(key: key);

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalVariables.defaultColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: GlobalVariables.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Statistics',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Dashboard Summary (2x2 grid)
            Text(
              'Dashboard Overview',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: GlobalVariables.blackGrey,
              ),
            ),
            const SizedBox(height: 16),
            const DashboardSummaryWidget(),
            
            const SizedBox(height: 32),
            
            // 2. Revenue Chart
            Text(
              'Revenue Analytics',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: GlobalVariables.blackGrey,
              ),
            ),
            const SizedBox(height: 16),
            const RevenueChartWidget(),
            
            const SizedBox(height: 32),
            
            // 3. Court Revenue Chart (NEW)
            Text(
              'Court Performance',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: GlobalVariables.blackGrey,
              ),
            ),
            const SizedBox(height: 16),
            const CourtRevenueWidget(),
            
            const SizedBox(height: 32),
            
            // 4. Orders Table
            Text(
              'Orders Management',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: GlobalVariables.blackGrey,
              ),
            ),
            const SizedBox(height: 16),
            const OrdersTableWidget(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
