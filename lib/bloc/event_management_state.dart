part of 'event_management_bloc.dart';

@immutable
abstract class EventManagementState {}

class EventInitial extends EventManagementState {}

class EventSubmitting extends EventManagementState {}

class EventSubmissionSuccess extends EventManagementState {}

class EventSubmissionFailure extends EventManagementState {
  final String error;
  EventSubmissionFailure(this.error);
}