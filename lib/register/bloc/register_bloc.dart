import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/register/bloc/register_events.dart';
import 'package:momento/register/bloc/register_states.dart';

class RegisterBloc extends Bloc<RegisterEvents, RegisterStates>{
  RegisterBloc():super(const RegisterStates(userName: "", email: "", password: "", confirmPassword: "")){
    void userNameEvent(UserNameEvent event, Emitter<RegisterStates> emit){
      emit(state.copyWith(userName: event.userName));
    }
    on<UserNameEvent>(userNameEvent);

    void emailEvent(EmailEvent event, Emitter<RegisterStates> emit){
      emit(state.copyWith(email: event.email));
    }
    on<EmailEvent>(emailEvent);

    void passwordEvent(PasswordEvent event, Emitter<RegisterStates> emit){
      emit(state.copyWith(password: event.password));
    }
    on<PasswordEvent>(passwordEvent);

    void confirmPasswordEvent(ConfirmPasswordEvent event, Emitter<RegisterStates> emit){
      emit(state.copyWith(confirmPassword: event.confirmPassword));
    }
    on<ConfirmPasswordEvent>(confirmPasswordEvent);
  }

}