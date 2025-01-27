// login_bloc.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/services/auth_api.dart';
import 'package:momento/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_event.dart';
import 'login_states.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final ApiService apiService;

  LoginBloc({required this.apiService}) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      final response = await apiService.loginUser(
        event.email,
        event.password,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response.token);
      await prefs.setString('userId', response.userId);
      await prefs.setString('email', response.email);
      await prefs.setString('username', response.username);
      final notificationService = NotificationService(
        supabase: Supabase.instance.client,
        messaging: FirebaseMessaging.instance,
      );

      // Initialize when user logs in
      await notificationService.initialize(response.userId);

      emit(LoginSuccess(response.token, response.userId, response.email));
    } catch (e) {
      if (e is ApiException) {
        emit(LoginFailure(e.message)); // Handle specific API errors
      } else {
        emit(LoginFailure('An error occurred. Please try again.'));
      }
    }
  }
}
