import 'dart:convert';
import 'package:frontend/models/time_period.dart';
import 'package:frontend/models/rating.dart';

class Order {
  final String id;
  final String userId;
  final String username;
  final String userImageUrl;
  final String facilityName;
  final String courtName;
  final String address;
  final double price;
  final DateTime createdAt;
  final String imageUrl;
  final TimePeriod timePeriod;
  final String state;
  final Rating? rating;
  final String facilityOwnerId;
  final String facilityOwnerUsername;
  final String facilityOwnerImageUrl;

  const Order({
    required this.id,
    required this.userId,
    required this.username,
    required this.userImageUrl,
    required this.facilityName,
    required this.courtName,
    required this.address,
    required this.price,
    required this.createdAt,
    required this.imageUrl,
    required this.timePeriod,
    required this.state,
    required this.facilityOwnerId,
    required this.facilityOwnerUsername,
    required this.facilityOwnerImageUrl,
    this.rating,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'username': username,
        'userImageUrl': userImageUrl,
        'facilityName': facilityName,
        'courtName': courtName,
        'address': address,
        'price': price,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'imageUrl': imageUrl,
        'dateTimePeriod': timePeriod.toMap(),
        'state': state,
        'rating': rating?.toMap(),
        'facilityOwnerId': facilityOwnerId,
        'facilityOwnerUsername': facilityOwnerUsername,
        'facilityOwnerImageUrl': facilityOwnerImageUrl,
      };

  factory Order.fromMap(Map<String, dynamic> map) {
    DateTime _parseDate(String? raw) {
      if (raw == null || raw.isEmpty) return DateTime.now();
      try {
        return DateTime.parse(raw).toLocal();
      } catch (_) {
        return DateTime.now();
      }
    }

    return Order(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      userImageUrl: map['userImageUrl'] ?? '',
      facilityName: map['facilityName'] ?? '',
      courtName: map['courtName'] ?? '',
      address: map['address'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      createdAt: _parseDate(map['createdAt']),
      imageUrl: map['imageUrl'] ?? '',
      timePeriod: TimePeriod.fromMap(map['dateTimePeriod'] ?? {}),
      state: map['state'] ?? 'None',
      rating: map['rating'] != null ? Rating.fromMap(map['rating']) : null,
      facilityOwnerId: map['facilityOwnerId'] ?? '',
      facilityOwnerUsername: map['facilityOwnerUsername'] ?? '',
      facilityOwnerImageUrl: map['facilityOwnerImageUrl'] ?? '',
    );
  }

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'Order(id: $id, userId: $userId, username: $username, '
      'state: $state, rating: $rating)';
}
