import 'dart:convert';

class Facility {
  final String id;
  final String userId;
  final String name;
  final String facebookUrl;
  final String phoneNumber;
  final int courtsAmount;
  final String detailAddress;
  final double latitude;
  final double longitude;
  final double ratingAvg;
  final int totalRating;
  final Active activeAt;
  final int registeredAt;
  final List<String> imageUrls;

  Facility({
    required this.id,
    required this.userId,
    required this.name,
    required this.facebookUrl,
    required this.phoneNumber,
    required this.courtsAmount,
    required this.detailAddress,
    required this.latitude,
    required this.longitude,
    required this.ratingAvg,
    required this.totalRating,
    required this.activeAt,
    required this.registeredAt,
    required this.imageUrls,
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
      'latitude': latitude,
      'longitude': longitude,
      'rating_avg': ratingAvg,
      'total_rating': totalRating,
      'active_at': activeAt.toMap(),
      'registered_at': registeredAt,
      'image_urls': imageUrls,
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
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      ratingAvg: map['rating_avg']?.toDouble() ?? 0.0,
      totalRating: map['total_rating'] ?? 0,
      activeAt: Active.fromMap(map['active_at'] ?? {}),
      registeredAt: map['registered_at'] ?? 0,
      imageUrls: List<String>.from(map['image_urls'] ?? []),
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
    double? latitude,
    double? longitude,
    double? ratingAvg,
    int? totalRating,
    Active? activeAt,
    int? registeredAt,
    List<String>? imageUrls,
  }) {
    return Facility(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      courtsAmount: courtsAmount ?? this.courtsAmount,
      detailAddress: detailAddress ?? this.detailAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      totalRating: totalRating ?? this.totalRating,
      activeAt: activeAt ?? this.activeAt,
      registeredAt: registeredAt ?? this.registeredAt,
      imageUrls: imageUrls ?? this.imageUrls,
    );
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
