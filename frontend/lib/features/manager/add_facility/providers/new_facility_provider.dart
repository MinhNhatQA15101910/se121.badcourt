import 'package:flutter/material.dart';
import 'package:frontend/models/facility.dart';

class NewFacilityProvider extends ChangeNotifier {
  Facility _newFacility = Facility(
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

  Facility get newFacility => _newFacility;

  void setFacility(Facility facility) {
    _newFacility = facility;
    notifyListeners();
  }
}
