import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/screens/auth/sign_up/signup_services.dart';
import 'package:momento/utils/flutter_toaster.dart';
import 'package:momento/screens/auth/log_in/password_validator.dart';
import 'package:momento/screens/auth/sign_up/bloc/signup_bloc.dart';

class SignUpController {
  final BuildContext context;
  SignUpController({required this.context});

  Future<void> handleEmailSignUp() async {
    final state = context.read<SignUpBloc>().state;
    String email = state.email;
    String password = state.password;
    String confirmPassword = state.confirmPassword;
    String userName = state.userName;
    bool isChecked = state.isChecked;

    String? _errorTextEmail = validateEmailStructure(email);
    String? _errorTextPassword = validatePasswordStructure(password);

    bool _isDark = Theme.of(context).brightness == Brightness.dark;
    Color _textColor = _isDark ? Colors.black : Colors.white;
    Color _bgColor = _isDark ? Colors.white : Colors.black;

    if (userName.isEmpty) {
      toastInfo(
          message: "User name cannot be empty.",
          backgroundColor: _bgColor,
          textColor: _textColor);
      return;
    }

    if (_errorTextEmail != null) {
      toastInfo(
          message: _errorTextEmail,
          backgroundColor: _bgColor,
          textColor: _textColor);
      return;
    }

    if (_errorTextPassword != null) {
      toastInfo(
          message: _errorTextPassword,
          backgroundColor: _bgColor,
          textColor: _textColor);
      return;
    }

    if (password != confirmPassword) {
      toastInfo(
          message: "Passwords do not match.",
          backgroundColor: _bgColor,
          textColor: _textColor);
      return;
    }

    if (!isChecked) {
      toastInfo(
          message: "Please agree to the terms and conditions.",
          backgroundColor: _bgColor,
          textColor: _textColor);
      return;
    }


await SignupServices.performSignUpRequest(
      email: email,
      password: password,
      userName: userName,
      bgColor: _bgColor,
      textColor: _textColor,
      dateOfBirth: state.dateOfBirth,
      name: state.name,
      context: context,
    );
  }
}
