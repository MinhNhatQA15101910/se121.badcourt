import 'package:frontend/common/widgets/custom_button.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  static const String routeName = '/map';
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: GlobalVariables.green,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select a location',
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
              styleString:
                  'https://maps.vietmap.vn/api/maps/light/styles.json?apikey=506862bb03a3d71632bdeb7674a3625328cb7e5a9b011841',
              initialCameraPosition:
                  CameraPosition(target: LatLng(10.762317, 106.654551)),
              onMapCreated: (VietmapController controller) {
                setState(() {});
              },
            ),
            Column(
              children: [
                SizedBox(
                  height: 12,
                ),
                Container(
                  child: Container(
                    decoration: BoxDecoration(
                      color: GlobalVariables.lightGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),
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
                  child: CustomButton(
                      onTap: () => {},
                      buttonText: 'Select',
                      borderColor: GlobalVariables.green,
                      fillColor: GlobalVariables.green,
                      textColor: Colors.white),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
