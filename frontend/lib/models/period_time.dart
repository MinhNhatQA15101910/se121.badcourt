class PeriodTime {
  final int hourFrom;
  final int hourTo;

  PeriodTime({
    required this.hourFrom,
    required this.hourTo,
  });

  factory PeriodTime.fromMap(Map<String, dynamic> map) {
    final dynamic fromRaw = map['hourFrom'];
    final dynamic toRaw = map['hourTo'];

    if (fromRaw == null || toRaw == null) {
      throw ArgumentError('hourFrom and hourTo are required fields.');
    }

    return PeriodTime(
      hourFrom: int.tryParse(fromRaw.toString()) ?? 0,
      hourTo: int.tryParse(toRaw.toString()) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hourFrom': hourFrom,
      'hourTo': hourTo,
    };
  }

  @override
  String toString() => 'PeriodTime(hourFrom: $hourFrom, hourTo: $hourTo)';

  PeriodTime copyWith({
    int? hourFrom,
    int? hourTo,
  }) {
    return PeriodTime(
      hourFrom: hourFrom ?? this.hourFrom,
      hourTo: hourTo ?? this.hourTo,
    );
  }
}
