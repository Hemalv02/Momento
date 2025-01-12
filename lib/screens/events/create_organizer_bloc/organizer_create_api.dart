import 'dart:convert';
import 'package:http/http.dart' as http;

class CoOrganizerApiService {
  final String _baseUrl = "https://8bzqcx5t-8000.inc1.devtunnels.ms/event";

  Future<CoOrganizerResponse> addCoOrganizer(
      int eventId, String email, String currentUserId) async {
    try {
      final url = Uri.parse("$_baseUrl/$eventId/coorganizers");
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'event_id': eventId,
          'email': email,
          'current_user_id': currentUserId,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return CoOrganizerResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorDetail =
            jsonDecode(response.body)['detail'] ?? 'Unknown error';
        throw CoOrganizerApiException(
            'Error ${response.statusCode}: $errorDetail');
      }
    } catch (e) {
      if (e is CoOrganizerApiException) {
        throw e;
      } else {
        throw Exception('An unexpected error occurred: $e');
      }
    }
  }
}

class CoOrganizerResponse {
  final String message;

  CoOrganizerResponse({required this.message});

  factory CoOrganizerResponse.fromJson(Map<String, dynamic> json) {
    return CoOrganizerResponse(message: json['message']);
  }
}

class CoOrganizerApiException implements Exception {
  final String message;

  CoOrganizerApiException(this.message);
}
