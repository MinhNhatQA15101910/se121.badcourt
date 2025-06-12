import 'dart:convert';

import 'package:frontend/models/time_period.dart';

class Court {
  final String id;
  final String courtName; // Tên sân
  final String description; // Mô tả sân
  final int pricePerHour; // Giá mỗi giờ
  final String state; // Trạng thái sân
  final String createdAt; // Thời gian tạo
  final List<TimePeriod> orderPeriods; // Danh sách các khoảng thời gian đặt sân
  final List<TimePeriod> inactivePeriods;

  Court({
    required this.id,
    required this.courtName,
    required this.description,
    required this.pricePerHour,
    required this.state,
    required this.createdAt,
    required this.orderPeriods,
    required this.inactivePeriods,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courtName': courtName,
      'description': description,
      'pricePerHour': pricePerHour,
      'state': state,
      'createdAt': createdAt,
      'orderPeriods': orderPeriods.map((period) => period.toMap()).toList(),
      'inactivePeriods':
          inactivePeriods.map((period) => period.toMap()).toList(),
    };
  }

  factory Court.fromMap(Map<String, dynamic> map) {
    return Court(
      id: map['id'] ?? '',
      courtName: map['courtName'] ?? '',
      description: map['description'] ?? '',
      pricePerHour: map['pricePerHour'] ?? 0,
      state: map['state'] ?? 'Inactive',
      createdAt: map['createdAt'] ?? 0,
      orderPeriods: List<TimePeriod>.from(
        (map['orderPeriods'] ?? []).map((period) => TimePeriod.fromMap(period)),
      ),
      inactivePeriods: List<TimePeriod>.from(
        (map['inactivePeriods'] ?? [])
            .map((period) => TimePeriod.fromMap(period)),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Court.fromJson(String source) => Court.fromMap(json.decode(source));

  Court copyWith(
      {String? id,
      String? courtName,
      String? description,
      int? pricePerHour,
      String? state,
      String? createdAt,
      List<TimePeriod>? orderPeriods,
      List<TimePeriod>? inactivePeriods}) {
    return Court(
      id: id ?? this.id,
      courtName: courtName ?? this.courtName,
      description: description ?? this.description,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      orderPeriods: orderPeriods ?? this.orderPeriods,
      inactivePeriods: inactivePeriods ?? this.inactivePeriods,
    );
  }

  List<TimePeriod> getTimePeriodsByDate(DateTime date) {
    return orderPeriods
        .where((period) =>
            period.hourFrom.year == date.year &&
            period.hourFrom.month == date.month &&
            period.hourFrom.day == date.day)
        .toList();
  }
}
