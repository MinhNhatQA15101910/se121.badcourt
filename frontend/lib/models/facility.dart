import 'dart:convert';

import 'package:frontend/models/active.dart';
import 'package:frontend/models/image_custom.dart';
import 'package:frontend/models/manager_info.dart';

class Facility {
  final String id;
  final String facilityName;
  final String facebookUrl;
  final String description;
  final String policy;
  final String userId;
  final List<ImageCustom> facilityImages;
  final int courtsAmount;
  final int minPrice;
  final int maxPrice;
  final String detailAddress;
  final String province;
  final double lat;
  final double lon;
  final double ratingAvg;
  final int totalRating;
  final String state;
  final DateTime registeredAt;
  final ManagerInfo managerInfo;
  final Active? activeAt;
  final String userName;
  final String? userImageUrl;

  Facility({
    required this.id,
    required this.facilityName,
    required this.facebookUrl,
    required this.description,
    required this.policy,
    required this.userId,
    required this.facilityImages,
    required this.courtsAmount,
    required this.minPrice,
    required this.maxPrice,
    required this.detailAddress,
    required this.province,
    required this.lat,
    required this.lon,
    required this.ratingAvg,
    required this.totalRating,
    required this.state,
    required this.registeredAt,
    required this.managerInfo,
    this.activeAt,
    required this.userName,
    this.userImageUrl,
  });

  Facility copyWith({
    String? id,
    String? facilityName,
    String? facebookUrl,
    String? description,
    String? policy,
    String? userId,
    List<ImageCustom>? facilityImages,
    int? courtsAmount,
    int? minPrice,
    int? maxPrice,
    String? detailAddress,
    String? province,
    double? lat,
    double? lon,
    double? ratingAvg,
    int? totalRating,
    String? state,
    DateTime? registeredAt,
    ManagerInfo? managerInfo,
    Active? activeAt,
    String? userName,
    String? userImageUrl,
  }) {
    return Facility(
      id: id ?? this.id,
      facilityName: facilityName ?? this.facilityName,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      description: description ?? this.description,
      policy: policy ?? this.policy,
      userId: userId ?? this.userId,
      facilityImages: facilityImages ?? this.facilityImages,
      courtsAmount: courtsAmount ?? this.courtsAmount,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      detailAddress: detailAddress ?? this.detailAddress,
      province: province ?? this.province,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      totalRating: totalRating ?? this.totalRating,
      state: state ?? this.state,
      registeredAt: registeredAt ?? this.registeredAt,
      managerInfo: managerInfo ?? this.managerInfo,
      activeAt: activeAt ?? this.activeAt,
      userName: userName ?? this.userName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'facilityName': facilityName,
      'facebookUrl': facebookUrl,
      'description': description,
      'policy': policy,
      'userId': userId,
      'photos': facilityImages.map((img) => img.toMap()).toList(),
      'courtsAmount': courtsAmount,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'detailAddress': detailAddress,
      'province': province,
      'location': {
        'type': 'Point',
        'coordinates': [lon, lat],
      },
      'ratingAvg': ratingAvg,
      'totalRatings': totalRating,
      'state': state,
      'registeredAt': registeredAt.toUtc().toIso8601String(),
      'managerInfo': managerInfo.toMap(),
      'activeAt': activeAt?.toMap(),
      'userName': userName,
      'userImageUrl': userImageUrl,
    };
  }

  factory Facility.fromMap(Map<String, dynamic> map) {
    final coordinates = map['location']?['coordinates'] ?? [0.0, 0.0];
    return Facility(
      id: map['id'] ?? '',
      facilityName: map['facilityName'] ?? '',
      facebookUrl: map['facebookUrl'] ?? '',
      description: map['description'] ?? '',
      policy: map['policy'] ?? '',
      userId: map['userId'] ?? '',
      facilityImages: List<ImageCustom>.from(
        (map['photos'] ?? []).map((img) => ImageCustom.fromMap(img)),
      ),
      courtsAmount: map['courtsAmount'] ?? 0,
      minPrice: map['minPrice'] ?? 0,
      maxPrice: map['maxPrice'] ?? 0,
      detailAddress: map['detailAddress'] ?? '',
      province: map['province'] ?? '',
      lon: (coordinates[0] ?? 0.0).toDouble(),
      lat: (coordinates[1] ?? 0.0).toDouble(),
      ratingAvg: map['ratingAvg']?.toDouble() ?? 0.0,
      totalRating: map['totalRatings'] ?? 0,
      state: map['state'] ?? '',
      registeredAt:
          DateTime.tryParse(map['registeredAt'] ?? '') ?? DateTime.now(),
      managerInfo: ManagerInfo.fromMap(map['managerInfo'] ?? {}),
      activeAt:
          map['activeAt'] != null ? Active.fromMap(map['activeAt']) : null,
      userName: map['userName'] ?? '',
      userImageUrl: map['userImageUrl'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Facility.fromJson(String source) =>
      Facility.fromMap(json.decode(source));

  bool hasDay(String day) {
    return activeAt?.schedule.containsKey(day.toLowerCase()) ?? false;
  }
}
