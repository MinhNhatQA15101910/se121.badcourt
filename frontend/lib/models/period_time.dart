class PeriodTime {
  final int hourFrom;
  final int hourTo;

  PeriodTime({required this.hourFrom, required this.hourTo});

  factory PeriodTime.fromMap(Map<String, dynamic> map) {
    return PeriodTime(
      hourFrom: map['hour_from'] ?? 0,
      hourTo: map['hour_to'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hour_from': hourFrom,
      'hour_to': hourTo,
    };
  }
}
