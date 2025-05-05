import 'dart:convert';

import 'package:frontend/models/image_custom.dart';
import 'package:frontend/models/order_period.dart';

class Order {
  final String id;
  final String facilityName;
  final String address;
  final double price;
  final DateTime createdAt;
  final ImageCustom image;
  final OrderPeriod timePeriod;

  const Order({
    required this.id,
    required this.facilityName,
    required this.address,
    required this.price,
    required this.createdAt,
    required this.image,
    required this.timePeriod,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'facilityName': facilityName,
      'address': address,
      'price': price,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'image': image.toMap(),
      'timePeriod': timePeriod.toMap(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      facilityName: map['facilityName'] ?? '',
      address: map['address'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt']?.toInt() ?? 0,
      ),
      image: ImageCustom.fromMap(map['image'] ?? {}),
      timePeriod: OrderPeriod.fromMap(map['timePeriod']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));
}
