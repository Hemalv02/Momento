abstract class FetchEventEvent {}

class FetchEventsByCreator extends FetchEventEvent {
  final String createdBy;
  FetchEventsByCreator(this.createdBy);
}

class RefreshEventsByCreator extends FetchEventEvent {
  final String createdBy;
  RefreshEventsByCreator(this.createdBy);
}

