import 'package:flutter/material.dart';
import 'package:frontend/models/facility.dart';

class PlayerCurrentFacilityProvider extends ChangeNotifier {
  Facility _currentFacility = Facility(
    id: '',
    userId: '',
    name: '',
    facebookUrl: '',
    phoneNumber: '',
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
      citizenId: '',
      citizenImageUrlFront: '',
      citizenImageUrlBack: '',
      bankCardUrlFront: '',
      bankCardUrlBack: '',
      businessLicenseImageUrls: [],
      id: '',
    ),
  );

  Facility get currentFacility => _currentFacility;

  void setFacility(Facility facility) {
    _currentFacility = facility;
    notifyListeners();
  }
}
