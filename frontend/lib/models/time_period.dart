class TimePeriod {
  final DateTime hourFrom;
  final DateTime hourTo;

  const TimePeriod({
    required this.hourFrom,
    required this.hourTo,
  });

  factory TimePeriod.fromMap(Map<String, dynamic> map) {
    return TimePeriod(
      hourFrom:
          DateTime.tryParse(map['hourFrom'] ?? '')?.toLocal() ?? DateTime.now(),
      hourTo:
          DateTime.tryParse(map['hourTo'] ?? '')?.toLocal() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'hourFrom': hourFrom.toUtc().toIso8601String(),
        'hourTo': hourTo.toUtc().toIso8601String(),
      };
  String get hourFromStr =>
      '${hourFrom.hour.toString().padLeft(2, '0')}:${hourFrom.minute.toString().padLeft(2, '0')}';
  String get hourToStr =>
      '${hourTo.hour.toString().padLeft(2, '0')}:${hourTo.minute.toString().padLeft(2, '0')}';

}
