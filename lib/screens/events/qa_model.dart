class Question {
  final int id;
  final int eventId;
  final String userId;
  final String question;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int replyCount; // Add this field

  Question({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.question,
    required this.createdAt,
    required this.updatedAt,
    required this.replyCount,
  });

  factory Question.fromMap(
      {required Map<String, dynamic> map, required String myUserId}) {
    return Question(
      id: map['id'],
      eventId: map['event_id'],
      userId: map['user_id'],
      question: map['question'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      replyCount: map['reply_count'] ?? 0, // Add this field
    );
  }
}
