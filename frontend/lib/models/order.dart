import 'dart:convert';

import 'package:frontend/models/order_period.dart';

class Order {
  final String id;
  final String userId;
  final String courtId;
  final DateTime orderedAt;
  final String facilityName;
  final String address;
  final String imageUrl;
  final double price;
  final OrderPeriod period;

  const Order({
    required this.id,
    required this.userId,
    required this.courtId,
    required this.orderedAt,
    required this.facilityName,
    required this.address,
    required this.imageUrl,
    required this.price,
    required this.period,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'court_id': courtId,
      'ordered_at': orderedAt.millisecondsSinceEpoch,
      'facility_name': facilityName,
      'address': address,
      'image_url': imageUrl,
      'price': price,
      'period': period.toMap(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['_id'] ?? '',
      userId: map['user_id'] ?? '',
      courtId: map['court_id'] ?? '',
      orderedAt: DateTime.fromMillisecondsSinceEpoch(
        map['ordered_at']?.toInt() ?? 0,
      ),
      facilityName: map['facility_name'] ?? '',
      address: map['address'] ?? '',
      imageUrl: map['image_url'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      period: OrderPeriod.fromMap(map['period']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));
}
