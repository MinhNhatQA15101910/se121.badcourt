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
