class BookingTime {
  final int id;
  final DateTime startDate;
  final DateTime endDate; 
  final int status;

  BookingTime({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory BookingTime.fromJson(Map<String, dynamic> json) {
    return BookingTime(
      id: json['id'] as int,
      startDate: DateTime.parse(json['startDate']).toLocal(),
      endDate: DateTime.parse(json['endDate']).toLocal(),
      status: json['status'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toUtc().toIso8601String(),
      'endDate': endDate.toUtc().toIso8601String(),
      'status': status,
    };
  }
}
