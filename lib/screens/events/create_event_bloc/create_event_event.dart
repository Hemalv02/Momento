abstract class CreateEventEvent {}

class CreateEventSubmitted extends CreateEventEvent {
  final String name;
  final String organizedBy;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final String createdBy;

  CreateEventSubmitted(this.name, this.organizedBy, this.location,
      this.startDate, this.endDate, this.description, this.createdBy);
}
