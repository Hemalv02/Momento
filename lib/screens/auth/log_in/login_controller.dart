import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/utils/flutter_toaster.dart';
import 'package:momento/screens/auth/log_in/bloc/login_bloc.dart';
import 'package:momento/screens/auth/log_in/password_validator.dart';
import 'package:momento/screens/auth/log_in/login_services.dart';

class LoginController {
  final BuildContext context;
  const LoginController({required this.context});

  Future<void> handleLogIn(String type) async {
    try {
      if (type == "email") {
        final state = context.read<LoginBloc>().state;
        String email = state.email;
        String password = state.password;

        // Validate email and password
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

        // Make POST request to FastAPI login endpoint
        await LoginServices.performLoginRequest(
          email: email,
          password: password,
          bgColor: _bgColor,
          textColor: _textColor,
          context: context,
        );
      } else {
        // Navigate to the register page
        Navigator.of(context).pushNamed('register');
      }
    } catch (e) {
      print(e);
    }
  }
}
