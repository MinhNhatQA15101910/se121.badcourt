import 'package:frontend/models/period_time.dart';

class Active {
  final Map<String, PeriodTime> schedule;

  Active({required this.schedule});

  factory Active.fromMap(Map<String, dynamic> map) {
    final Map<String, PeriodTime> schedule = {};

    map.forEach((key, value) {
      if (value != null && value is Map<String, dynamic>) {
        schedule[key] = PeriodTime.fromMap(value);
      }
    });

    return Active(schedule: schedule);
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {};
    schedule.forEach((key, value) {
      map[key] = value.toMap();
    });
    return map;
  }
}
