import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/screens/auth/sign_up/bloc/signup_events.dart';
import 'package:momento/screens/auth/sign_up/bloc/signup_states.dart';

class SignUpBloc extends Bloc<SignUpEvents, SignUpStates> {
  SignUpBloc() : super(SignUpStates.initial()) {
    void nameEvent(NameEvent event, Emitter<SignUpStates> emit) {
      emit(state.copyWith(name: event.name));
    }

    on<NameEvent>(nameEvent);

    void userNameEvent(UserNameEvent event, Emitter<SignUpStates> emit) {
      emit(state.copyWith(userName: event.userName));
    }

    on<UserNameEvent>(userNameEvent);

    void emailEvent(EmailEvent event, Emitter<SignUpStates> emit) {
      emit(state.copyWith(email: event.email));
    }

    on<EmailEvent>(emailEvent);

    void dateOfBirthEvent(DateOfBirthEvent event, Emitter<SignUpStates> emit) {
      emit(state.copyWith(dateOfBirth: event.dateOfBirth));
    }

    on<DateOfBirthEvent>(dateOfBirthEvent);

    void passwordEvent(PasswordEvent event, Emitter<SignUpStates> emit) {
      emit(state.copyWith(password: event.password));
    }

    on<PasswordEvent>(passwordEvent);

    void confirmPasswordEvent(ConfirmPasswordEvent event, Emitter<SignUpStates> emit) {
      emit(state.copyWith(confirmPassword: event.confirmPassword));
    }

    on<ConfirmPasswordEvent>(confirmPasswordEvent);

    void checkEvent(CheckEvent event, Emitter<SignUpStates> emit) {
      emit(state.copyWith(isChecked: event.isChecked));
    }

    on<CheckEvent>(checkEvent);
  }
}