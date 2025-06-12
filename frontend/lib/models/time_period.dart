class TimePeriod {
  final DateTime hourFrom;
  final DateTime hourTo;

  TimePeriod({
    required this.hourFrom,
    required this.hourTo,
  });

  Map<String, dynamic> toMap() {
    return {
      'hourFrom': hourFrom.toUtc().toIso8601String(),
      'hourTo': hourTo.toUtc().toIso8601String(),
    };
  }

  factory TimePeriod.fromMap(Map<String, dynamic> map) {
    return TimePeriod(
      hourFrom: DateTime.parse(map['hourFrom'] ?? DateTime.now().toUtc().toIso8601String()),
      hourTo: DateTime.parse(map['hourTo'] ?? DateTime.now().toUtc().toIso8601String()),
    );
  }
}
