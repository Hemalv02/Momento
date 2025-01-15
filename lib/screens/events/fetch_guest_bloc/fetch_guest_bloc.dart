import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/screens/events/fetch_guest_bloc/fetch_guest_event.dart';
import 'package:momento/screens/events/fetch_guest_bloc/fetch_guest_state.dart';
import 'package:momento/screens/events/fetch_guest_bloc/guest_api.dart';

class FetchGuestBloc extends Bloc<FetchGuestEvent, FetchGuestState> {
  final GuestApiService apiService;

  FetchGuestBloc({required this.apiService}) : super(FetchGuestInitial()) {
    on<FetchGuestByEventId>(_onFetchGuestsByEventId);
    on<RefreshGuestsByEventId>(_onRefreshGuestsByEventId);
  }

  Future<void> _onFetchGuestsByEventId(
      FetchGuestByEventId event, Emitter<FetchGuestState> emit) async {
    emit(FetchGuestLoading());
    try {
      final guests = await apiService.fetchEvents(event.eventId);
      emit(FetchGuestLoaded(guests));
    } catch (e) {
      if (e is GuestApiException) {
        emit(FetchGuestError(e.message));
      } else {
        emit(FetchGuestError("An unexpected error occurred"));
      }
    }
  }

  Future<void> _onRefreshGuestsByEventId(
      RefreshGuestsByEventId event, Emitter<FetchGuestState> emit) async {
    // Keep the current guests if available
    final currentGuests =
        state is FetchGuestLoaded ? (state as FetchGuestLoaded).guests : null;

    emit(FetchGuestLoading(previousGuests: currentGuests));

    try {
      final guests = await apiService.fetchEvents(event.eventId);
      emit(FetchGuestLoaded(guests));
    } catch (e) {
      if (e is GuestApiException) {
        emit(FetchGuestError(e.message, previousGuests: currentGuests));
      } else {
        emit(FetchGuestError("An unexpected error occurred",
            previousGuests: currentGuests));
      }
    }
  }
}
