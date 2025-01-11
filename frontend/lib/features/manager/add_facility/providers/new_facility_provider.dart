import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/models/active.dart';
import 'package:frontend/models/coordinates.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/models/location.dart';
import 'package:frontend/models/manager_info.dart';

class NewFacilityProvider extends ChangeNotifier {
  Facility _newFacility = Facility(
    id: 'default_id',
    userId: 'default_userId',
    name: 'Default Facility Name',
    facebookUrl: 'https://www.facebook.com/default',
    courtsAmount: 1,
    detailAddress: 'Default Address, Default City',
    province: 'Default Province',
    location: Location(
      type: 'Point',
      coordinates: Coordinates(
        longitude: 106.0,
        latitude: 10.0,
      ),
    ),
    ratingAvg: 0.0,
    totalRating: 0,
    activeAt: Active(schedule: {}),
    registeredAt: DateTime.now().millisecondsSinceEpoch,
    description: 'Default description for the facility.',
    policy: 'Default policy for the facility.',
    maxPrice: 100000,
    minPrice: 50000,
    managerInfo: ManagerInfo(
      fullName: 'Default Manager',
      email: 'manager@example.com',
      phoneNumber: '0123456789',
      citizenId: '123456789',
      citizenImageUrlFront: 'https://via.placeholder.com/150',
      citizenImageUrlBack: 'https://via.placeholder.com/150',
      bankCardUrlFront: 'https://via.placeholder.com/150',
      bankCardUrlBack: 'https://via.placeholder.com/150',
      businessLicenseImageUrls: [
        'https://via.placeholder.com/150',
        'https://via.placeholder.com/200',
      ],
      id: 'default_manager_id',
    ),
    facilityImages: [
      FacilityImage(
        url: 'https://via.placeholder.com/150',
        isMain: true,
        publicId: 'default_image_id_1',
      ),
      FacilityImage(
        url: 'https://via.placeholder.com/200',
        isMain: false,
        publicId: 'default_image_id_2',
      ),
    ],
    isApproved: false,
    approvedAt: 0,
    distance: 0.0,
  );

  List<File> _facilityImages = [];
  File _frontCitizenIdImage = File('');
  File _backCitizenIdImage = File('');
  File _frontBankCardImage = File('');
  File _backBankCardImage = File('');
  List<File> _licenseImages = [];

  Facility get newFacility => _newFacility;
  List<File> get facilityImages => _facilityImages;
  File get frontCitizenIdImage => _frontCitizenIdImage;
  File get backCitizenIdImage => _backCitizenIdImage;
  File get frontBankCardImage => _frontBankCardImage;
  File get backBankCardImage => _backBankCardImage;
  List<File> get licenseImages => _licenseImages;

  void setFacility(Facility facility) {
    _newFacility = facility;
    notifyListeners();
  }

  void setFacilityImageUrls(List<File> facilityImages) {
    _facilityImages = facilityImages;
    notifyListeners();
  }

  void setFrontCitizenIdImage(File frontCitizenIdImage) {
    _frontCitizenIdImage = frontCitizenIdImage;
    notifyListeners();
  }

  void setBackCitizenIdImage(File backCitizenIdImage) {
    _backCitizenIdImage = backCitizenIdImage;
    notifyListeners();
  }

  void setFrontBankCardImage(File frontBankCardImage) {
    _frontBankCardImage = frontBankCardImage;
    notifyListeners();
  }

  void setBackBankCardImage(File backBankCardImage) {
    _backBankCardImage = backBankCardImage;
    notifyListeners();
  }

  void setLicenseImages(List<File> licenseImages) {
    _licenseImages = licenseImages;
    notifyListeners();
  }
}
