
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/flutter_toaster.dart';
import 'package:momento/log_in/password_validator.dart';
import 'package:momento/register/bloc/register_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterController {
   final BuildContext context;
   RegisterController({required this.context});

   Future<void> handleEmailRegister() async {
     final state = context.read<RegisterBloc>().state;
     String email = state.email;
     String password = state.password;
     String confirmPassword = state.confirmPassword;
     String userName = state.userName;

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

     final supabase = Supabase.instance.client;

     try {
       // Supabase sign-up
       final AuthResponse response = await supabase.auth.signUp(
         email: email,
         password: password,
       );

       // To get the user
       final User? user = response.user;

       if (user == null) {
         toastInfo(message: "Registration failed.", backgroundColor: _bgColor, textColor: _textColor);
         return;
       }

       // Insert user data into Firebase Firestore
       await FirebaseFirestore.instance.collection('users').doc(user.id).set({
         'userId': user.id,
         'username': userName,
         'email': email,
       });

       toastInfo(message: user.id, backgroundColor: _bgColor, textColor: _textColor);
       Navigator.of(context).pop();

     } catch (e) {
       // Handle registration errors
       toastInfo(
           message: e.toString(),
           backgroundColor: _bgColor,
           textColor: _textColor);
     }
   }
}