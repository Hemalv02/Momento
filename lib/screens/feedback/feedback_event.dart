abstract class FeedbackEvent {}

class SubmitFeedbackEvent extends FeedbackEvent {
  final String userId;
  final String feedbackMessage;

  SubmitFeedbackEvent({
    required this.userId,
    required this.feedbackMessage,
  });
}
