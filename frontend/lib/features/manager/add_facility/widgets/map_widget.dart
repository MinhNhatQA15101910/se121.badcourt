import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:frontend/features/manager/add_facility/providers/address_provider.dart';
import 'package:provider/provider.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:frontend/features/manager/add_facility/models/detail_address.dart';
import 'package:frontend/constants/global_variables.dart';

class MapWidget extends StatefulWidget {
  final DetailAddress? detailAddress;

  const MapWidget({
    Key? key,
    required this.detailAddress,
  }) : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  VietmapController? _mapController;
  LatLng markerPosition = LatLng(0.0, 0.0);
  bool _isMapInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.detailAddress == null ||
          (widget.detailAddress!.lat == 0.0 &&
              widget.detailAddress!.lng == 0.0)) {
        // Request current location if detailAddress is null or lat/lng is 0.0
        LatLng? currentLocation =
            await _mapController?.requestMyLocationLatLng();

        if (currentLocation != null) {
          // Create a new DetailAddress with the current location
          DetailAddress newAddress = DetailAddress(
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
            lat: currentLocation.latitude,
            lng: currentLocation.longitude,
          );

          // Use AddressProvider to update the address
          final addressProvider = Provider.of<AddressProvider>(
            context,
            listen: false,
          );
          addressProvider.setAddress(newAddress);

          setState(() {
            markerPosition = currentLocation;
          });
        }
      } else {
        setState(() {
          markerPosition =
              LatLng(widget.detailAddress!.lat, widget.detailAddress!.lng);
        });
      }

      if (_isMapInitialized) {
        _updateMap();
      }
    });
  }

  void _updateMap() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: markerPosition, zoom: 15),
        ),
      );
      _mapController!.addSymbol(
        SymbolOptions(
          geometry: markerPosition,
          iconImage: "marker-15",
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        children: [
          VietmapGL(
            myLocationTrackingMode: MyLocationTrackingMode.Tracking,
            myLocationEnabled: true,
            trackCameraPosition: true,
            styleString: dotenv.env['VIETMAP_STRING_KEY']!,
            initialCameraPosition: CameraPosition(
              target: markerPosition,
              zoom: 15,
            ),
            onMapCreated: (VietmapController controller) {
              setState(() {
                _mapController = controller;
                _isMapInitialized = true;
              });
              // Call _updateMap() to adjust camera and marker after the map is created
              _updateMap();
            },
            onStyleLoadedCallback: () {
              if (_isMapInitialized) {
                _updateMap();
              }
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
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: GlobalVariables.red,
                        size: 50,
                      ),
                      latLng: markerPosition,
                    )
                  ],
                  mapController: _mapController!,
                ),
        ],
      ),
    );
  }
}
