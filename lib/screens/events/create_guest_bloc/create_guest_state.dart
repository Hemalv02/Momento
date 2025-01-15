abstract class CreateGuestState {}

class CreateGuestInitial extends CreateGuestState {}

class CreateGuestLoading extends CreateGuestState {}

class CreateGuestSuccess extends CreateGuestState {
  final String message;

  CreateGuestSuccess(this.message);
}

class CreateGuestFailure extends CreateGuestState {
  final String error;

  CreateGuestFailure(this.error);
}
