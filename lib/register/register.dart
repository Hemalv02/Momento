import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:momento/log_in/widget/login_widget.dart';
import 'package:momento/register/bloc/register_bloc.dart';
import 'package:momento/register/bloc/register_states.dart';
import 'package:momento/register/bloc/register_events.dart';
import 'package:momento/register/register_controller.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RegisterState();
  }
}

class _RegisterState extends State<Register> {
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark ? Colors.black : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black;
    return BlocBuilder<RegisterBloc, RegisterStates>(builder: (context, state) {
      return Container(
        color: bgColor,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: bgColor,
            appBar: buildAppBar(bgColor, textColor, "Register"),
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
                        buildTextField(
                            "Enter your username", "username", (value) {context
                              .read<RegisterBloc>()
                              .add(UserNameEvent(value));}),
                        reusableText("Email"),
                        buildTextField("Enter your email", "email", (value) {
                          context
                              .read<RegisterBloc>()
                              .add(EmailEvent(value));
                        }),
                        reusableText("Password"),
                        buildTextField("Enter your password", "password",
                            (value) {
                          context
                              .read<RegisterBloc>()
                              .add(PasswordEvent(value));
                        }),
                        reusableText("Confirm Password"),
                        buildTextField("Re-enter password", "password",
                            (value) {
                         context
                              .read<RegisterBloc>()
                              .add(ConfirmPasswordEvent(value));
                        }),
                        Container(
                            margin: EdgeInsets.only(left: 25.w),
                            child: reusableText(
                                "By creating an account, you agree to our Terms of Service and Privacy Policy")),
                        SizedBox(height: 20.h),
                        buildLogInAndSignUpButton("Reister", () {
                          //LoginController(context: context).handleLogIn("email");
                          RegisterController(context: context)
                              .handleEmailRegister();
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
