import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/facility_detail/widgets/booking_widget_player.dart';
import 'package:frontend/providers/player/selected_court_provider.dart';
import 'package:frontend/providers/court_hub_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class SingleCourtDetailScreen extends StatefulWidget {
  static const String routeName = '/singleCourtDetail';

  const SingleCourtDetailScreen({Key? key}) : super(key: key);

  @override
  _SingleCourtDetailScreenState createState() => _SingleCourtDetailScreenState();
}

class _SingleCourtDetailScreenState extends State<SingleCourtDetailScreen> with WidgetsBindingObserver {
  String? _currentCourtId;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Connect to court when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectToCourt();
    });
  }

  @override
  void dispose() {
    print('[SingleCourtDetail] dispose() called');
    WidgetsBinding.instance.removeObserver(this);
    
    // Ensure disconnect happens
    _disconnectFromCourt();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Disconnect when app goes to background
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      print('[SingleCourtDetail] App going to background, disconnecting...');
      _disconnectFromCourt();
    }
  }

  Future<void> _connectToCourt() async {
    try {
      final selectedCourtProvider = Provider.of<SelectedCourtProvider>(context, listen: false);
      final courtHubProvider = Provider.of<CourtHubProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      final court = selectedCourtProvider.selectedCourt;
      if (court != null && userProvider.user.token.isNotEmpty) {
        _currentCourtId = court.id;
        
        print('[SingleCourtDetail] Connecting to court: $_currentCourtId');
        
        await courtHubProvider.connectToCourt(
          userProvider.user.token,
          court.id,
          initialCourt: court,
        );
        
        _isConnected = true;
        print('[SingleCourtDetail] ✅ Connected to court: $_currentCourtId');
      }
    } catch (e) {
      print('[SingleCourtDetail] ❌ Error connecting to court: $e');
      _isConnected = false;
    }
  }

  Future<void> _disconnectFromCourt() async {
    if (_currentCourtId != null && _isConnected) {
      try {
        print('[SingleCourtDetail] Disconnecting from court: $_currentCourtId');
        
        final courtHubProvider = Provider.of<CourtHubProvider>(context, listen: false);
        await courtHubProvider.disconnectFromCourt(_currentCourtId!);
        
        _isConnected = false;
        print('[SingleCourtDetail] ✅ Disconnected from court: $_currentCourtId');
      } catch (e) {
        print('[SingleCourtDetail] ❌ Error disconnecting from court: $e');
      }
    } else {
      print('[SingleCourtDetail] No court to disconnect from (courtId: $_currentCourtId, connected: $_isConnected)');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('[SingleCourtDetail] build() called');
    
    return WillPopScope(
      onWillPop: () async {
        print('[SingleCourtDetail] WillPopScope triggered - disconnecting...');
        await _disconnectFromCourt();
        return true; // Allow navigation
      },
      child: Consumer2<SelectedCourtProvider, CourtHubProvider>(
        builder: (context, selectedCourtProvider, courtHubProvider, child) {
          final originalCourt = selectedCourtProvider.selectedCourt;
          final facility = selectedCourtProvider.selectedFacility;
          final selectedDate = selectedCourtProvider.selectedDate;

          if (originalCourt == null || facility == null || selectedDate == null) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: GlobalVariables.green,
                title: Text(
                  'Court Detail',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: GlobalVariables.white,
                  ),
                ),
              ),
              body: Center(
                child: Text(
                  'No court selected',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            );
          }

          // Use real-time court data if available, otherwise use original court
          final court = courtHubProvider.getCourt(originalCourt.id) ?? originalCourt;
          final isConnected = courtHubProvider.isConnected(originalCourt.id);

          return Scaffold(
            appBar: AppBar(
              backgroundColor: GlobalVariables.green,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: GlobalVariables.white),
                onPressed: () async {
                  print('[SingleCourtDetail] Back button pressed - disconnecting...');
                  await _disconnectFromCourt();
                  Navigator.of(context).pop();
                },
              ),
              title: Text(
                DateFormat('EEE, dd/MM/yyyy').format(selectedDate),
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: GlobalVariables.white,
                ),
              ),
        
            ),
            body: Container(
              color: GlobalVariables.defaultColor,
              child: Column(
                children: [
                  // Connection status banner
                  if (!isConnected)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      color: Colors.orange.withOpacity(0.1),
                      child: Row(
                        children: [
                          Icon(Icons.wifi_off, color: Colors.orange, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Using offline data - Real-time updates unavailable',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Court info header
                  Container(
                    color: GlobalVariables.white,
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: GlobalVariables.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.sports_tennis,
                            color: GlobalVariables.green,
                            size: 40,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      court.courtName,
                                      style: GoogleFonts.inter(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: GlobalVariables.blackGrey,
                                      ),
                                    ),
                                  ),
                                  // Real-time indicator
                                  if (isConnected)
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: GlobalVariables.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: GlobalVariables.green),
                                      ),
                                      child: Text(
                                        'LIVE',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: GlobalVariables.green,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                court.description,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: GlobalVariables.darkGrey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${court.pricePerHour.toString()} đ/hour',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: GlobalVariables.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  // Booking widget
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: BookingWidgetPlayer(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
