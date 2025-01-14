class Coordinates {
  final double longitude;
  final double latitude;

  Coordinates({
    required this.longitude,
    required this.latitude,
  });

  factory Coordinates.fromList(List<dynamic> list) {
    return Coordinates(
      longitude: list[0].toDouble(),
      latitude: list[1].toDouble(),
    );
  }

  List<double> toList() {
    return [longitude, latitude];
  }
}
