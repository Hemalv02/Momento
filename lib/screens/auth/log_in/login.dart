import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:momento/screens/auth/log_in/bloc/login_bloc.dart';
import 'package:momento/screens/auth/log_in/bloc/login_events.dart';
import 'package:momento/screens/auth/log_in/bloc/login_states.dart';
import 'package:momento/screens/auth/log_in/login_controller.dart';
import 'package:momento/screens/auth/log_in/widget/login_widget.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LogInState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Log In"),
            backgroundColor: const Color(0xFF003675),
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(top: 35.h),
              padding: EdgeInsets.only(left: 25.w, right: 25.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: Column(
                    children: [
                      Text(
                        "Welcome back!",
                        style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                            color: Colors.grey.shade800),
                      ),
                      Text("We are so excited to see you again!",
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                              color: Colors.grey.shade600)),
                    ],
                  )),
                  SizedBox(height: 30.h),
                  reusableText("Email"),
                  SizedBox(height: 5.h),
                  buildTextField("Enter your email", "email", (value) {
                    context.read<LoginBloc>().add(EmailEvent(email: value));
                  }),
                  SizedBox(height: 15.h),
                  reusableText("Password"),
                  SizedBox(height: 5.h),
                  buildTextField("Enter your password", "password", (value) {
                    context
                        .read<LoginBloc>()
                        .add(PasswordEvent(password: value));
                  }),
                  forgotPassword(() {
                    Navigator.of(context).pushNamed('forgot_password');
                  }),
                  SizedBox(height: 8.h),
                  loginButton("Log In", () {
                    LoginController(context: context).handleLogIn("email");
                  }),
                  SizedBox(height: 15.h),
                  signUpButton("Don't have an account? Sign up", () {
                    Navigator.of(context).pushNamed('signup');
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
