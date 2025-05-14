class PeriodTime {
  final String hourFrom;
  final String hourTo;

  PeriodTime({
    required this.hourFrom,
    required this.hourTo,
  });

  factory PeriodTime.fromMap(Map<String, dynamic> map) {
    // Kiểm tra dữ liệu đầu vào hợp lệ
    if (map['hourFrom'] == null || map['hourTo'] == null) {
      throw ArgumentError('hourFrom and hourTo are required fields.');
    }

    String formatTime(String time) {
      List<String> parts = time.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
      return time;
    }

    return PeriodTime(
      hourFrom: formatTime(map['hourFrom'].toString()),
      hourTo: formatTime(map['hourTo'].toString()),
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
    String? hourFrom,
    String? hourTo,
  }) {
    return PeriodTime(
      hourFrom: hourFrom ?? this.hourFrom,
      hourTo: hourTo ?? this.hourTo,
    );
  }
}
