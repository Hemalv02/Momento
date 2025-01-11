import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/screens/events/bloc/create_event_event.dart';
import 'package:momento/screens/events/bloc/create_event_state.dart';
import 'package:momento/services/event_api.dart';

class CreateEventBloc extends Bloc<CreateEventEvent, CreateEventState> {
  final EventApiService apiService;

  CreateEventBloc({required this.apiService}) : super(CreateEventInitial()) {
    on<CreateEventSubmitted>(onCreateEventSubmitted);
  }

  Future<void> onCreateEventSubmitted(
      CreateEventSubmitted event, Emitter<CreateEventState> emit) async {
    emit(CreateEventLoading());
    try {
      final response = await apiService.createEvent(
          event.name,
          event.organizedBy,
          event.startDate,
          event.endDate,
          event.description,
          event.createdBy);

      print(response);
      emit(CreateEventSuccess(response.message));
    } catch (e) {
      if (e is EventApiException) {
        emit(CreateEventFailure(e.message)); // Handle specific API errors
      } else {
        emit(CreateEventFailure("An unexpected error occurred"));
      }
    }
  }
}
