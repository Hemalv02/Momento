import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/log_in/bloc/login_bloc.dart';
import 'package:momento/log_in/password_validator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginController {
  final BuildContext context;
  const LoginController({required this.context});

  void handleLogIn(String type) {
    try {
      if (type == "Log In") {
        //BlocProvider.of<LoginBloc>(context).state;
        final state=context.read<LoginBloc>().state;
        print("Email: ${state.email}");
        String email = state.email;
        String password = state.password;
        //validate email and password
        String? errorTextEmail=validateEmailStructure(email);
        String? errorTextPassword=validatePasswordStructure(password);
        if(errorTextEmail!=null){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorTextEmail)));
          return;
        }
        if(errorTextPassword!=null){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorTextPassword)));
          return;
        }
        //if valid then find the user in the database
          
        //if user is found then add the user to the firebase database so that chat can be done
        // await FirebaseFirestore.instance.collection('users').doc(userCredentials.user!.uid).set({
        //   'username': _enteredUsername,
        //   'email': _enteredEmail,
        // });
        //then navigate to the chat page
      } else {
        //navigate to the register page
      }
    } catch (e) {
      print(e);
    }
  }
}