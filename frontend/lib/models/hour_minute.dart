class HourMinute {
  final String hourFrom;
  final String hourTo;

  const HourMinute({
    required this.hourFrom,
    required this.hourTo,
  });

  /// Convert map coming **from server** (UTC) → local (UTC+7)
  factory HourMinute.fromMap(Map<String, dynamic> map) {
    if (map['hourFrom'] == null || map['hourTo'] == null) {
      throw ArgumentError('hourFrom and hourTo are required fields.');
    }

    String _utcToLocal(String time) {
      // Accepts "HH:mm:ss" or "HH:mm"
      final parts = time.split(':').map(int.parse).toList();
      final hour = parts[0];
      final minute = parts.length > 1 ? parts[1] : 0;
      final second = parts.length > 2 ? parts[2] : 0;

      final utcTime = DateTime.utc(2000, 1, 1, hour, minute, second);
      final localTime = utcTime.add(const Duration(hours: 7)); // UTC+7
      return _formatHHmm(localTime);
    }

    return HourMinute(
      hourFrom: _utcToLocal(map['hourFrom'].toString()),
      hourTo: _utcToLocal(map['hourTo'].toString()),
    );
  }

  /// Convert back to Map (still as local HH:mm strings)
  Map<String, dynamic> toMap() => {
        'hourFrom': hourFrom,
        'hourTo': hourTo,
      };

  @override
  String toString() => 'HourMinute(hourFrom: $hourFrom, hourTo: $hourTo)';

  HourMinute copyWith({String? hourFrom, String? hourTo}) => HourMinute(
        hourFrom: hourFrom ?? this.hourFrom,
        hourTo: hourTo ?? this.hourTo,
      );

  // ---------- Helpers for business logic ----------

  /// Create DateTime at [baseDate] with [hourFrom]
  DateTime getStartDateTime(DateTime baseDate) {
    final parts = hourFrom.split(':').map(int.parse).toList();
    return DateTime(baseDate.year, baseDate.month, baseDate.day, parts[0],
        parts.length > 1 ? parts[1] : 0);
  }

  /// Create DateTime at [baseDate] with [hourTo]
  DateTime getEndDateTime(DateTime baseDate) {
    final parts = hourTo.split(':').map(int.parse).toList();
    return DateTime(baseDate.year, baseDate.month, baseDate.day, parts[0],
        parts.length > 1 ? parts[1] : 0);
  }

  // ---------- Private util ----------

  static String _formatHHmm(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
