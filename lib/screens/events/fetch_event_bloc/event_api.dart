import 'dart:convert';
import 'package:http/http.dart' as http;

class EventApiService {
  final String baseUrl = "https://8bzqcx5t-8000.inc1.devtunnels.ms/event";

  Future<List<Event>> fetchEvents(String createdBy) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/$createdBy"));

      if (response.statusCode == 200) {
        // Parse the response data
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Event.fromJson(json)).toList();
      } else {
        throw EventApiException(
            'Server error: ${response.statusCode}, ${response.body}');
      }
    } on http.ClientException {
      throw EventApiException('Network error or timeout');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}

class Event {
  final int id;
  final DateTime createdAt;
  final String eventName;
  final String organizedBy;
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final String createdBy;

  Event({
    required this.id,
    required this.createdAt,
    required this.eventName,
    required this.organizedBy,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.createdBy,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      eventName: json['event_name'],
      organizedBy: json['organized_by'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      description: json['description'],
      createdBy: json['created_by'],
    );
  }
}

class EventApiException implements Exception {
  final String message;

  EventApiException(this.message);
}
