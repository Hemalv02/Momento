import 'package:momento/screens/events/fetch_organizer_bloc/organizer_fetch_api.dart';

abstract class FetchCoorganizerState {}

class FetchCoorganizerInitial extends FetchCoorganizerState {}

class FetchCoorganizerLoading extends FetchCoorganizerState {
  final List<Coorganizer>? previousCoorganizers;

  FetchCoorganizerLoading({this.previousCoorganizers});
}

class FetchCoorganizerLoaded extends FetchCoorganizerState {
  final List<Coorganizer> coorganizers;

  FetchCoorganizerLoaded(this.coorganizers);
}

class FetchCoorganizerError extends FetchCoorganizerState {
  final String message;
  final List<Coorganizer>? previousCoorganizers;

  FetchCoorganizerError(this.message, {this.previousCoorganizers});
}
