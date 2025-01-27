import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final SupabaseClient _supabase;
  final FirebaseMessaging _messaging;

  NotificationService({
    required SupabaseClient supabase,
    required FirebaseMessaging messaging,
  })  : _supabase = supabase,
        _messaging = messaging;

  /// Initialize notification service and handle token management
  Future<void> initialize(String userId) async {
    try {
      // Request notification permissions
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Save or update token
      await saveOrUpdateFCMToken(userId);

      // Listen for token refresh and update it in Supabase
      _messaging.onTokenRefresh.listen((newToken) async {
        await saveOrUpdateFCMToken(userId);
      });
    } catch (e) {
      print('Error initializing notification service: $e');
      // Optionally report the error to a tracking service
      rethrow;
    }
  }

  /// Save or update the FCM token in Supabase
  Future<void> saveOrUpdateFCMToken(String userId) async {
    try {
      final token = await _messaging.getToken();
      print('FCM token: $token');
      if (token == null) {
        print('Failed to get FCM token');
        return;
      }

      // Check if a token exists for the user
      final response = await _supabase
          .from('fcm_token') // Ensure this matches your table name (singular)
          .select('id, token')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        // Insert a new token if none exists
        await _supabase.from('fcm_token').insert({
          'user_id': userId,
          'token': token,
        });
        print('New FCM token stored in Supabase');
      } else if (response['token'] != token) {
        // Update the existing token if it has changed
        await _supabase.from('fcm_token').update({
          'token': token,
        }).eq('id', response['id']);
        print('FCM token updated in Supabase');
      } else {
        print('FCM token is already up to date');
      }
    } catch (e) {
      print('Error saving/updating FCM token: $e');
      // Optionally report the error to a tracking service
      rethrow;
    }
  }

  /// Delete the FCM token for a user
  Future<void> deleteToken(String userId) async {
    try {
      await _supabase.from('fcm_token').delete().eq('user_id', userId);
      print('FCM token deleted from Supabase');
    } catch (e) {
      print('Error deleting FCM token: $e');
      // Optionally report the error to a tracking service
      rethrow;
    }
  }
}
