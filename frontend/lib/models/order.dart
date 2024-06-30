import 'dart:convert';

import 'package:frontend/models/order_period.dart';

class Order {
  final String id;
  final String userId;
  final String courtId;
  final int orderedAt;
  final double price;
  final OrderPeriod period;

  const Order({
    required this.id,
    required this.userId,
    required this.courtId,
    required this.orderedAt,
    required this.price,
    required this.period,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'court_id': courtId,
      'ordered_at': orderedAt,
      'price': price,
      'period': period.toMap(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['_id'] ?? '',
      userId: map['user_id'] ?? '',
      courtId: map['court_id'] ?? '',
      orderedAt: map['ordered_at']?.toInt() ?? 0,
      price: map['price']?.toDouble() ?? 0.0,
      period: OrderPeriod.fromMap(map['period']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));
}
