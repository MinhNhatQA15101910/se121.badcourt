import 'dart:convert';

class Court {
  final String id;
  final String facilityId;
  final String name;
  final String description;
  final int pricePerHour;

  Court({
    required this.id,
    required this.facilityId,
    required this.name,
    required this.description,
    required this.pricePerHour,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'facility_id': facilityId,
      'name': name,
      'description': description,
      'price_per_hour': pricePerHour,
    };
  }

  factory Court.fromMap(Map<String, dynamic> map) {
    return Court(
      id: map['_id'] ?? '',
      facilityId: map['facility_id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      pricePerHour: map['price_per_hour'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Court.fromJson(String source) => Court.fromMap(json.decode(source));

  Court copyWith({
    String? id,
    String? facilityId,
    String? name,
    String? description,
    int? pricePerHour,
  }) {
    return Court(
      id: id ?? this.id,
      facilityId: facilityId ?? this.facilityId,
      name: name ?? this.name,
      description: description ?? this.description,
      pricePerHour: pricePerHour ?? this.pricePerHour,
    );
  }
}
