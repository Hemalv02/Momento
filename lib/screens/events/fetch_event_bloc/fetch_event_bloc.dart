import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/screens/events/fetch_event_bloc/event_api.dart';
import 'package:momento/screens/events/fetch_event_bloc/fetch_event_event.dart';
import 'package:momento/screens/events/fetch_event_bloc/fetch_event_state.dart';

class FetchEventBloc extends Bloc<FetchEventEvent, FetchEventState> {
  final EventApiService apiService;

  FetchEventBloc({required this.apiService}) : super(FetchEventInitial()) {
    on<FetchEventsByCreator>(_onFetchEventsByCreator);
    on<RefreshEventsByCreator>(_onRefreshEventsByCreator);
  }

  Future<void> _onFetchEventsByCreator(
      FetchEventsByCreator event, Emitter<FetchEventState> emit) async {
    emit(FetchEventLoading());
    try {
      final events = await apiService.fetchEvents(event.createdBy);
      emit(FetchEventLoaded(events));
    } catch (e) {
      if (e is EventApiException) {
        emit(FetchEventError(e.message));
      } else {
        emit(FetchEventError("An unexpected error occurred"));
      }
    }
  }

  Future<void> _onRefreshEventsByCreator(
      RefreshEventsByCreator event, Emitter<FetchEventState> emit) async {
    // Get current events if available
    final currentEvents =
        state is FetchEventLoaded ? (state as FetchEventLoaded).events : null;

    emit(FetchEventLoading(previousEvents: currentEvents));

    try {
      final events = await apiService.fetchEvents(event.createdBy);
      emit(FetchEventLoaded(events));
    } catch (e) {
      if (e is EventApiException) {
        emit(FetchEventError(e.message));
      } else {
        emit(FetchEventError("An unexpected error occurred"));
      }
    }
  }
}
