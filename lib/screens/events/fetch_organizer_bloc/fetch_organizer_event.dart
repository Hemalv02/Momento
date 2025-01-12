abstract class FetchCoorganizerEvent {}

class FetchCoorganizerByEventId extends FetchCoorganizerEvent {
  final int eventId;
  FetchCoorganizerByEventId(this.eventId);
}

class RefreshCoorganizersByEventId extends FetchCoorganizerEvent {
  final int eventId;
  RefreshCoorganizersByEventId(this.eventId);
}
