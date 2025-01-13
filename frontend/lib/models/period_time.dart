class PeriodTime {
  final int hourFrom;
  final int hourTo;

  PeriodTime({
    required this.hourFrom,
    required this.hourTo,
  });

  factory PeriodTime.fromMap(Map<String, dynamic> map) {
    // Kiểm tra dữ liệu đầu vào hợp lệ
    if (map['hourFrom'] == null || map['hourTo'] == null) {
      throw ArgumentError('hourFrom and hourTo are required fields.');
    }

    return PeriodTime(
      hourFrom: map['hourFrom'],
      hourTo: map['hourTo'],
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
