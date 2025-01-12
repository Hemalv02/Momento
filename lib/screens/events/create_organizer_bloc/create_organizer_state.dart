abstract class CoOrganizerState {}

class CoOrganizerInitial extends CoOrganizerState {}

class CoOrganizerLoading extends CoOrganizerState {}

class CoOrganizerSuccess extends CoOrganizerState {
  final String message;

  CoOrganizerSuccess(this.message);
}

class CoOrganizerFailure extends CoOrganizerState {
  final String error;

  CoOrganizerFailure(this.error);
}
