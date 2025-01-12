abstract class CoOrganizerEvent {}

class CoOrganizerSubmitted extends CoOrganizerEvent {
  final int eventId;
  final String email;
  final String currentUserId;

  CoOrganizerSubmitted(this.eventId, this.email, this.currentUserId);
}
