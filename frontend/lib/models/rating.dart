import 'dart:convert';

class Rating {
  final String id;
  final String userId;
  final String facilityId;
  final int stars;
  final String feedback;
  final DateTime createdAt;

  const Rating({
    required this.id,
    required this.userId,
    required this.facilityId,
    required this.stars,
    required this.feedback,
    required this.createdAt,
  });

  factory Rating.fromMap(Map<String, dynamic> map) {
    DateTime _parse(String? raw) {
      if (raw == null || raw.isEmpty) return DateTime.now();
      try {
        return DateTime.parse(raw).toLocal();
      } catch (_) {
        return DateTime.now();
      }
    }

    return Rating(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      facilityId: map['facilityId'] ?? '',
      stars: (map['stars'] ?? 0).toInt(),
      feedback: map['feedback'] ?? '',
      createdAt: _parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'facilityId': facilityId,
        'stars': stars,
        'feedback': feedback,
        'createdAt': createdAt.toUtc().toIso8601String(),
      };

  factory Rating.fromJson(String source) =>
      Rating.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'Rating(id: $id, userId: $userId, facilityId: $facilityId, '
      'stars: $stars, feedback: $feedback, createdAt: $createdAt)';
}
