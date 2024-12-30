part of 'event_management_bloc.dart';

@immutable
abstract class EventManagementEvent {}

class SubmitEvent extends EventManagementEvent {
  final String eventName;
  final String date;
  final String time;
  final String location;
  final String budget;
  final String organizedBy;

  SubmitEvent({
    required this.eventName,
    required this.date,
    required this.time,
    required this.location,
    required this.budget,
    required this.organizedBy,
  });
}

