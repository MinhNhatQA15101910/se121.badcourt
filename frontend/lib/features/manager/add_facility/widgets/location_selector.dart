import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/loader.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/add_facility/models/detail_address.dart';
import 'package:frontend/features/manager/add_facility/providers/address_provider.dart';
import 'package:frontend/features/manager/add_facility/screens/map_screen.dart';
import 'package:frontend/features/manager/add_facility/services/add_facility_service.dart';
import 'package:frontend/features/manager/add_facility/widgets/label_display.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class LocationSelector extends StatefulWidget {
  const LocationSelector({
    super.key,
    required this.selectedAddress,
  });

  final DetailAddress? selectedAddress;

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  final addFacilityService = AddFacilityService();

  var _isGettingLocation = false;
  String get locationImage {
    final addressProvider = Provider.of<AddressProvider>(
      context,
      listen: false,
    );

    if (addressProvider.address == null) {
      return '';
    }

    final lng = addressProvider.address!.lng;
    final lat = addressProvider.address!.lat;

    return 'https://api.mapbox.com/styles/v1/mapbox/streets-v12/static/pin-l-a+f00($lng,$lat)/$lng,$lat,14/600x300?access_token=pk.eyJ1IjoiZG9taW5obmhhdDIwMDMiLCJhIjoiY2xydTB2cnVqMGNibTJrcDFiNXRjN3N4ZiJ9.-DHYngV7hjqTT__N7u5Ruw';
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

    if (lat == null || lng == null) {
      return;
    }

    _savePlace(lat, lng);
  }

  Widget _isValidateText(bool isValidateText) {
    String text = isValidateText ? 'Verified' : 'Not verified';
    Color textColor = isValidateText ? Colors.green : Colors.red;
    return Text(
      text,
      textAlign: TextAlign.start,
      style: GoogleFonts.inter(
        fontSize: 10,
        color: textColor,
        decoration: TextDecoration.underline,
        decorationColor: textColor,
        textStyle: const TextStyle(
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  void _navigateToMapScreen() async {
    final DetailAddress? selectedAddress = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapScreen()),
    );

    if (selectedAddress != null) {
      final addressProvider = Provider.of<AddressProvider>(
        context,
        listen: false,
      );
      addressProvider.setAddress(selectedAddress);
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

    final addressProvider = Provider.of<AddressProvider>(
      context,
      listen: false,
    );
    addressProvider.setAddress(detailAddress!);

    setState(() {
      _isGettingLocation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = context.watch<AddressProvider>();

    Widget previewContent = Text(
      'No location chosen',
      style: GoogleFonts.inter(
        fontSize: 16,
        color: GlobalVariables.green,
        fontWeight: FontWeight.bold,
      ),
    );

    if (addressProvider.address != null) {
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
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: GlobalVariables.lightGreen,
            ),
          ),
          child: previewContent,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
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
                      'Get Current Location',
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.map,
                    color: GlobalVariables.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Select on Map',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: GlobalVariables.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
