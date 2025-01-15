import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/screens/events/create_guest_bloc/create_guest_event.dart';
import 'package:momento/screens/events/create_guest_bloc/create_guest_state.dart';
import 'package:momento/screens/events/create_guest_bloc/guest_create_api.dart';

class CreateGuestBloc extends Bloc<CreateGuestEvent, CreateGuestState> {
  final GuestCreateApiService apiService;

  CreateGuestBloc({required this.apiService}) : super(CreateGuestInitial()) {
    on<CreateGuestSubmitted>(onCreateEventSubmitted);
  }

  Future<void> onCreateEventSubmitted(
      CreateGuestSubmitted event, Emitter<CreateGuestState> emit) async {
    emit(CreateGuestLoading());
    try {
      final response =
          await apiService.createGuest(event.name, event.email, event.eventId);

      emit(CreateGuestSuccess(response.message));
    } catch (e) {
      if (e is GuestApiException) {
        emit(CreateGuestFailure(e.message)); // Handle specific API errors
      } else {
        emit(CreateGuestFailure("An unexpected error occurred"));
      }
    }
  }
}
