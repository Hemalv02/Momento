import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/screens/auth/log_in/bloc/login_events.dart';
import 'package:momento/screens/auth/log_in/bloc/login_states.dart';

class LoginBloc extends Bloc<LoginEvents, LogInState> {
  LoginBloc() : super(const LogInState()) {
    void emailEvent(EmailEvent event, Emitter<LogInState> emit) {
      emit(state.copyWith(email: event.email));
    }

    on<EmailEvent>(emailEvent);

    void passwordEvent(PasswordEvent event, Emitter<LogInState> emit) {
      emit(state.copyWith(password: event.password));
    }

    on<PasswordEvent>(passwordEvent);
  }
}
