import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:momento/screens/auth/log_in/widget/login_widget.dart';
import 'package:momento/screens/auth/sign_up/bloc/signup_bloc.dart';
import 'package:momento/screens/auth/sign_up/bloc/signup_states.dart';
import 'package:momento/screens/auth/sign_up/bloc/signup_events.dart';
import 'package:momento/screens/auth/sign_up/signup_controller.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark ? Colors.black : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black;
    return BlocBuilder<SignUpBloc, SignUpStates>(builder: (context, state) {
      return Container(
        color: bgColor,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
              title: const Text("Sign Up"),
              backgroundColor: const Color(0xFF003675),
              foregroundColor: Colors.white,
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  reusableText("Enter your details below to register"),
                  Container(
                    margin: EdgeInsets.only(top: 36.h),
                    padding: EdgeInsets.only(left: 25.w, right: 25.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        reusableText("User name"),
                        buildTextField("Enter your username", "username",
                            (value) {
                          context.read<SignUpBloc>().add(UserNameEvent(value));
                        }),
                        reusableText("Email"),
                        buildTextField("Enter your email", "email", (value) {
                          context.read<SignUpBloc>().add(EmailEvent(value));
                        }),
                        reusableText("Password"),
                        buildTextField("Enter your password", "password",
                            (value) {
                          context.read<SignUpBloc>().add(PasswordEvent(value));
                        }),
                        reusableText("Confirm Password"),
                        buildTextField("Re-enter password", "password",
                            (value) {
                          context
                              .read<SignUpBloc>()
                              .add(ConfirmPasswordEvent(value));
                        }),
                        Container(
                            margin: EdgeInsets.only(left: 25.w),
                            child: reusableText(
                                "By creating an account, you agree to our Terms of Service and Privacy Policy")),
                        SizedBox(height: 20.h),
                        loginButton("Reister", () {
                          //LoginController(context: context).handleLogIn("email");
                          SignUpController(context: context)
                              .handleEmailSignUp();
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
    });
  }
}
