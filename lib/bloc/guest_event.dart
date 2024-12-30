part of 'guest_bloc.dart';

@immutable
sealed class GuestEvent {}

class AddGuest extends GuestEvent {
  final String eventName;
  final String GuestName;
  final String GuestDesignation;
  final int GuestNumber;

  AddGuest({
    required this.eventName,
    required this.GuestName,
    required this.GuestDesignation,
    required this.GuestNumber,
  });
}
