import 'dart:convert';

class Facility {
  final String id;
  final String userId;
  final String name;
  final String facebookUrl;
  final String phoneNumber;
  final int courtsAmount;
  final String detailAddress;
  final String province;
  final double latitude;
  final double longitude;
  final double ratingAvg;
  final int totalRating;
  final Active activeAt;
  final int registeredAt;
  final List<String> imageUrls;
  final String description;
  final String policy;
  final int maxPrice;
  final int minPrice;
  final ManagerInfo managerInfo;

  Facility({
    required this.id,
    required this.userId,
    required this.name,
    required this.facebookUrl,
    required this.phoneNumber,
    required this.courtsAmount,
    required this.detailAddress,
    required this.province,
    required this.latitude,
    required this.longitude,
    required this.ratingAvg,
    required this.totalRating,
    required this.activeAt,
    required this.registeredAt,
    required this.imageUrls,
    required this.description,
    required this.policy,
    required this.maxPrice,
    required this.minPrice,
    required this.managerInfo,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'user_id': userId,
      'name': name,
      'facebook_url': facebookUrl,
      'phone_number': phoneNumber,
      'courts_amount': courtsAmount,
      'detail_address': detailAddress,
      'province': province,
      'latitude': latitude,
      'longitude': longitude,
      'rating_avg': ratingAvg,
      'total_rating': totalRating,
      'active_at': activeAt.toMap(),
      'registered_at': registeredAt,
      'image_urls': imageUrls,
      'description': description,
      'policy': policy,
      'max_price': maxPrice,
      'min_price': minPrice,
      'manager_info': managerInfo.toMap(),
    };
  }

  factory Facility.fromMap(Map<String, dynamic> map) {
    return Facility(
      id: map['_id'] ?? '',
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
      facebookUrl: map['facebook_url'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      courtsAmount: map['courts_amount'] ?? 0,
      detailAddress: map['detail_address'] ?? '',
      province: map['province'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      ratingAvg: map['rating_avg']?.toDouble() ?? 0.0,
      totalRating: map['total_rating'] ?? 0,
      activeAt: Active.fromMap(map['active_at'] ?? {}),
      registeredAt: map['registered_at'] ?? 0,
      imageUrls: List<String>.from(map['image_urls'] ?? []),
      description: map['description'] ?? '',
      policy: map['policy'] ?? '',
      maxPrice: map['max_price'] ?? 0,
      minPrice: map['min_price'] ?? 0,
      managerInfo: ManagerInfo.fromMap(map['manager_info'] ?? {}),
    );
  }

  String toJson() => json.encode(toMap());

  factory Facility.fromJson(String source) =>
      Facility.fromMap(json.decode(source));

  Facility copyWith({
    String? id,
    String? userId,
    String? name,
    String? facebookUrl,
    String? phoneNumber,
    int? courtsAmount,
    String? detailAddress,
    String? province,
    double? latitude,
    double? longitude,
    double? ratingAvg,
    int? totalRating,
    Active? activeAt,
    int? registeredAt,
    List<String>? imageUrls,
    String? description,
    String? policy,
    int? maxPrice,
    int? minPrice,
    ManagerInfo? managerInfo,
  }) {
    return Facility(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      courtsAmount: courtsAmount ?? this.courtsAmount,
      detailAddress: detailAddress ?? this.detailAddress,
      province: province ?? this.province,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      totalRating: totalRating ?? this.totalRating,
      activeAt: activeAt ?? this.activeAt,
      registeredAt: registeredAt ?? this.registeredAt,
      imageUrls: imageUrls ?? this.imageUrls,
      description: description ?? this.description,
      policy: policy ?? this.policy,
      maxPrice: maxPrice ?? this.maxPrice,
      minPrice: minPrice ?? this.minPrice,
      managerInfo: managerInfo ?? this.managerInfo,
    );
  }

  bool hasDay(String day) {
    return activeAt.schedule.containsKey(day.toLowerCase());
  }
}

class Active {
  final Map<String, PeriodTime> schedule;

  Active({required this.schedule});

  factory Active.fromMap(Map<String, dynamic> map) {
    Map<String, PeriodTime> schedule = {};
    map.forEach((key, value) {
      if (key != '_id') {
        schedule[key] = PeriodTime.fromMap(value);
      }
    });
    return Active(schedule: schedule);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    schedule.forEach((key, value) {
      map[key] = value.toMap();
    });
    return map;
  }
}

class PeriodTime {
  final int hourFrom;
  final int hourTo;

  PeriodTime({required this.hourFrom, required this.hourTo});

  factory PeriodTime.fromMap(Map<String, dynamic> map) {
    return PeriodTime(
      hourFrom: map['hour_from'] ?? 0,
      hourTo: map['hour_to'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hour_from': hourFrom,
      'hour_to': hourTo,
    };
  }
}

class ManagerInfo {
  final String fullName;
  final String email;
  final String citizenId;
  final String citizenImageUrlFront;
  final String citizenImageUrlBack;
  final String bankCardUrlFront;
  final String bankCardUrlBack;
  final List<String> businessLicenseImageUrls;
  final String id;

  ManagerInfo({
    required this.fullName,
    required this.email,
    required this.citizenId,
    required this.citizenImageUrlFront,
    required this.citizenImageUrlBack,
    required this.bankCardUrlFront,
    required this.bankCardUrlBack,
    required this.businessLicenseImageUrls,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'full_name': fullName,
      'email': email,
      'citizen_id': citizenId,
      'citizen_image_url_front': citizenImageUrlFront,
      'citizen_image_url_back': citizenImageUrlBack,
      'bank_card_url_front': bankCardUrlFront,
      'bank_card_url_back': bankCardUrlBack,
      'business_license_image_urls': businessLicenseImageUrls,
      '_id': id,
    };
  }

  factory ManagerInfo.fromMap(Map<String, dynamic> map) {
    return ManagerInfo(
      fullName: map['full_name'] ?? '',
      email: map['email'] ?? '',
      citizenId: map['citizen_id'] ?? '',
      citizenImageUrlFront: map['citizen_image_url_front'] ?? '',
      citizenImageUrlBack: map['citizen_image_url_back'] ?? '',
      bankCardUrlFront: map['bank_card_url_front'] ?? '',
      bankCardUrlBack: map['bank_card_url_back'] ?? '',
      businessLicenseImageUrls:
          List<String>.from(map['business_license_image_urls'] ?? []),
      id: map['_id'] ?? '',
    );
  }

  ManagerInfo copyWith({
    String? fullName,
    String? email,
    String? citizenId,
    String? citizenImageUrlFront,
    String? citizenImageUrlBack,
    String? bankCardUrlFront,
    String? bankCardUrlBack,
    List<String>? businessLicenseImageUrls,
    String? id,
  }) {
    return ManagerInfo(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      citizenId: citizenId ?? this.citizenId,
      citizenImageUrlFront: citizenImageUrlFront ?? this.citizenImageUrlFront,
      citizenImageUrlBack: citizenImageUrlBack ?? this.citizenImageUrlBack,
      bankCardUrlFront: bankCardUrlFront ?? this.bankCardUrlFront,
      bankCardUrlBack: bankCardUrlBack ?? this.bankCardUrlBack,
      businessLicenseImageUrls:
          businessLicenseImageUrls ?? this.businessLicenseImageUrls,
      id: id ?? this.id,
    );
  }
}
