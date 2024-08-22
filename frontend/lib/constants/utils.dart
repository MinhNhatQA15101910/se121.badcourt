import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<File?> pickOneImage() async {
  try {
    var files = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (files != null && files.files.isNotEmpty) {
      for (var f in files.files) {
        return File(f.path!);
      }
    }
  } catch (e) {
    debugPrint(e.toString());
  }

  return null;
}

Future<List<File>> pickMultipleImages() async {
  List<File> images = [];

  try {
    var result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      for (var file in result.files) {
        if (file.path != null) {
          images.add(File(file.path!));
        }
      }
    } else {
      debugPrint("No images selected or result is null");
    }
  } catch (e) {
    debugPrint("Error picking images: $e");
  }

  return images;
}

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

  SharedPreferences prefs = await SharedPreferences.getInstance();
  LocationData locationData = await location.getLocation();
  prefs.setBool('has-permission', true);
  prefs.setDouble('latitude', locationData.latitude!);
  print('Latitude: ${locationData.latitude}');
  prefs.setDouble('longitude', locationData.longitude!);
  print('Longitude: ${locationData.longitude}');
}
