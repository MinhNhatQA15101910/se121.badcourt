import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/models/active.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/models/manager_info.dart';
import 'package:frontend/models/image_custom.dart';

class NewFacilityProvider extends ChangeNotifier {
  Facility _newFacility = Facility(
    id: 'default_id',
    userId: 'default_userId',
    facilityName: 'Default Facility Name',
    facebookUrl: 'https://www.facebook.com/default',
    description: 'This is a default facility description.',
    policy: 'Default policy for this facility.',
    userImageUrl: 'https://via.placeholder.com/150',
    facilityImageUrl: 'https://via.placeholder.com/150',
    facilityImages: [
      ImageCustom(
        id: 'default_image_id_1',
        url: 'https://via.placeholder.com/150',
        isMain: true,
        type: 'image',
      ),
      ImageCustom(
        id: 'default_image_id_2',
        url: 'https://via.placeholder.com/200',
        isMain: false,
        type: 'image',
      ),
    ],
    courtsAmount: 1,
    detailAddress: '123 Default Street, Default City',
    province: 'Default Province',
    lon: 0,
    lat: 0,
    ratingAvg: 4.5,
    totalRating: 100,
    state: 'Pending',
    createdAt: DateTime.now().millisecondsSinceEpoch,
    minPrice: 0,
    maxPrice: 0,
    managerInfo: ManagerInfo(
      fullName: 'Default Manager',
      email: 'manager@example.com',
      phoneNumber: '0123456789',
      citizenId: '123456789',
      citizenImageFront: ImageCustom(
        id: 'default_citizen_front_id',
        url: 'https://via.placeholder.com/150',
        isMain: true,
        type: 'image',
      ),
      citizenImageBack: ImageCustom(
        id: 'default_citizen_back_id',
        url: 'https://via.placeholder.com/150',
        isMain: true,
        type: 'image',
      ),
      bankCardFront: ImageCustom(
        id: 'default_bank_front_id',
        url: 'https://via.placeholder.com/150',
        isMain: true,
        type: 'image',
      ),
      bankCardBack: ImageCustom(
        id: 'default_bank_back_id',
        url: 'https://via.placeholder.com/150',
        isMain: true,
        type: 'image',
      ),
      businessLicenseImages: [
        ImageCustom(
          id: 'default_license_id_1',
          url: 'https://via.placeholder.com/150',
          isMain: true,
          type: 'image',
        ),
        ImageCustom(
          id: 'default_license_id_2',
          url: 'https://via.placeholder.com/200',
          isMain: false,
          type: 'image',
        ),
      ],
    ),
    activeAt: Active(
      schedule: {},
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
