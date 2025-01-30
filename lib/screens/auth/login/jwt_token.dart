import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenValidator {
  static const String _tokenKey = 'token'; // SharedPreferences key

  /// Reads the token from SharedPreferences
  Future<String?> _getTokenFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Checks if the token is valid and not expired
  Future<bool> isTokenValid() async {
    // Fetch the token from SharedPreferences
    final token = await _getTokenFromPreferences();

    if (token == null || token.isEmpty) {
      print('Token not found in SharedPreferences.');
      return false;
    }

    // Decode the token without verifying signature
    try {
      // Decode the JWT to get the claims
      if (JwtDecoder.isExpired(token)) {
        print('Token has expired.');
        return false;
      }

      return true;
    } catch (e) {
      print('Error while decoding or validating the token: $e');
      return false;
    }
  }

  /// Saves a new token to SharedPreferences
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    print('Token saved to SharedPreferences.');
  }

  /// Deletes the token from SharedPreferences
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    print('Token removed from SharedPreferences.');
  }
}
