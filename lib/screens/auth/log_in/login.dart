import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:momento/screens/auth/log_in/bloc/login_bloc.dart';
import 'package:momento/screens/auth/log_in/bloc/login_events.dart';
import 'package:momento/screens/auth/log_in/bloc/login_states.dart';
import 'package:momento/screens/auth/log_in/widget/login_controller.dart';
import 'package:momento/screens/auth/log_in/widget/login_widget.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark ? Colors.black : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black;
    return BlocBuilder<LoginBloc, LogInState>(
      builder: (context, state) {
        return Container(
          color: bgColor,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: bgColor,
              appBar: buildAppBar(bgColor, textColor, "Log In"),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    buildThirdPartyLogin(context),
                    reusableText("Or use your email account to login"),
                    Container(
                      margin: EdgeInsets.only(top: 36.h),
                      padding: EdgeInsets.only(left: 25.w, right: 25.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          reusableText("Email"),
                          SizedBox(height: 5.h),
                          buildTextField("Enter your email", "email", (value) {
                            context
                                .read<LoginBloc>()
                                .add(EmailEvent(email: value));
                          }),
                          SizedBox(height: 5.h),
                          reusableText("Password"),
                          SizedBox(height: 5.h),
                          buildTextField("Enter your password", "password",
                              (value) {
                            context
                                .read<LoginBloc>()
                                .add(PasswordEvent(password: value));
                          }),
                          forgotPassword(),
                          buildLogInAndSignUpButton("Log In", () {
                            LoginController(context: context)
                                .handleLogIn("email");
                          }),
                          buildLogInAndSignUpButton(
                              "Don't have an account? Sign up", () {
                            Navigator.of(context).pushNamed('register');
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
