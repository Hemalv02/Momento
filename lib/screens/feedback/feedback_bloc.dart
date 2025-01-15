import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/screens/feedback/feedback_event.dart';
import 'package:momento/screens/feedback/feedback_repository.dart';
import 'package:momento/screens/feedback/feedback_state.dart';

class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final FeedbackRepository _repository;

  FeedbackBloc({required FeedbackRepository repository})
      : _repository = repository,
        super(FeedbackInitial()) {
    on<SubmitFeedbackEvent>(_onSubmitFeedback);
  }

  Future<void> _onSubmitFeedback(
    SubmitFeedbackEvent event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(FeedbackLoading());

    try {
      final response = await _repository.submitFeedback(
        userId: event.userId,
        feedbackMessage: event.feedbackMessage,
      );

      emit(FeedbackSuccess(message: response['message']));
    } catch (e) {
      emit(FeedbackError(error: e.toString()));
    }
  }
}
