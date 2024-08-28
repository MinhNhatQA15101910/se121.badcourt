import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/add_facility/models/detail_address.dart';
import 'package:frontend/features/manager/add_facility/providers/address_provider.dart';
import 'package:frontend/features/manager/add_facility/screens/map_screen.dart';
import 'package:frontend/features/manager/add_facility/widgets/label_display.dart';
import 'package:frontend/features/manager/add_facility/widgets/map_widget.dart'; // Import MapWidget
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LocationSelector extends StatelessWidget {
  const LocationSelector({
    super.key,
    required this.selectedAddress,
  });

  final DetailAddress selectedAddress;

  void navigateToMapScreen(BuildContext context) async {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelDisplay(
          label: 'Select a location on the map',
          isRequired: true,
        ),

        // Add the MapWidget below the buttons
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: MapWidget(detailAddress: selectedAddress),
        ),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: double.maxFinite,
            height: 48,
            child: ElevatedButton(
              onPressed: () => navigateToMapScreen(context),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: GlobalVariables.green,
                    width: 1,
                  ),
                ),
                backgroundColor: GlobalVariables.white,
                elevation: 0,
              ),
              child: Icon(
                Icons.add_location_alt_outlined,
                color: GlobalVariables.green,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
