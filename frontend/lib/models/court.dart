import 'dart:convert';

class Court {
  final String id;
  final String courtName; // Tên sân
  final String description; // Mô tả sân
  final int pricePerHour; // Giá mỗi giờ
  final String state; // Trạng thái sân
  final int createdAt; // Thời gian tạo

  Court({
    required this.id,
    required this.courtName,
    required this.description,
    required this.pricePerHour,
    required this.state,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'courtName': courtName,
      'description': description,
      'pricePerHour': pricePerHour,
      'state': state,
      'createdAt': createdAt,
    };
  }

  factory Court.fromMap(Map<String, dynamic> map) {
    return Court(
      id: map['_id'] ?? '',
      courtName: map['courtName'] ?? '',
      description: map['description'] ?? '',
      pricePerHour: map['pricePerHour'] ?? 0,
      state: map['state'] ?? 'Inactive',
      createdAt: map['createdAt'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Court.fromJson(String source) => Court.fromMap(json.decode(source));

  Court copyWith({
    String? id,
    String? courtName,
    String? description,
    int? pricePerHour,
    String? state,
    int? createdAt,
  }) {
    return Court(
      id: id ?? this.id,
      courtName: courtName ?? this.courtName,
      description: description ?? this.description,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
