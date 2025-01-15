import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/screens/events/create_organizer_bloc/create_organizer_event.dart';
import 'package:momento/screens/events/create_organizer_bloc/create_organizer_state.dart';
import 'package:momento/screens/events/create_organizer_bloc/organizer_create_api.dart';

class CoOrganizerBloc extends Bloc<CoOrganizerEvent, CoOrganizerState> {
  final CoOrganizerApiService apiService;

  CoOrganizerBloc({required this.apiService}) : super(CoOrganizerInitial()) {
    on<CoOrganizerSubmitted>(onCoOrganizerSubmitted);
  }

  Future<void> onCoOrganizerSubmitted(
      CoOrganizerSubmitted event, Emitter<CoOrganizerState> emit) async {
    emit(CoOrganizerLoading());
    try {
      final response = await apiService.addCoOrganizer(
          event.eventId, event.email, event.currentUserId);
      emit(CoOrganizerSuccess(response.message));
    } catch (e) {
      if (e is CoOrganizerApiException) {
        emit(CoOrganizerFailure(e.message));
      } else {
        emit(CoOrganizerFailure("An unexpected error occurred"));
      }
    }
  }
}
