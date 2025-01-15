abstract class FetchGuestEvent {}

class FetchGuestByEventId extends FetchGuestEvent {
  final int eventId;
  FetchGuestByEventId(this.eventId);
}

class RefreshGuestsByEventId extends FetchGuestEvent {
  final int eventId;
  RefreshGuestsByEventId(this.eventId);
}
