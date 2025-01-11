import 'package:frontend/models/coordinates.dart';

class Location {
  final String type;
  final Coordinates coordinates;

  Location({
    required this.type,
    required this.coordinates,
  });

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      type: map['type'] ?? 'Point',
      coordinates: Coordinates.fromList(map['coordinates'] ?? [0.0, 0.0]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'coordinates': coordinates.toList(),
    };
  }
}