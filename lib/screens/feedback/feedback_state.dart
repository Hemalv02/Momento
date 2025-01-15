abstract class FeedbackState {}

class FeedbackInitial extends FeedbackState {}

class FeedbackLoading extends FeedbackState {}

class FeedbackSuccess extends FeedbackState {
  final String message;

  FeedbackSuccess({required this.message});
}

class FeedbackError extends FeedbackState {
  final String error;

  FeedbackError({required this.error});
}
