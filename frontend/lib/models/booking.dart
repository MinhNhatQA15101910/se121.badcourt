class BookingTime {
  int id;
  DateTime startDate;
  DateTime endDate;
  int status;

  BookingTime({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  // Convert a Booking into a Map. The keys must correspond to the names of the
  // fields in the database.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
    };
  }

  // A factory constructor to create a Booking from JSON.
  factory BookingTime.fromJson(Map<String, dynamic> json) {
    return BookingTime(
      id: json['id'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: json['status'],
    );
  }
}
