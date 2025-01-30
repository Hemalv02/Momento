import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/screens/events/fetch_event_bloc/event_api.dart';
import 'package:momento/screens/events/fetch_event_bloc/fetch_event_event.dart';
import 'package:momento/screens/events/fetch_event_bloc/fetch_event_state.dart';

class FetchEventBloc extends Bloc<FetchEventEvent, FetchEventState> {
  final EventApiService apiService;

  FetchEventBloc({required this.apiService}) : super(FetchEventInitial()) {
    on<FetchEventsByCreator>(_onFetchEventsByCreator);
    on<RefreshEventsByCreator>(_onRefreshEventsByCreator);
    on<FetchEventsByGuest>(_onFetchEventsByGuest);
    on<RefreshEventsByGuest>(_onRefreshEventsByGuest);
  }

  Future<void> _onFetchEventsByCreator(
      FetchEventsByCreator event, Emitter<FetchEventState> emit) async {
    emit(FetchEventLoading());
    try {
      final events = await apiService.fetchEvents(event.createdBy);
      if (events.isEmpty) {
        emit(FetchEventEmpty()); // Emit empty state for empty list
      } else {
        List<Event> yourEvents = [];
        for (var event in events) {
          if (event.role != 'guest') {
            yourEvents.add(event);
          }
        }
        emit(FetchEventLoaded(yourEvents));
      }
    } on EventApiException catch (e) {
      emit(FetchEventError(e.message));
    } catch (e) {
      emit(FetchEventError('An unexpected error occurred'));
    }
  }

  Future<void> _onFetchEventsByGuest(
      FetchEventsByGuest event, Emitter<FetchEventState> emit) async {
    emit(FetchEventLoading());
    try {
      final events = await apiService.fetchEvents(event.createdBy);
      if (events.isEmpty) {
        emit(FetchEventEmpty()); // Emit empty state for empty list
      } else {
        List<Event> upcomingEvents = [];
        for (var event in events) {
          if (event.role == 'guest') {
            upcomingEvents.add(event);
          }
        }
        emit(FetchEventLoaded(upcomingEvents));
      }
    } on EventApiException catch (e) {
      emit(FetchEventError(e.message));
    } catch (e) {
      emit(FetchEventError('An unexpected error occurred'));
    }
  }

  Future<void> _onRefreshEventsByCreator(
      RefreshEventsByCreator event, Emitter<FetchEventState> emit) async {
    final currentEvents =
        state is FetchEventLoaded ? (state as FetchEventLoaded).events : null;

    emit(FetchEventLoading(previousEvents: currentEvents));

    try {
      final events = await apiService.fetchEvents(event.createdBy);
      if (events.isEmpty) {
        emit(FetchEventEmpty()); // Emit empty state for empty list
      } else {
        List<Event> yourEvents = [];
        for (var event in events) {
          if (event.role != 'guest') {
            yourEvents.add(event);
          }
        }
        emit(FetchEventLoaded(yourEvents));
      }
    } on EventApiException catch (e) {
      emit(FetchEventError(e.message));
    } catch (e) {
      emit(FetchEventError('An unexpected error occurred'));
    }
  }

  Future<void> _onRefreshEventsByGuest(
      RefreshEventsByGuest event, Emitter<FetchEventState> emit) async {
    final currentEvents =
        state is FetchEventLoaded ? (state as FetchEventLoaded).events : null;

    emit(FetchEventLoading(previousEvents: currentEvents));

    try {
      final events = await apiService.fetchEvents(event.createdBy);
      if (events.isEmpty) {
        emit(FetchEventEmpty()); // Emit empty state for empty list
      } else {
        List<Event> upcomingEvents = [];
        for (var event in events) {
          if (event.role == 'guest') {
            upcomingEvents.add(event);
          }
        }
        emit(FetchEventLoaded(upcomingEvents));
      }
    } on EventApiException catch (e) {
      emit(FetchEventError(e.message));
    } catch (e) {
      emit(FetchEventError('An unexpected error occurred'));
    }
  }
}
