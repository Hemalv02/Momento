import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/utils/flutter_toaster.dart';
import 'package:momento/screens/auth/log_in/bloc/login_bloc.dart';
import 'package:momento/screens/auth/log_in/password_validator.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

class LoginController {
  final BuildContext context;
  const LoginController({required this.context});

  Future<void> handleLogIn(String type) async {
    try {
      if (type == "email") {
        //BlocProvider.of<LoginBloc>(context).state;
        final state = context.read<LoginBloc>().state;
        //print("Email: ${state.email}");
        String email = state.email;
        String password = state.password;
        //validate email and password
        String? _errorTextEmail = validateEmailStructure(email);
        String? _errorTextPassword = validatePasswordStructure(password);

        bool _isDark = Theme.of(context).brightness == Brightness.dark;
        Color _textColor = _isDark ? Colors.black : Colors.white;
        Color _bgColor = _isDark ? Colors.white : Colors.black;

        if (_errorTextEmail != null) {
          toastInfo(
              message: _errorTextEmail,
              textColor: _textColor,
              backgroundColor: _bgColor);
          return;
        }
        if (_errorTextPassword != null) {
          toastInfo(
              message: _errorTextPassword,
              textColor: _textColor,
              backgroundColor: _bgColor);
          return;
        }
        // final supabase = Supabase.instance.client;

        try {
          // final AuthResponse response = await supabase.auth.signInWithPassword(
          //   email: email,
          //   password: password,
          // );
          // final User? user = response.user;
          // if (user == null) {
          //   toastInfo(
          //     message: "You don't exist.",
          //     textColor: _textColor,
          //     backgroundColor: _bgColor,
          //   );
          //   return;
          // }
          print(email);
          print(password);
          toastInfo(
              message: "Logged in ",
              backgroundColor: _bgColor,
              textColor: _textColor);

          // Handle successful login
        } catch (e) {
          // Handle login errors
          if (e.toString().contains("Invalid login credentials")) {
            toastInfo(
                message: "Invalid login credentials",
                textColor: _textColor,
                backgroundColor: _bgColor);
          } else {
            toastInfo(
                message: "Login failed: $e",
                textColor: _textColor,
                backgroundColor: _bgColor);
          }

          print('Login failed: $e');
          return;
        }
        // Navigator.of(context).pushReplacementNamed('home');
        //then navigate to the chat page
      } else {
        //navigate to the register page
      }
    } catch (e) {
      print(e);
    }
  }
}
