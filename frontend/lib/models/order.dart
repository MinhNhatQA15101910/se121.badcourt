import 'dart:convert';
import 'package:frontend/models/image_custom.dart';
import 'package:frontend/models/time_period.dart';

class Order {
  final String id;
  final String facilityName;
  final String address;
  final double price;
  final DateTime createdAt;
  final ImageCustom image;
  final TimePeriod timePeriod;
  final String state;

  const Order({
    required this.id,
    required this.facilityName,
    required this.address,
    required this.price,
    required this.createdAt,
    required this.image,
    required this.timePeriod,
    this.state = 'None',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'facilityName': facilityName,
      'address': address,
      'price': price,
      'createdAt': createdAt.toIso8601String(),
      'image': image.toMap(),
      'dateTimePeriod': timePeriod.toMap(),
      'state': state,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      facilityName: map['facilityName'] ?? '',
      address: map['address'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
      image: ImageCustom.fromMap(map['image'] ?? {}),
      timePeriod: TimePeriod.fromMap(map['dateTimePeriod'] ?? {}),
      state: map['state'] ?? 'None',
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));
}
