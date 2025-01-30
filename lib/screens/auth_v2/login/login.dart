import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:momento/custom_widgets/loading.dart';
import 'package:momento/custom_widgets/login_widget.dart';
import 'package:momento/screens/auth_v2/login/bloc/login_bloc.dart';
import 'package:momento/screens/auth_v2/login/bloc/login_event.dart';
import 'package:momento/screens/auth_v2/login/bloc/login_states.dart';
import 'package:momento/services/auth_api.dart';
import 'package:momento/utils/password_validator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(apiService: ApiService()),
      child: Scaffold(
        appBar: reusableAppBar(),
        backgroundColor: Colors.white,
        body: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              Navigator.of(context).pushReplacementNamed('page_selector');
            }
            if (state is LoginFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          builder: (context, state) {
            return Form(
              key: formKey,
              child: AnimatedLoadingOverlay(
                isLoading: state is LoginLoading,
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.only(top: 35.h),
                    padding: EdgeInsets.symmetric(horizontal: 25.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Text
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome back!",
                              style: TextStyle(
                                fontSize: 32.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto',
                                color: Colors.grey.shade800,
                              ),
                            ),
                            Text(
                              "We are so excited to see you again!",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto',
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30.h),
                        // Email Input
                        reusableText("Email"),
                        SizedBox(height: 5.h),
                        reusableTextField(
                          controller: emailController,
                          hintText: "Enter your email",
                          prefixIcon: Icons.person,
                          textInputAction: TextInputAction.next,
                          obscureText: false,
                          validator: validateEmailStructure,
                        ),
                        SizedBox(height: 15.h),
                        // Password Input
                        reusableText("Password"),
                        SizedBox(height: 5.h),
                        reusableTextField(
                          controller: passwordController,
                          hintText: "Enter your password",
                          prefixIcon: Icons.lock,
                          textInputAction: TextInputAction.done,
                          obscureText: true,
                          validator: validatePasswordStructure,
                        ),
                        // Forgot Password
                        forgotPassword(() {
                          Navigator.of(context).pushNamed('forgot_password');
                        }),
                        SizedBox(height: 8.h),
                        // Login Button
                        reusableFilledButton(
                          text: "Log In",
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              context.read<LoginBloc>().add(
                                    LoginSubmitted(
                                      emailController.text,
                                      passwordController.text,
                                    ),
                                  );
                            }
                          },
                        ),
                        SizedBox(height: 15.h),
                        // Sign Up Button
                        reusableOutlinedButton(
                          text: "Don't have an account? Sign up",
                          onPressed: () {
                            Navigator.of(context).pushNamed('signup');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
