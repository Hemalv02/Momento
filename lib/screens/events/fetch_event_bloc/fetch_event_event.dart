abstract class FetchEventEvent {}

class FetchEventsByCreator extends FetchEventEvent {
  final String createdBy;
  FetchEventsByCreator(this.createdBy);
}
class FetchEventsByGuest extends FetchEventEvent {
  final String createdBy;
  FetchEventsByGuest(this.createdBy);
}

class RefreshEventsByCreator extends FetchEventEvent {
  final String createdBy;
  RefreshEventsByCreator(this.createdBy);
}
