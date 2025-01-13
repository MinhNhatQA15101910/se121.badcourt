import 'dart:convert';

import 'package:frontend/models/active.dart';
import 'package:frontend/models/image_custom.dart';
import 'package:frontend/models/manager_info.dart';

import 'dart:convert';

import 'package:frontend/models/image_custom.dart';
import 'package:frontend/models/manager_info.dart';
import 'package:frontend/models/period_time.dart';

class Facility {
  final String id;
  final String facilityName;
  final String facebookUrl;
  final String description;
  final String policy;
  final String userId;
  final String userImageUrl;
  final String facilityImageUrl;
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
  final int createdAt;
  final ManagerInfo managerInfo;
  final Active activeAt; // Added Active field

  Facility({
    required this.id,
    required this.facilityName,
    required this.facebookUrl,
    required this.description,
    required this.policy,
    required this.userId,
    required this.userImageUrl,
    required this.facilityImageUrl,
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
    required this.createdAt,
    required this.managerInfo,
    required this.activeAt, // Include Active in the constructor
  });

  Facility copyWith({
    String? id,
    String? facilityName,
    String? facebookUrl,
    String? description,
    String? policy,
    String? userId,
    String? userImageUrl,
    String? facilityImageUrl,
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
    int? createdAt,
    ManagerInfo? managerInfo,
    Active? activeAt, // Add Active to copyWith
  }) {
    return Facility(
      id: id ?? this.id,
      facilityName: facilityName ?? this.facilityName,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      description: description ?? this.description,
      policy: policy ?? this.policy,
      userId: userId ?? this.userId,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      facilityImageUrl: facilityImageUrl ?? this.facilityImageUrl,
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
      createdAt: createdAt ?? this.createdAt,
      managerInfo: managerInfo ?? this.managerInfo,
      activeAt: activeAt ?? this.activeAt, // Include Active in copyWith
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'facilityName': facilityName,
      'facebookUrl': facebookUrl,
      'description': description,
      'policy': policy,
      'userId': userId,
      'userImageUrl': userImageUrl,
      'facilityImageUrl': facilityImageUrl,
      'facilityImages': facilityImages.map((img) => img.toMap()).toList(),
      'courtsAmount': courtsAmount,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'detailAddress': detailAddress,
      'province': province,
      'lat': lat,
      'lon': lon,
      'ratingAvg': ratingAvg,
      'totalRating': totalRating,
      'state': state,
      'createdAt': createdAt,
      'managerInfo': managerInfo.toMap(),
      'activeAt': activeAt.toMap(), // Include Active in toMap
    };
  }

  factory Facility.fromMap(Map<String, dynamic> map) {
    return Facility(
      id: map['_id'] ?? '',
      facilityName: map['facilityName'] ?? '',
      facebookUrl: map['facebookUrl'] ?? '',
      description: map['description'] ?? '',
      policy: map['policy'] ?? '',
      userId: map['userId'] ?? '',
      userImageUrl: map['userImageUrl'] ?? '',
      facilityImageUrl: map['facilityImageUrl'] ?? '',
      facilityImages: List<ImageCustom>.from(
        (map['facilityImages'] ?? []).map((img) => ImageCustom.fromMap(img)),
      ),
      courtsAmount: map['courtsAmount'] ?? 0,
      minPrice: map['minPrice'] ?? 0,
      maxPrice: map['maxPrice'] ?? 0,
      detailAddress: map['detailAddress'] ?? '',
      province: map['province'] ?? '',
      lat: map['lat']?.toDouble() ?? 0.0,
      lon: map['lon']?.toDouble() ?? 0.0,
      ratingAvg: map['ratingAvg']?.toDouble() ?? 0.0,
      totalRating: map['totalRating'] ?? 0,
      state: map['state'] ?? '',
      createdAt: map['createdAt'] ?? 0,
      managerInfo: ManagerInfo.fromMap(map['managerInfo'] ?? {}),
      activeAt:
          Active.fromMap(map['activeAt'] ?? {}), // Include Active in fromMap
    );
  }

  String toJson() => json.encode(toMap());

  factory Facility.fromJson(String source) =>
      Facility.fromMap(json.decode(source));
}
