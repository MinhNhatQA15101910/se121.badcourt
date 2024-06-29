import 'package:flutter/material.dart';
import 'package:frontend/providers/location_provider.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

void getCurrentLocation(BuildContext context) async {
  Location location = Location();

  bool serviceEnabled;
  PermissionStatus permissionGranted;

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

  final locationProvider = Provider.of<LocationProvider>(
    context,
    listen: false,
  );
  locationProvider.setLocation(await location.getLocation());
}
