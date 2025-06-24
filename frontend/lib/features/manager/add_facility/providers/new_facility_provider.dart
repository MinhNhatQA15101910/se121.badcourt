import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/models/image_custom.dart';
import 'package:frontend/models/manager_info.dart';

class NewFacilityProvider extends ChangeNotifier {
  Facility _newFacility = Facility(
    id: '',
    facilityName: '',
    facebookUrl: '',
    description: '',
    policy: '',
    userId: '',
    facilityImages: [],
    courtsAmount: 0,
    minPrice: 0,
    maxPrice: 0,
    detailAddress: '',
    province: '',
    lat: 0.0,
    lon: 0.0,
    ratingAvg: 0.0,
    totalRating: 0,
    state: '',
    registeredAt: DateTime.now(),
    managerInfo: ManagerInfo(
      fullName: '',
      email: '',
      phoneNumber: '',
      citizenId: '',
      citizenImageFront: ImageCustom(id: '', url: '', isMain: false, type: ''),
      citizenImageBack: ImageCustom(id: '', url: '', isMain: false, type: ''),
      bankCardFront: ImageCustom(id: '', url: '', isMain: false, type: ''),
      bankCardBack: ImageCustom(id: '', url: '', isMain: false, type: ''),
      businessLicenseImages: [],
    ),
    userName: '',
  );

  List<File> _facilityImages = [];
  List<File> _licenseImages = [];
  File _frontCitizenIdImage = File('');
  File _backCitizenIdImage = File('');
  File _frontBankCardImage = File('');
  File _backBankCardImage = File('');
  
  // Add mode tracking
  bool _isEditMode = false;
  Facility? _originalFacility;

  // Getters
  Facility get newFacility => _newFacility;
  List<File> get facilityImages => _facilityImages;
  List<File> get licenseImages => _licenseImages;
  File get frontCitizenIdImage => _frontCitizenIdImage;
  File get backCitizenIdImage => _backCitizenIdImage;
  File get frontBankCardImage => _frontBankCardImage;
  File get backBankCardImage => _backBankCardImage;
  bool get isEditMode => _isEditMode;
  Facility? get originalFacility => _originalFacility;

  // Initialize for editing existing facility
  void initializeForEdit(Facility facility) {
    _isEditMode = true;
    _originalFacility = facility;
    _newFacility = facility.copyWith();
    notifyListeners();
  }

  // Initialize for creating new facility
  void initializeForCreate() {
    _isEditMode = false;
    _originalFacility = null;
    _newFacility = Facility(
      id: '',
      facilityName: '',
      facebookUrl: '',
      description: '',
      policy: '',
      userId: '',
      facilityImages: [],
      courtsAmount: 0,
      minPrice: 0,
      maxPrice: 0,
      detailAddress: '',
      province: '',
      lat: 0.0,
      lon: 0.0,
      ratingAvg: 0.0,
      totalRating: 0,
      state: '',
      registeredAt: DateTime.now(),
      managerInfo: ManagerInfo(
        fullName: '',
        email: '',
        phoneNumber: '',
        citizenId: '',
        citizenImageFront: ImageCustom(id: '', url: '', isMain: false, type: ''),
        citizenImageBack: ImageCustom(id: '', url: '', isMain: false, type: ''),
        bankCardFront: ImageCustom(id: '', url: '', isMain: false, type: ''),
        bankCardBack: ImageCustom(id: '', url: '', isMain: false, type: ''),
        businessLicenseImages: [],
      ),
      userName: '',
    );
    _clearAllImages();
    notifyListeners();
  }

  void _clearAllImages() {
    _facilityImages.clear();
    _licenseImages.clear();
    _frontCitizenIdImage = File('');
    _backCitizenIdImage = File('');
    _frontBankCardImage = File('');
    _backBankCardImage = File('');
  }

  // Setters
  void setFacility(Facility facility) {
    _newFacility = facility;
    notifyListeners();
  }

  void setFacilityImageUrls(List<File> images) {
    _facilityImages = images;
    notifyListeners();
  }

  void setLicenseImages(List<File> images) {
    _licenseImages = images;
    notifyListeners();
  }

  void setFrontCitizenIdImage(File image) {
    _frontCitizenIdImage = image;
    notifyListeners();
  }

  void setBackCitizenIdImage(File image) {
    _backCitizenIdImage = image;
    notifyListeners();
  }

  void setFrontBankCardImage(File image) {
    _frontBankCardImage = image;
    notifyListeners();
  }

  void setBackBankCardImage(File image) {
    _backBankCardImage = image;
    notifyListeners();
  }

  // Reset provider
  void reset() {
    initializeForCreate();
  }
}
