import 'package:flutter/material.dart';
import 'package:frontend/models/active.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/models/manager_info.dart';
import 'package:frontend/models/file_dto.dart';

class CurrentFacilityProvider extends ChangeNotifier {
  Facility _currentFacility = Facility(
    id: 'default_id',
    userId: 'default_userId',
    facilityName: 'Default Facility Name',
    facebookUrl: 'https://www.facebook.com/default',
    description: 'This is a default facility description.',
    policy: 'Default policy for this facility.',
    facilityImages: [
      FileDto(
        id: 'default_image_id_1',
        url: 'https://via.placeholder.com/150',
        isMain: true,
        fileType: 'image',
      ),
      FileDto(
        id: 'default_image_id_2',
        url: 'https://via.placeholder.com/200',
        isMain: false,
        fileType: 'image',
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
    registeredAt: DateTime.now(),
    minPrice: 0,
    maxPrice: 0,
    managerInfo: ManagerInfo(
      fullName: 'Default Manager',
      email: 'manager@example.com',
      phoneNumber: '0123456789',
      citizenId: '123456789',
      citizenImageFront: FileDto(
        id: 'default_citizen_front_id',
        url: 'https://via.placeholder.com/150',
        isMain: true,
        fileType: 'image',
      ),
      citizenImageBack: FileDto(
        id: 'default_citizen_back_id',
        url: 'https://via.placeholder.com/150',
        isMain: true,
        fileType: 'image',
      ),
      bankCardFront: FileDto(
        id: 'default_bank_front_id',
        url: 'https://via.placeholder.com/150',
        isMain: true,
        fileType: 'image',
      ),
      bankCardBack: FileDto(
        id: 'default_bank_back_id',
        url: 'https://via.placeholder.com/150',
        isMain: true,
        fileType: 'image',
      ),
      businessLicenseImages: [
        FileDto(
          id: 'default_license_id_1',
          url: 'https://via.placeholder.com/150',
          isMain: true,
          fileType: 'image',
        ),
        FileDto(
          id: 'default_license_id_2',
          url: 'https://via.placeholder.com/200',
          isMain: false,
          fileType: 'image',
        ),
      ],
    ),
    activeAt: Active(
      schedule: {},
    ),
    userName: '',
  );

  Facility get currentFacility => _currentFacility;

  void setFacility(Facility facility) {
    _currentFacility = facility;
    notifyListeners();
  }
}
