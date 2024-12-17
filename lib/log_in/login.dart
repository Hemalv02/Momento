import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:momento/log_in/widget/login_widget.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? Colors.black : Colors.white,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: isDark ? Colors.black : Colors.white,
          appBar: buildAppBar(isDark, "Log In"),
          body: SingleChildScrollView(
            child: Column(
              children: [
                buildThirdPartyLogin(context),
                reusableText("Or use your email account to login"),
                Container(margin: EdgeInsets.only(top: 36.h),
                padding: EdgeInsets.only(left: 25.w, right: 25.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      reusableText("Email"),
                      SizedBox(height: 5.h),
                      buildTextField("Enter your email", "email"),
                      SizedBox(height: 5.h),
                      reusableText("Password"),
                      SizedBox(height: 5.h),
                      buildTextField("Enter your password", "password"),
                      forgotPassword(),
                      buildLogInAndSignUpButton("Log In"),
                      buildLogInAndSignUpButton("Sign Up"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

