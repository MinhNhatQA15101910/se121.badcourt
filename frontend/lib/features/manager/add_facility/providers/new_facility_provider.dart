import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/models/facility.dart';

class NewFacilityProvider extends ChangeNotifier {
  Facility _newFacility = Facility(
    id: '',
    userId: '',
    name: '',
    facebookUrl: '',
    courtsAmount: 0,
    detailAddress: '',
    province: '',
    latitude: 0.0,
    longitude: 0.0,
    ratingAvg: 0.0,
    totalRating: 0,
    activeAt: Active(schedule: {}),
    registeredAt: 0,
    imageUrls: [],
    description: '',
    policy: '',
    maxPrice: 0,
    minPrice: 0,
    managerInfo: ManagerInfo(
      fullName: '',
      email: '',
      phoneNumber: '',
      citizenId: '',
      citizenImageUrlFront: '',
      citizenImageUrlBack: '',
      bankCardUrlFront: '',
      bankCardUrlBack: '',
      businessLicenseImageUrls: [],
      id: '',
    ),
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
