abstract class CreateGuestEvent {}

class CreateGuestSubmitted extends CreateGuestEvent {
  final String name;
  final String email;
  final int eventId;

  CreateGuestSubmitted(this.name, this.email, this.eventId);
}
