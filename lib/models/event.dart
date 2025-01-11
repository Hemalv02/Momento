class Event {
  final int id;
  final DateTime createdAt;
  final String eventName;
  final String organizedBy;
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final String createdBy;

  Event({
    required this.id,
    required this.createdAt,
    required this.eventName,
    required this.organizedBy,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.createdBy,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      eventName: json['event_name'],
      organizedBy: json['organized_by'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      description: json['description'],
      createdBy: json['created_by'],
    );
  }
}
