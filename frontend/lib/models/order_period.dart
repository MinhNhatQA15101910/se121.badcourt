class OrderPeriod {
  final DateTime hourFrom;
  final DateTime hourTo;

  OrderPeriod({
    required this.hourFrom,
    required this.hourTo,
  });

  Map<String, dynamic> toMap() {
    return {
      'hourFrom': hourFrom.millisecondsSinceEpoch,
      'hourTo': hourTo.millisecondsSinceEpoch,
    };
  }

  factory OrderPeriod.fromMap(Map<String, dynamic> map) {
    return OrderPeriod(
      hourFrom: DateTime.fromMillisecondsSinceEpoch(map['hourFrom'] ?? 0),
      hourTo: DateTime.fromMillisecondsSinceEpoch(map['hourTo'] ?? 0),
    );
  }
}
