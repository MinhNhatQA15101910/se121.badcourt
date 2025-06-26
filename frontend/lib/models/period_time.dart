class HourMinute {
  final String hourFrom;
  final String hourTo;

  HourMinute({
    required this.hourFrom,
    required this.hourTo,
  });

  factory HourMinute.fromMap(Map<String, dynamic> map) {
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

    return HourMinute(
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

  HourMinute copyWith({
    String? hourFrom,
    String? hourTo,
  }) {
    return HourMinute(
      hourFrom: hourFrom ?? this.hourFrom,
      hourTo: hourTo ?? this.hourTo,
    );
  }

  // Helper method to convert PeriodTime to DateTime objects for a specific date
  DateTime getStartDateTime(DateTime baseDate) {
    final parts = hourFrom.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
    return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
  }

  DateTime getEndDateTime(DateTime baseDate) {
    final parts = hourTo.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
    return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
  }
}
