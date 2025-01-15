import 'dart:convert';
import 'package:http/http.dart' as http;

class EventApiService {
  final String baseUrl = "https://fastapi-momento.vercel.app/event";

  Future<List<Event>> fetchEvents(String createdBy) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/$createdBy"));

      // For 404, return empty list instead of throwing error
      if (response.statusCode == 404) {
        return [];
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isEmpty) {
          return []; // Return empty list if response is empty
        }
        return data.map((json) => Event.fromJson(json)).toList();
      }

      // Handle other error cases
      final dynamic responseData = jsonDecode(response.body);
      final String errorMessage =
          responseData['detail'] ?? 'Server error occurred';
      throw EventApiException(errorMessage);
    } on FormatException {
      throw EventApiException('Invalid response format from server');
    } on http.ClientException {
      throw EventApiException('Network error or timeout');
    } catch (e) {
      if (e is EventApiException) {
        rethrow;
      }
      throw EventApiException('Unexpected error occurred: ${e.toString()}');
    }
  }
}

class Event {
  final int id;
  final DateTime createdAt;
  final String eventName;
  final String organizedBy;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final String createdBy;

  Event({
    required this.id,
    required this.createdAt,
    required this.eventName,
    required this.organizedBy,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.createdBy,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    try {
      return Event(
        id: json['id'],
        createdAt: DateTime.parse(json['created_at']),
        eventName: json['event_name'],
        organizedBy: json['organized_by'],
        location: json['location'],
        startDate: DateTime.parse(json['start_date']),
        endDate: DateTime.parse(json['end_date']),
        description: json['description'],
        createdBy: json['created_by'],
      );
    } catch (e) {
      throw EventApiException('Error parsing event data: ${e.toString()}');
    }
  }
}

class EventApiException implements Exception {
  final String message;

  EventApiException(this.message);

  @override
  String toString() => message;
}
