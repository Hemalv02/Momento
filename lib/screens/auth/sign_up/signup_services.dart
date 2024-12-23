import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:momento/utils/flutter_toaster.dart';

class SignupServices {
  static const String apiUrl = "http://192.168.0.108:8000/register";

  static Future<void> performSignUpRequest({
    required String name,
    required String email,
    required String password,
    required String userName,
    required DateTime dateOfBirth,
    required Color bgColor,
    required Color textColor,
    required BuildContext context,
  }) async {
    try {
      // Format the date to ISO 8601 string for API
      String formattedDate = dateOfBirth.toIso8601String().split('T')[0];

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "username": userName,
          "date_of_birth": formattedDate, // Using snake_case for API convention
        }),
      );

      if (response.statusCode == 200) {
        //final responseData = jsonDecode(response.body);
        toastInfo(
          message: "User registered successfully.",
          backgroundColor: bgColor,
          textColor: textColor,
        );
        Navigator.of(context).pop();
      } else {
        final errorData = jsonDecode(response.body);
        toastInfo(
          message:
              "Status code:${response.statusCode}. Registration failed: ${errorData['detail'] ?? response.body}",
          backgroundColor: bgColor,
          textColor: textColor,
        );
      }
    } catch (e) {
      toastInfo(
        message: e.toString(),
        backgroundColor: bgColor,
        textColor: textColor,
      );
    }
  }
}
