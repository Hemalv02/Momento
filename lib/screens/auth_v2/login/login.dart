import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:momento/screens/auth/log_in/widget/login_widget.dart';
import 'package:momento/screens/auth/sign_up/loading.dart';
import 'package:momento/screens/auth_v2/login/bloc/login_bloc.dart';
import 'package:momento/screens/auth_v2/login/bloc/login_event.dart';
import 'package:momento/screens/auth_v2/login/bloc/login_states.dart';
import 'package:momento/services/auth_api.dart';

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
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
        ),
        backgroundColor: Colors.white,
        body: BlocConsumer<LoginBloc, LoginState>(listener: (context, state) {
          if (state is LoginSuccess) {
            // Navigate to OTP verification screen
            Navigator.of(context).pushReplacementNamed('home');
          }
          if (state is LoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        }, builder: (context, state) {
          return Form(
            key: formKey,
            child: AnimatedLoadingOverlay(
              isLoading: state is LoginLoading,
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.only(top: 35.h),
                  padding: EdgeInsets.only(left: 25.w, right: 25.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                      ),
                      SizedBox(height: 30.h),
                      reusableText("Email"),
                      SizedBox(height: 5.h),
                      TextFormField(
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          // Simple email validation
                          if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          prefixIcon: const Icon(
                            Icons.person,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            borderSide: BorderSide(
                                color: const Color(0xFF003675), width: 2.w),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            borderSide:
                                BorderSide(color: Colors.red, width: 2.w),
                          ),
                          hintText: "Enter your email",
                          hintStyle: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.normal,
                            fontFamily: "Avenir"),
                      ),
                      SizedBox(height: 15.h),
                      reusableText("Password"),
                      SizedBox(height: 5.h),
                      TextFormField(
                        controller: passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          // Password validation: at least 8 characters, one number, and one special character
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          if (!RegExp(r'[0-9]').hasMatch(value)) {
                            return 'Password must contain at least one number';
                          }
                          if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                              .hasMatch(value)) {
                            return 'Password must contain at least one special character';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                        autocorrect: false,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          prefixIcon: const Icon(
                            Icons.lock,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            borderSide: BorderSide(
                                color: const Color(0xFF003675), width: 2.w),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            borderSide:
                                BorderSide(color: Colors.red, width: 2.w),
                          ),
                          hintText: "Enter your password",
                          hintStyle: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.normal,
                            fontFamily: "Avenir"),
                      ),
                      forgotPassword(() {
                        Navigator.of(context).pushNamed('forgot_password');
                      }),
                      SizedBox(height: 8.h),
                      FilledButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            context.read<LoginBloc>().add(
                                  LoginSubmitted(emailController.text,
                                      passwordController.text),
                                );
                            // Add your login functionality here
                            // LoginController(context: context).handleLogIn(emailController.text, passwordController.text);
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF003675),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text("Log In"),
                      ),
                      SizedBox(height: 15.h),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('signup');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0XFF003675),
                          minimumSize: const Size(double.infinity, 56),
                          side: BorderSide(
                            width: 2.w,
                            color: const Color(0xFF003675),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text("Don't have an account? Sign up"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
