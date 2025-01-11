import 'dart:convert';

import 'package:frontend/models/active.dart';
import 'package:frontend/models/location.dart';
import 'package:frontend/models/manager_info.dart';

class Facility {
  final String id;
  final String userId;
  final String name;
  final String facebookUrl;
  final int courtsAmount;
  final String detailAddress;
  final String province;
  final Location location;
  final double ratingAvg;
  final int totalRating;
  final Active activeAt;
  final int registeredAt;
  final List<FacilityImage> facilityImages; // Danh sách hình ảnh cơ sở
  final String description;
  final String policy;
  final int maxPrice;
  final int minPrice;
  final ManagerInfo managerInfo;
  final bool isApproved; // Trạng thái phê duyệt
  final int approvedAt; // Thời gian phê duyệt
  final double distance; // Khoảng cách

  Facility({
    required this.id,
    required this.userId,
    required this.name,
    required this.facebookUrl,
    required this.courtsAmount,
    required this.detailAddress,
    required this.province,
    required this.location,
    required this.ratingAvg,
    required this.totalRating,
    required this.activeAt,
    required this.registeredAt,
    required this.facilityImages,
    required this.description,
    required this.policy,
    required this.maxPrice,
    required this.minPrice,
    required this.managerInfo,
    required this.isApproved,
    required this.approvedAt,
    required this.distance,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'userId': userId,
      'name': name,
      'facebookUrl': facebookUrl,
      'courtsAmount': courtsAmount,
      'detailAddress': detailAddress,
      'province': province,
      'location': location.toMap(),
      'ratingAvg': ratingAvg,
      'totalRating': totalRating,
      'activeAt': activeAt.toMap(),
      'registeredAt': registeredAt,
      'facilityImages': facilityImages.map((img) => img.toMap()).toList(),
      'description': description,
      'policy': policy,
      'maxPrice': maxPrice,
      'minPrice': minPrice,
      'managerInfo': managerInfo.toMap(),
      'isApproved': isApproved,
      'approvedAt': approvedAt,
      'distance': distance,
    };
  }

  factory Facility.fromMap(Map<String, dynamic> map) {
    return Facility(
      id: map['_id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      facebookUrl: map['facebookUrl'] ?? '',
      courtsAmount: map['courtsAmount'] ?? 0,
      detailAddress: map['detailAddress'] ?? '',
      province: map['province'] ?? '',
      location: Location.fromMap(map['location'] ?? {}),
      ratingAvg: map['ratingAvg']?.toDouble() ?? 0.0,
      totalRating: map['totalRating'] ?? 0,
      activeAt: Active.fromMap(map['activeAt'] ?? {}),
      registeredAt: map['registeredAt'] ?? 0,
      facilityImages: List<FacilityImage>.from(
        (map['facilityImages'] ?? []).map((img) => FacilityImage.fromMap(img)),
      ),
      description: map['description'] ?? '',
      policy: map['policy'] ?? '',
      maxPrice: map['maxPrice'] ?? 0,
      minPrice: map['minPrice'] ?? 0,
      managerInfo: ManagerInfo.fromMap(map['managerInfo'] ?? {}),
      isApproved: map['isApproved'] ?? false,
      approvedAt: map['approvedAt'] ?? 0,
      distance: map['distance']?.toDouble() ?? 0.0,
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
    int? courtsAmount,
    String? detailAddress,
    String? province,
    Location? location,
    double? ratingAvg,
    int? totalRating,
    Active? activeAt,
    int? registeredAt,
    List<FacilityImage>? facilityImages,
    String? description,
    String? policy,
    int? maxPrice,
    int? minPrice,
    ManagerInfo? managerInfo,
    bool? isApproved,
    int? approvedAt,
    double? distance,
  }) {
    return Facility(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      courtsAmount: courtsAmount ?? this.courtsAmount,
      detailAddress: detailAddress ?? this.detailAddress,
      province: province ?? this.province,
      location: location ?? this.location,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      totalRating: totalRating ?? this.totalRating,
      activeAt: activeAt ?? this.activeAt,
      registeredAt: registeredAt ?? this.registeredAt,
      facilityImages: facilityImages ?? this.facilityImages,
      description: description ?? this.description,
      policy: policy ?? this.policy,
      maxPrice: maxPrice ?? this.maxPrice,
      minPrice: minPrice ?? this.minPrice,
      managerInfo: managerInfo ?? this.managerInfo,
      isApproved: isApproved ?? this.isApproved,
      approvedAt: approvedAt ?? this.approvedAt,
      distance: distance ?? this.distance,
    );
  }

  bool hasDay(String day) {
    return activeAt.schedule.containsKey(day.toLowerCase());
  }
}

class FacilityImage {
  final String url;
  final bool isMain;
  final String publicId;

  FacilityImage({
    required this.url,
    required this.isMain,
    required this.publicId,
  });

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'isMain': isMain,
      'publicId': publicId,
    };
  }

  factory FacilityImage.fromMap(Map<String, dynamic> map) {
    return FacilityImage(
      url: map['url'] ?? '',
      isMain: map['isMain'] ?? false,
      publicId: map['publicId'] ?? '',
    );
  }
}
