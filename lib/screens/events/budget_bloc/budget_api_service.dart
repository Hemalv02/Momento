import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:momento/screens/events/budget_bloc/budget_model.dart';

class BudgetApiService {
  final String baseUrl = "http://146.190.73.109/budget";

  Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transaction'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(transaction.toJson()),
      );

      if (response.statusCode == 200) {
        return Transaction.fromJson(jsonDecode(response.body));
      } else {
        final errorDetail =
            jsonDecode(response.body)['detail'] ?? 'Unknown error';
        throw Exception('Failed to create transaction: $errorDetail');
      }
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }

  Future<List<Transaction>> getTransactions(
      int eventId, String currentUserId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$eventId/transactions')
            .replace(queryParameters: {'current_user_id': currentUserId}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Transaction.fromJson(json)).toList();
      } else {
        final errorDetail =
            jsonDecode(response.body)['detail'] ?? 'Unknown error';
        throw Exception('Failed to fetch transactions: $errorDetail');
      }
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  Future<Map<String, dynamic>> getBudgetSummary(
      int eventId, String currentUserId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$eventId/summary')
            .replace(queryParameters: {'current_user_id': currentUserId}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorDetail =
            jsonDecode(response.body)['detail'] ?? 'Unknown error';
        throw Exception('Failed to fetch budget summary: $errorDetail');
      }
    } catch (e) {
      throw Exception('Failed to fetch budget summary: $e');
    }
  }
}
