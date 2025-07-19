import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/statistic/services/statistic_service.dart';
import 'package:frontend/providers/manager/current_facility_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:provider/provider.dart';

class DashboardSummaryWidget extends StatefulWidget {
  const DashboardSummaryWidget({Key? key}) : super(key: key);

  @override
  State<DashboardSummaryWidget> createState() => _DashboardSummaryWidgetState();
}

String _formatPrice(final price) {
  if (price >= 1000000) {
    double millions = price / 1000000;
    if (millions == millions.toInt()) {
      return '${millions.toInt()}tr đ';
    } else {
      return '${millions.toStringAsFixed(1)}tr đ';
    }
  } else if (price >= 1000) {
    double thousands = price / 1000;
    if (thousands == thousands.toInt()) {
      return '${thousands.toInt()}k đ';
    } else {
      return '${thousands.toStringAsFixed(1)}k đ';
    }
  } else {
    return '${price}đ';
  }
}

class _DashboardSummaryWidgetState extends State<DashboardSummaryWidget>
    with TickerProviderStateMixin {
  final StatisticService _statisticService = StatisticService();
  Map<String, dynamic>? _summaryData;
  bool _isLoading = true;
  bool _hasError = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSummaryData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSummaryData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final facilityProvider =
          Provider.of<CurrentFacilityProvider>(context, listen: false);
      final facilityId = facilityProvider.currentFacility.id;
      final data =
          await _statisticService.getDashboardSummary(context, facilityId);

      if (mounted) {
        setState(() {
          _summaryData = data;
          _isLoading = false;
          _hasError = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });

        IconSnackBar.show(
          context,
          label: 'Failed to load dashboard data',
          snackBarType: SnackBarType.fail,
        );
      }
    }
  }

  Future<void> _refreshData() async {
    _animationController.reset();
    await _loadSummaryData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          if (_isLoading) _buildLoadingState(),
          if (_hasError) _buildErrorState(),
          if (!_isLoading && !_hasError && _summaryData != null)
            _buildContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
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
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: GlobalVariables.green,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: GlobalVariables.green.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.dashboard_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dashboard Overview',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: GlobalVariables.blackGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Real-time business metrics',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: GlobalVariables.darkGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
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
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: GlobalVariables.green,
                      ),
                    )
                  : Icon(Icons.refresh_rounded, color: GlobalVariables.green),
              onPressed: _isLoading ? null : _refreshData,
              tooltip: 'Refresh Data',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: GlobalVariables.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: GlobalVariables.green,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading dashboard data...',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: GlobalVariables.darkGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we fetch your latest metrics',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: GlobalVariables.darkGrey.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 30,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Failed to load data',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: GlobalVariables.blackGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to fetch dashboard metrics',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: GlobalVariables.darkGrey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: GlobalVariables.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // First row
              Row(
                children: [
                  Expanded(
                    child: _buildEnhancedSummaryCard(
                      title: 'Total Revenue',
                      value:
                          '${_formatPrice(_summaryData!['totalRevenue'] ?? 0)}',
                      icon: Icons.account_balance_wallet_rounded,
                      color: GlobalVariables.green,
                      trend: '+12.5%',
                      isPositive: true,
                      delay: 0,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildEnhancedSummaryCard(
                      title: 'Total Orders',
                      value: '${_summaryData!['totalOrders'] ?? 0}',
                      icon: Icons.receipt_long_rounded,
                      color: Colors.blue,
                      trend: '+8.2%',
                      isPositive: true,
                      delay: 100,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Second row
              Row(
                children: [
                  Expanded(
                    child: _buildEnhancedSummaryCard(
                      title: 'Total players',
                      value: '${_summaryData!['totalCustomers'] ?? 0}',
                      icon: Icons.people_rounded,
                      color: Colors.orange,
                      trend: '+15.3%',
                      isPositive: true,
                      delay: 200,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildEnhancedSummaryCard(
                      title: 'Total Courts',
                      value: '${_summaryData!['totalCourts'] ?? 0}',
                      icon: Icons.business_rounded,
                      color: Colors.purple,
                      trend: '+2.1%',
                      isPositive: true,
                      delay: 300,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
    required bool isPositive,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, animationValue, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * animationValue),
          child: Opacity(
            opacity: animationValue,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.1),
                    color.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: color,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    title,
                    maxLines: 1,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: GlobalVariables.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
