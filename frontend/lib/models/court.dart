import 'dart:convert';

class Court {
  final String id;
  final String facilityId;
  final String name;
  final String description;
  final int pricePerHour;
  final List<OrderPeriod> orderPeriods; // New field for order periods

  Court({
    required this.id,
    required this.facilityId,
    required this.name,
    required this.description,
    required this.pricePerHour,
    required this.orderPeriods,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'facility_id': facilityId,
      'name': name,
      'description': description,
      'price_per_hour': pricePerHour,
      'order_periods': orderPeriods.map((period) => period.toMap()).toList(),
    };
  }

  factory Court.fromMap(Map<String, dynamic> map) {
    List<dynamic> orderPeriodsJson = map['order_periods'] ?? [];
    List<OrderPeriod> orderPeriods =
        orderPeriodsJson.map((period) => OrderPeriod.fromMap(period)).toList();

    return Court(
      id: map['_id'] ?? '',
      facilityId: map['facility_id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      pricePerHour: map['price_per_hour'] ?? 0,
      orderPeriods: orderPeriods,
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
    List<OrderPeriod>? orderPeriods,
  }) {
    return Court(
      id: id ?? this.id,
      facilityId: facilityId ?? this.facilityId,
      name: name ?? this.name,
      description: description ?? this.description,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      orderPeriods: orderPeriods ?? this.orderPeriods,
    );
  }

  List<OrderPeriod> getOrderPeriodsByDate(DateTime date) {
    return orderPeriods
        .where((period) =>
            period.hourFrom.year == date.year &&
            period.hourFrom.month == date.month &&
            period.hourFrom.day == date.day)
        .toList();
  }
}

class OrderPeriod {
  final String userId;
  final DateTime hourFrom;
  final DateTime hourTo;

  OrderPeriod({
    required this.userId,
    required this.hourFrom,
    required this.hourTo,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'hour_from': hourFrom.millisecondsSinceEpoch,
      'hour_to': hourTo.millisecondsSinceEpoch,
    };
  }

  factory OrderPeriod.fromMap(Map<String, dynamic> map) {
    return OrderPeriod(
      userId: map['user_id'] ?? '',
      hourFrom: DateTime.fromMillisecondsSinceEpoch(map['hour_from'] ?? 0),
      hourTo: DateTime.fromMillisecondsSinceEpoch(map['hour_to'] ?? 0),
    );
  }
}
