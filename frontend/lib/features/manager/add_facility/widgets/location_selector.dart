import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/common/widgets/loader.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/add_facility/models/detail_address.dart';
import 'package:frontend/features/manager/add_facility/screens/map_screen.dart';
import 'package:frontend/features/manager/add_facility/services/add_facility_service.dart';
import 'package:frontend/common/widgets/label_display.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';

class LocationSelector extends StatefulWidget {
  const LocationSelector({
    super.key,
    required this.selectedAddress,
    required this.onAddressSelected,
    this.lat,
    this.lng,
  });

  final DetailAddress? selectedAddress;
  final void Function(DetailAddress) onAddressSelected;
  final double? lat;
  final double? lng;

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  final addFacilityService = AddFacilityService();

  var _isGettingLocation = false;

  String get locationImage {
    if (widget.selectedAddress == null) {
      return '';
    }

    final lng = widget.lng != 0.0 ? widget.lng : widget.selectedAddress!.lng;
    final lat = widget.lat != 0.0 ? widget.lat : widget.selectedAddress!.lat;

    return 'https://api.mapbox.com/styles/v1/mapbox/streets-v12/static/pin-l-a+f00($lng,$lat)/$lng,$lat,14/600x300?access_token=${dotenv.env['MAPBOX_ACCESS_TOKEN']}';
  }

  @override
  void initState() {
    super.initState();

    if (widget.lat != null && widget.lng != null) {
      _savePlace(widget.lat!, widget.lng!);
    }
  }

  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });

    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final lng = locationData.longitude;

    print('Latitude: $lat, Longitude: $lng');

    if (lat == null || lng == null) {
      return;
    }

    _savePlace(lat, lng);
  }

  void _navigateToMapScreen() async {
    final DetailAddress? selectedAddress = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapScreen()),
    );

    if (selectedAddress != null) {
      widget.onAddressSelected(selectedAddress);
    }
  }

  void _savePlace(double latitude, double longitude) async {
    String? refId = await addFacilityService.fetchAddressRefId(
      context: context,
      lat: latitude,
      lng: longitude,
    );

    var detailAddress = await addFacilityService.fetchDetailAddress(
      refId: refId!,
    );

    widget.onAddressSelected(detailAddress!);

    setState(() {
      _isGettingLocation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No location chosen',
      style: GoogleFonts.inter(
        fontSize: 16,
        color: GlobalVariables.green,
        fontWeight: FontWeight.bold,
      ),
    );

    if (widget.selectedAddress != null) {
      previewContent = Image.network(
        locationImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (_isGettingLocation) {
      previewContent = const Loader();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelDisplay(
          label: 'Select a location on the map',
          isRequired: true,
        ),
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: GlobalVariables.lightGreen),
          ),
          width: double.infinity,
          height: 150,
          child: previewContent,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0),
              child: InkWell(
                onTap: _getCurrentLocation,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: GlobalVariables.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Current location',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: GlobalVariables.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: InkWell(
                onTap: _navigateToMapScreen,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.map,
                      color: GlobalVariables.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Select map',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: GlobalVariables.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
