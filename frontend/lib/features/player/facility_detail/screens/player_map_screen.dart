import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/facility.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlayerMapScreen extends StatefulWidget {
  static const String routeName = '/playerMap';
  const PlayerMapScreen({super.key});

  @override
  State<PlayerMapScreen> createState() => _PlayerMapScreenState();
}

class _PlayerMapScreenState extends State<PlayerMapScreen> {
  VietmapController? _mapController;
  late LatLng markerPosition;
  Facility? facility;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lấy facility từ ModalRoute
    facility = ModalRoute.of(context)!.settings.arguments as Facility;

    // Thiết lập vị trí marker ban đầu
    markerPosition = LatLng(
      facility!.lat,
      facility!.lon,
    );
  }

  void _goToFacility() {
    if (_mapController != null) {
      // Quay lại vị trí của facility
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: markerPosition, zoom: 15),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (facility == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Loading..."),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: GlobalVariables.green,
          title: Text(
            'Facility Location',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.none,
              color: GlobalVariables.white,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          VietmapGL(
            myLocationTrackingMode: MyLocationTrackingMode.Tracking,
            myLocationEnabled: true,
            trackCameraPosition: true,
            styleString: dotenv.env['VIETMAP_STRING_KEY']!,
            initialCameraPosition: CameraPosition(
              target: markerPosition, // Chuyển đến vị trí của facility
              zoom: 15,
            ),
            onMapCreated: (VietmapController controller) {
              setState(() {
                _mapController = controller;
              });
            },
          ),
          _mapController == null
              ? SizedBox.shrink()
              : MarkerLayer(
                  markers: [
                    Marker(
                      alignment: Alignment.bottomCenter,
                      height: 50,
                      width: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black..withOpacity(0.1),
                              spreadRadius: 0.2,
                              blurRadius: 32,
                            ),
                          ],
                        ),
                        child: SvgPicture.asset(
                          'assets/vectors/vector_location_icon.svg',
                          width: 80,
                          height: 80,
                        ),
                      ),
                      latLng: markerPosition,
                    )
                  ],
                  mapController: _mapController!,
                ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: GlobalVariables.green,
              onPressed: _goToFacility,
              child: Icon(
                Icons.my_location,
                color: GlobalVariables.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
