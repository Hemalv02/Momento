import 'package:dio/dio.dart'; // or use any HTTP client like `http`

class ApiService {
  final Dio _dio;

  ApiService() : _dio = Dio();

  Future<LoginResponse> loginUser(String email, String password) async {
    try {
      final response = await _dio.post(
        "https://8bzqcx5t-8000.inc1.devtunnels.ms/auth/login",
        data: {
          'email': email,
          'password': password,
        },
      );

      // If the request succeeded (status code 200), return the parsed response
      return LoginResponse(
        token: response.data['access_token'],
        userId: response.data['user_id'],
        email: response.data['email'],
        username: response.data['username'],
      );
    } on DioException catch (e) {
      // Handle DioError explicitly
      if (e.response != null) {
        // Server responded with a non-200 status code
        throw ApiException(e.response?.data['detail'] ??
            'An unknown error occurred with status code ${e.response?.statusCode}');
      } else {
        // No response (e.g., network error, timeout, etc.)
        throw ApiException('Failed to connect to the server');
      }
    } catch (e) {
      // Catch other unexpected exceptions
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<RegistrationResponse> registerUser(
      String username, String email, String password) async {
    try {
      final response = await _dio.post(
        "https://8bzqcx5t-8000.inc1.devtunnels.ms/auth/register",
        data: {
          "username": username,
          "email": email,
          "password": password,
        },
      );

      // If the request succeeded (status code 200), return the parsed response
      return RegistrationResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Handle DioError explicitly
      if (e.response != null) {
        // Server responded with a non-200 status code
        throw ApiException(e.response?.data['detail'] ??
            'An unknown error occurred with status code ${e.response?.statusCode}');
      } else {
        // No response (e.g., network error, timeout, etc.)
        throw ApiException('Failed to connect to the server');
      }
    } catch (e) {
      // Catch other unexpected exceptions
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<OTPResponse> verifyOTP(
      String email, String otp, String otpType) async {
    try {
      final response = await _dio.post(
        "https://8bzqcx5t-8000.inc1.devtunnels.ms/auth/verify-otp",
        data: {
          "email": email,
          "otp": otp,
          "otp_type": otpType,
        },
      );

      // If the request succeeded (status code 200), return the parsed response
      return OTPResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Handle DioError explicitly
      if (e.response != null) {
        // Server responded with a non-200 status code
        throw ApiException(e.response?.data['detail'] ??
            'An unknown error occurred with status code ${e.response?.statusCode}');
      } else {
        // No response (e.g., network error, timeout, etc.)
        throw ApiException('Failed to connect to the server');
      }
    } catch (e) {
      // Catch other unexpected exceptions
      throw Exception('An unexpected error occurred: $e');
    }
  }
}

class OTPResponse {
  final String message;

  OTPResponse({required this.message});

  factory OTPResponse.fromJson(Map<String, dynamic> json) {
    return OTPResponse(message: json['message']);
  }
}

class RegistrationResponse {
  final String message;

  RegistrationResponse({required this.message});

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationResponse(message: json['message']);
  }
}

class ApiException implements Exception {
  final String message;

  ApiException(this.message);
}

class LoginResponse {
  final String token;
  final String userId;
  final String email;
  final String username;

  LoginResponse(
      {required this.token,
      required this.userId,
      required this.email,
      required this.username});
}
