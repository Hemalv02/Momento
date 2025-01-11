import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/services/auth_api.dart'; // API service to call the registration endpoint
import 'signup_event.dart';
import 'signup_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final ApiService apiService;

  SignUpBloc({required this.apiService}) : super(SignUpInitial()) {
    on<RegisterUser>(_onRegisterUser);
  }

  Future<void> _onRegisterUser(
      RegisterUser event, Emitter<SignUpState> emit) async {
    emit(SignUpLoading());
    try {
      final response = await apiService.registerUser(
        event.username,
        event.email,
        event.password,
      );

      print(response);
      emit(SignUpSuccess(message: response.message));
    } catch (e) {
      if (e is ApiException) {
        emit(SignUpError(message: e.message)); // Handle specific API errors
      } else {
        emit(const SignUpError(message: "An unexpected error occurred"));
      }
    }
  }
}
