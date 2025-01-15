import 'package:dio/dio.dart';

class EventApiService {
  final Dio _dio;

  EventApiService() : _dio = Dio();

  Future<EventResponse> createEvent(
      String name,
      String organizedBy,
      DateTime startDate,
      DateTime endDate,
      String description,
      String createdBy) async {
    try {
      final response = await _dio.post(
        "https://fastapi-momento.vercel.app/event/create",
        data: {
          'event_name': name,
          'organized_by': organizedBy,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'description': description,
          'created_by': createdBy,
        },
      );

      // If the request succeeded (status code 200), return the parsed response
      return EventResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Handle DioError explicitly
      if (e.response != null) {
        // Server responded with a non-200 status code
        throw EventApiException(e.response?.data['detail'] ??
            'An unknown error occurred with status code ${e.response?.statusCode}');
      } else {
        // No response (e.g., network error, timeout, etc.)
        throw EventApiException('Failed to connect to the server');
      }
    } catch (e) {
      // Catch other unexpected exceptions
      throw Exception('An unexpected error occurred: $e');
    }
  }
}

class EventResponse {
  final String message;

  EventResponse({required this.message});

  factory EventResponse.fromJson(Map<String, dynamic> json) {
    return EventResponse(message: json['message']);
  }
}

class EventApiException implements Exception {
  final String message;

  EventApiException(this.message);
}
