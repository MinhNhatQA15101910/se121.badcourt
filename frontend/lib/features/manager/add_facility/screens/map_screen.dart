import 'package:flutter/material.dart';
import 'package:frontend/features/manager/add_facility/providers/address_provider.dart';
import 'package:frontend/features/manager/add_facility/services/add_facility_service.dart';
import 'package:provider/provider.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/features/manager/add_facility/models/detail_address.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/common/widgets/custom_button.dart';

class MapScreen extends StatefulWidget {
  static const String routeName = '/manager/map';
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _searchController = TextEditingController();
  VietmapController? _mapController;
  LatLng markerPosition = LatLng(10.762317, 106.654551);
  final _addFacilityService = AddFacilityService();
  String _refId = "";
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

    final addressProvider = Provider.of<AddressProvider>(
      context,
      listen: false,
    );
    final currentAddess = addressProvider.currentAddress;
    if (currentAddess.lat != 0.0 && currentAddess.lng != 0.0) {
      setState(() {
        markerPosition = LatLng(
          currentAddess.lat,
          currentAddess.lng,
        );
        _detailAddress = currentAddess;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: markerPosition, zoom: 15),
          ),
        );
      });
    }
  }

  Future<void> _updateAddress(LatLng latLng) async {
    try {
      final refId = await _addFacilityService.fetchAddressRefId(
        context: context,
        lat: latLng.latitude,
        lng: latLng.longitude,
      );

      if (refId != null) {
        setState(() {
          _refId = refId;
        });

        final detailAddress = await _addFacilityService.fetchDetailAddress(
          refId: _refId,
        );

        if (detailAddress != null) {
          setState(() {
            _detailAddress = detailAddress;
            markerPosition = LatLng(_detailAddress.lat, _detailAddress.lng);
          });

          final addressProvider = Provider.of<AddressProvider>(
            context,
            listen: false,
          );
          addressProvider.setAddress(detailAddress);
        }
      }
    } catch (e) {
      print('Error during search: $e');
    }

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 15),
      ),
    );
  }

  Future<void> _performSearch(String value) async {
    if (value.isNotEmpty) {
      try {
        final refId = await _addFacilityService.fetchAddressRefId(
          context: context,
          searchText: value,
        );

        if (refId != null) {
          setState(() {
            _refId = refId;
          });

          final detailAddress = await _addFacilityService.fetchDetailAddress(
            refId: _refId,
          );

          if (detailAddress != null) {
            setState(() {
              _detailAddress = detailAddress;
              markerPosition = LatLng(_detailAddress.lat, _detailAddress.lng);
            });

            _mapController?.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: markerPosition, zoom: 15),
              ),
            );
          }
        }
      } catch (e) {
        print('Error during search: $e');
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
          title: Text(
            'Select a location',
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
        alignment: Alignment.topCenter,
        children: [
          VietmapGL(
            myLocationTrackingMode: MyLocationTrackingMode.Tracking,
            myLocationEnabled: true,
            trackCameraPosition: true,
            styleString: dotenv.env['VIETMAP_STRING_KEY']!,
            initialCameraPosition:
                CameraPosition(target: LatLng(10.762317, 106.654551), zoom: 15),
            onMapCreated: (VietmapController controller) {
              setState(() {
                _mapController = controller;
              });
            },
            onMapClick: (point, latLng) {
              _updateAddress(latLng);
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
                              color: Colors.black.withOpacity(0.1),
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
          Column(
            children: [
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Find address',
                          hintStyle: GoogleFonts.inter(
                            color: GlobalVariables.darkGrey,
                            fontSize: 16,
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
                        onFieldSubmitted: (value) async {
                          if (value.isNotEmpty) {
                            _performSearch(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: Container()),
              Container(
                color: GlobalVariables.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        onTap: () {
                          Navigator.of(context).pop(_detailAddress);
                        },
                        buttonText: 'Select',
                        borderColor: GlobalVariables.green,
                        fillColor: GlobalVariables.green,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
