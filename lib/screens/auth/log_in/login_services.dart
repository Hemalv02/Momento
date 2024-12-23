import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:momento/utils/flutter_toaster.dart';

class LoginServices {
  static const String apiUrl = 'http://192.168.8.107:8000/login';

  static Future<void> performLoginRequest({
    required String email,
    required String password,
    required Color bgColor,
    required Color textColor,
    required BuildContext context,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://192.168.0.108:8000/login'), // Replace with your API URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        toastInfo(
            message: "Logged in: ${responseData['message']}",
            backgroundColor: bgColor,
            textColor: textColor);

        // Navigate to home or chat page
        Navigator.of(context).pushReplacementNamed('reset_password');
        //home page nai tai onno page e push kore dekhlam arki
      } else {
        final responseData = json.decode(response.body);
        toastInfo(
            message: "Login failed: ${responseData['detail']}",
            textColor: textColor,
            backgroundColor: bgColor);
      }
    } catch (e) {
      print(e);
      toastInfo(
        message: e.toString(),
        backgroundColor: bgColor,
        textColor: textColor,
      );
    }
  }
}
