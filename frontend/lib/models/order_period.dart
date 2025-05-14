class OrderPeriod {
  final DateTime hourFrom;
  final DateTime hourTo;

  OrderPeriod({
    required this.hourFrom,
    required this.hourTo,
  });

  Map<String, dynamic> toMap() {
    return {
      'hourFrom': hourFrom.toUtc().toIso8601String(),
      'hourTo': hourTo.toUtc().toIso8601String(),
    };
  }

  factory OrderPeriod.fromMap(Map<String, dynamic> map) {
    return OrderPeriod(
      hourFrom: DateTime.parse(map['hourFrom'] ?? DateTime.now().toUtc().toIso8601String()),
      hourTo: DateTime.parse(map['hourTo'] ?? DateTime.now().toUtc().toIso8601String()),
    );
  }
}
