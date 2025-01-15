import 'package:momento/screens/events/fetch_guest_bloc/guest_api.dart';

abstract class FetchGuestState {}

class FetchGuestInitial extends FetchGuestState {}

class FetchGuestLoading extends FetchGuestState {
  final List<Guest>? previousGuests;

  FetchGuestLoading({this.previousGuests});
}

class FetchGuestLoaded extends FetchGuestState {
  final List<Guest> guests;

  FetchGuestLoaded(this.guests);
}

class FetchGuestError extends FetchGuestState {
  final String message;
  final List<Guest>? previousGuests;

  FetchGuestError(this.message, {this.previousGuests});
}
