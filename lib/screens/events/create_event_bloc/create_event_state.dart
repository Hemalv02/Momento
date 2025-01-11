abstract class CreateEventState {}

class CreateEventInitial extends CreateEventState {}

class CreateEventLoading extends CreateEventState {}

class CreateEventSuccess extends CreateEventState {
  final String message;

  CreateEventSuccess(this.message);
}

class CreateEventFailure extends CreateEventState {
  final String error;

  CreateEventFailure(this.error);
}
