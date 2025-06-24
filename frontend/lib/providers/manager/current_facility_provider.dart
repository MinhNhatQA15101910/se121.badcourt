import 'package:flutter/material.dart';
import 'package:frontend/models/active.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/models/manager_info.dart';
import 'package:frontend/models/image_custom.dart';

class CurrentFacilityProvider extends ChangeNotifier {
  Facility _currentFacility = Facility(
    id: 'default_id',
    userId: 'default_userId',
    facilityName: 'Default Facility Name',
    facebookUrl: 'https://www.facebook.com/default',
    description: 'This is a default facility description.',
    policy: 'Default policy for this facility.',
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
    registeredAt: DateTime.now(),
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
    userName: '',
  );

  Facility get currentFacility => _currentFacility;

  void setFacility(Facility facility) {
    _currentFacility = facility;
    notifyListeners();
  }
}
