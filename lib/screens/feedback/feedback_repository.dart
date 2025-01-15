import 'dart:convert';
import 'package:http/http.dart' as http;

class FeedbackRepository {
  final String baseUrl = 'https://fastapi-momento.vercel.app';

  Future<Map<String, dynamic>> submitFeedback({
    required String userId,
    required String feedbackMessage,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/feedback/send'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': userId,
          'feedbackMessage': feedbackMessage,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to submit feedback: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to submit feedback: ${e.toString()}');
    }
  }
}
