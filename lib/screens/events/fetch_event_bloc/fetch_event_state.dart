import 'package:momento/screens/events/fetch_event_bloc/event_api.dart';

abstract class FetchEventState {}

class FetchEventInitial extends FetchEventState {}

class FetchEventLoading extends FetchEventState {
  final List<Event>? previousEvents;
  FetchEventLoading({this.previousEvents});
}

class FetchEventLoaded extends FetchEventState {
  final List<Event> events;
  FetchEventLoaded(this.events);
}

class FetchEventError extends FetchEventState {
  final String message;
  FetchEventError(this.message);
}
