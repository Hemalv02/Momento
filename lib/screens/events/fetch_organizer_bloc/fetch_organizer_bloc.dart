import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/screens/events/fetch_organizer_bloc/fetch_organizer_event.dart';
import 'package:momento/screens/events/fetch_organizer_bloc/fetch_organizer_state.dart';
import 'package:momento/screens/events/fetch_organizer_bloc/organizer_fetch_api.dart';

class FetchCoorganizerBloc
    extends Bloc<FetchCoorganizerEvent, FetchCoorganizerState> {
  final CoorganizerApiService apiService;

  FetchCoorganizerBloc({required this.apiService})
      : super(FetchCoorganizerInitial()) {
    on<FetchCoorganizerByEventId>(_onFetchCoorganizersByEventId);
    on<RefreshCoorganizersByEventId>(_onRefreshCoorganizersByEventId);
  }

  Future<void> _onFetchCoorganizersByEventId(FetchCoorganizerByEventId event,
      Emitter<FetchCoorganizerState> emit) async {
    emit(FetchCoorganizerLoading());
    try {
      final coorganizers = await apiService.fetchCoorganizers(event.eventId);
      emit(FetchCoorganizerLoaded(coorganizers));
    } catch (e) {
      emit(FetchCoorganizerError("An unexpected error occurred"));
    }
  }

  Future<void> _onRefreshCoorganizersByEventId(
      RefreshCoorganizersByEventId event,
      Emitter<FetchCoorganizerState> emit) async {
    final currentCoorganizers = state is FetchCoorganizerLoaded
        ? (state as FetchCoorganizerLoaded).coorganizers
        : null;

    emit(FetchCoorganizerLoading(previousCoorganizers: currentCoorganizers));

    try {
      final coorganizers = await apiService.fetchCoorganizers(event.eventId);
      emit(FetchCoorganizerLoaded(coorganizers));
    } catch (e) {
      emit(FetchCoorganizerError("An unexpected error occurred",
          previousCoorganizers: currentCoorganizers));
    }
  }
}
