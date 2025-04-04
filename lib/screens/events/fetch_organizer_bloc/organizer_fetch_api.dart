import 'dart:convert';
import 'package:http/http.dart' as http;

class CoorganizerApiService {
  final String baseUrl = "http://146.190.73.109/event";

  Future<List<Coorganizer>> fetchCoorganizers(int eventId) async {
    try {
      final response =
          await http.get(Uri.parse("$baseUrl/$eventId/coorganizers"));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Coorganizer.fromJson(json)).toList();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}

class Coorganizer {
  final String username;
  final String email;

  Coorganizer({
    required this.username,
    required this.email,
  });

  factory Coorganizer.fromJson(Map<String, dynamic> json) {
    return Coorganizer(
      username: json['username'],
      email: json['email'],
    );
  }
}
