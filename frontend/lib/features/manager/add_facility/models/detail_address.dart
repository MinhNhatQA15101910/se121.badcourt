class DetailAddress {
  final String display;
  final String name;
  final String hsNum;
  final String street;
  final String address;
  final int cityId;
  final String city;
  final int districtId;
  final String district;
  final int wardId;
  final String ward;
  final double lat;
  final double lng;

  DetailAddress({
    required this.display,
    required this.name,
    required this.hsNum,
    required this.street,
    required this.address,
    required this.cityId,
    required this.city,
    required this.districtId,
    required this.district,
    required this.wardId,
    required this.ward,
    required this.lat,
    required this.lng,
  });

  factory DetailAddress.fromJson(Map<String, dynamic> json) {
    return DetailAddress(
      display: json['display'] ?? '',
      name: json['name'] ?? '',
      hsNum: json['hs_num'] ?? '',
      street: json['street'] ?? '',
      address: json['address'] ?? '',
      cityId: json['city_id'] ?? 0,
      city: json['city'] ?? '',
      districtId: json['district_id'] ?? 0,
      district: json['district'] ?? '',
      wardId: json['ward_id'] ?? 0,
      ward: json['ward'] ?? '',
      lat: json['lat'] ?? 0.0,
      lng: json['lng'] ?? 0.0,
    );
  }
}
