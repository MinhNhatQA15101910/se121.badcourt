import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/common/widgets/custom_button.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/add_facility/models/detail_address.dart';
import 'package:frontend/features/manager/add_facility/services/add_facility_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:flutter/material.dart';

class PlayerMapScreen extends StatefulWidget {
  static const String routeName = '/playerMap';
  const PlayerMapScreen({super.key});

  @override
  State<PlayerMapScreen> createState() => _PlayerMapScreenState();
}

class _PlayerMapScreenState extends State<PlayerMapScreen> {
  final _searchController = TextEditingController();
  final _addFacilityService = AddFacilityService();
  VietmapController? _mapController;
  LatLng markerPosition = LatLng(
      GlobalVariables.facility.latitude, GlobalVariables.facility.longitude);
  String _searchCode = "";
  DetailAddress _detailAddress = DetailAddress(
    display: '',
    name: '',
    hsNum: '',
    street: '',
    address: '',
    cityId: 0,
    city: '',
    districtId: 0,
    district: '',
    wardId: 0,
    ward: '',
    lat: 0.0,
    lng: 0.0,
  );

  @override
  void initState() {
    super.initState();
  }

  void OnUpdateLocation() {
    setState(() {
      markerPosition = LatLng(GlobalVariables.facility.latitude,
          GlobalVariables.facility.longitude);
    });
  }

  Future<void> _fetchSearchCode() async {
    final seachCode = await _addFacilityService.fetchAddressRefId(
        vietmap_api_key, _searchController.text);
    if (seachCode != null) {
      setState(() {
        _searchCode = seachCode;
      });
    }
  }

  Future<void> _fetchDetailAddress() async {
    final detailAddress = await _addFacilityService.fetchDetailAddress(
      vietmap_api_key,
      _searchCode,
    );

    if (detailAddress != null) {
      setState(() {
        _detailAddress = detailAddress;
        markerPosition = LatLng(_detailAddress.lat, _detailAddress.lng);
      });

      // Animate the map camera to the new marker position
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: markerPosition, zoom: 15),
        ),
      );
    }
  }

  void _pingMarker() async {
    if (_mapController != null) {
      // Get the current location
      LatLng? currentLocation = await _mapController?.requestMyLocationLatLng();

      if (currentLocation != null) {
        setState(() {
          markerPosition = currentLocation;
        });

        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: markerPosition, zoom: 15),
          ),
        );

        setState(() {});

        Future.delayed(Duration(seconds: 1), () {
          setState(() {});
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: GlobalVariables.green,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Detail Adress',
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
      body: Container(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            VietmapGL(
              myLocationEnabled: true,
              trackCameraPosition: true,
              styleString: vietmap_string_key,
              initialCameraPosition: CameraPosition(
                  target: LatLng(GlobalVariables.facility.latitude,
                      GlobalVariables.facility.longitude),
                  zoom: 15),
              onMapCreated: (VietmapController controller) {
                setState(() {
                  _mapController = controller;
                });
              },
            ),
            _mapController == null
                ? SizedBox.shrink()
                : MarkerLayer(markers: [
                    Marker(
                        alignment: Alignment.bottomCenter,
                        height: 50,
                        width: 50,
                        child: const Icon(
                          Icons.location_on_outlined,
                          color: GlobalVariables.red,
                          size: 50,
                        ),
                        latLng: markerPosition)
                  ], mapController: _mapController!),
            Column(
              children: [
                SizedBox(
                  height: 12,
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        child: Expanded(
                          child: TextFormField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Find badminton facilities',
                              hintStyle: GoogleFonts.inter(
                                color: GlobalVariables.darkGrey,
                                fontSize: 16,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
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
                              fillColor: GlobalVariables.white,
                              filled: true,
                              prefixIcon: Icon(
                                Icons.search,
                                color: GlobalVariables.darkGrey,
                              ),
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                            ),
                            validator: (facilityName) {
                              if (facilityName == null ||
                                  facilityName.isEmpty) {
                                return 'Please enter your facility name.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      GestureDetector(
                        onTap: _pingMarker,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: GlobalVariables.grey,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/vectors/vector_reality_location.svg',
                              width: 32,
                              height: 32,
                              // ignore: deprecated_member_use
                              color: GlobalVariables.green,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                Container(
                  color: GlobalVariables.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          child: CustomButton(
                            onTap: () {
                              _fetchSearchCode();
                              _fetchDetailAddress();
                            },
                            buttonText: 'Search',
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
                            onTap: OnUpdateLocation,
                            buttonText: 'Address',
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
            )
          ],
        ),
      ),
    );
  }
}
