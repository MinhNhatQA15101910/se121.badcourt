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
  final String activeAt;
  final int registeredAt;
  final List<String> imageUrls;

  const Facility({
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
      'active_at': activeAt,
      'registered_at': registeredAt,
      'image_urls': imageUrls
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
      activeAt: map['active_at'] ?? '',
      registeredAt: map['registered_at'] ?? 0,
      imageUrls: map['image_urls'] ?? [],
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
    String? activeAt,
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
