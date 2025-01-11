import 'package:flutter/material.dart';
import 'package:frontend/models/active.dart';
import 'package:frontend/models/coordinates.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/models/location.dart';
import 'package:frontend/models/manager_info.dart';

class CurrentFacilityProvider extends ChangeNotifier {
  Facility _currentFacility = Facility(
  id: 'default_id',
  userId: 'default_userId',
  name: 'Default Facility Name',
  facebookUrl: 'https://www.facebook.com/default',
  courtsAmount: 1,
  detailAddress: '123 Default Street, Default City',
  province: 'Default Province',
  location: Location(
    type: 'Point',
    coordinates: Coordinates(
      longitude: 106.7000,
      latitude: 10.8000,
    ),
  ),
  ratingAvg: 4.5,
  totalRating: 100,
  activeAt: Active(schedule: {}),
  registeredAt: DateTime.now().millisecondsSinceEpoch,
  description: 'This is a default facility description.',
  policy: 'Default policy for this facility.',
  maxPrice: 200000,
  minPrice: 100000,
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


  Facility get currentFacility => _currentFacility;

  void setFacility(Facility facility) {
    _currentFacility = facility;
    notifyListeners();
  }
}
