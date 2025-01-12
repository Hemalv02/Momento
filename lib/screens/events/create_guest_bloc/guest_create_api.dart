import 'dart:convert';
import 'package:http/http.dart' as http;

class GuestCreateApiService {
  final String _baseUrl = "https://8bzqcx5t-8000.inc1.devtunnels.ms";

  Future<GuestResponse> createGuest(
    String name,
    String email,
    int eventId,
  ) async {
    try {
      final url = Uri.parse("$_baseUrl/guest/create");
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'event_id': eventId,
        }),
      );

      // Check if the response is successful (status code 200-299)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return GuestResponse.fromJson(jsonDecode(response.body));
      } else {
        // Handle server errors
        final errorDetail =
            jsonDecode(response.body)['detail'] ?? 'Unknown error';
        throw GuestApiException('Error ${response.statusCode}: $errorDetail');
      }
    } catch (e) {
      // Handle unexpected errors
      if (e is GuestApiException) {
        throw e;
      } else {
        throw Exception('An unexpected error occurred: $e');
      }
    }
  }
}

class GuestResponse {
  final String message;

  GuestResponse({required this.message});

  factory GuestResponse.fromJson(Map<String, dynamic> json) {
    return GuestResponse(message: json['message']);
  }
}

class GuestApiException implements Exception {
  final String message;

  GuestApiException(this.message);
}
