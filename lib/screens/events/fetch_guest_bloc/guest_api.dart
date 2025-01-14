import 'dart:convert';
import 'package:http/http.dart' as http;

class GuestApiService {
  final String baseUrl =
      "https://fastapi-momento-qpa72d3hf-mominul-islam-hemals-projects.vercel.app/guest";

  Future<List<Guest>> fetchEvents(int eventId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/list/$eventId"));

      if (response.statusCode == 200) {
        // Parse the response data
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Guest.fromJson(json)).toList();
      } else {
        throw GuestApiException(
            'Server error: ${response.statusCode}, ${response.body}');
      }
    } on http.ClientException {
      throw GuestApiException('Network error or timeout');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}

class Guest {
  final int id;
  final String createdAt;
  final String name;
  final String email;
  final int eventId;

  Guest({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.email,
    required this.eventId,
  });

  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      id: json['id'],
      createdAt: json['created_at'],
      name: json['name'],
      email: json['email'],
      eventId: json['event_id'],
    );
  }
}

class GuestApiException implements Exception {
  final String message;

  GuestApiException(this.message);
}
