import 'package:frontend/models/period_time.dart';

class Active {
  final Map<String, PeriodTime> schedule;

  Active({required this.schedule});

  factory Active.fromMap(Map<String, dynamic> map) {
    Map<String, PeriodTime> schedule = {};
    map.forEach((key, value) {
      if (key != '_id') {
        schedule[key] = PeriodTime.fromMap(value);
      }
    });
    return Active(schedule: schedule);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    schedule.forEach((key, value) {
      map[key] = value.toMap();
    });
    return map;
  }
}
