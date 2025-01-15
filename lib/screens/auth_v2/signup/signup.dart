import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:momento/screens/auth/sign_up/loading.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/screens/auth_v2/signup/bloc/signup_bloc.dart';
import 'package:momento/screens/auth_v2/signup/bloc/signup_event.dart';
import 'package:momento/screens/auth_v2/signup/bloc/signup_state.dart';
import 'package:momento/screens/auth_v2/signup/signup_otp.dart';
import 'package:momento/services/auth_api.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _acceptTerms = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 20 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset <= 20 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignUpBloc(apiService: ApiService()),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
        ),
        backgroundColor: Colors.white,
        body: BlocConsumer<SignUpBloc, SignUpState>(
          listener: (context, state) {
            if (state is SignUpSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );

              // Navigate to OTP verification screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SignUpOtpVerification(email: emailController.text),
                ),
              );
            }
            if (state is SignUpError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return Form(
              key: formKey,
              child: AnimatedLoadingOverlay(
                isLoading: state is SignUpLoading,
                child: SingleChildScrollView(
                  controller: _scrollController,
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
                              "Create your account",
                              style: TextStyle(
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto',
                                  color: Colors.grey.shade800),
                            ),
                            Text("We are excited to have you join us!",
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                    color: Colors.grey.shade600)),
                          ],
                        ),
                        SizedBox(height: 30.h),
                        // Rest of your existing form code remains the same
                        reusableText("Username"),
                        SizedBox(height: 5.h),
                        TextFormField(
                          controller: usernameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
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
                            hintText: "Enter your username",
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
                        reusableText("Email"),
                        SizedBox(height: 5.h),
                        TextFormField(
                          controller: emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            prefixIcon: const Icon(
                              Icons.email,
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
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
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
                        SizedBox(height: 15.h),
                        reusableText("Confirm Password"),
                        SizedBox(height: 5.h),
                        TextFormField(
                          controller: confirmPasswordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.done,
                          autocorrect: false,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
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
                            hintText: "Confirm your password",
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
                        Row(
                          children: [
                            Transform.scale(
                              scale:
                                  1.5, // Adjust the scale to increase the size of the checkbox
                              child: Checkbox(
                                value: _acceptTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _acceptTerms = value!;
                                  });
                                },
                                activeColor: const Color(0xFF003675),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "By creating an account, you agree to our Terms of Service and Privacy Policy",
                                style: TextStyle(
                                    fontSize: 14.sp, color: Colors.grey[900]),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        FilledButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              // Trigger registration event
                              context.read<SignUpBloc>().add(
                                    RegisterUser(
                                      username: usernameController.text,
                                      email: emailController.text,
                                      password: passwordController.text,
                                    ),
                                  );
                            }

                            if (!_acceptTerms) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Please accept the terms and conditions"),
                                ),
                              );
                            }
                          }, // Disable the button if the terms are not accepted
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF003675),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text("Register"),
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

  Widget reusableText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
        color: Colors.grey.shade800,
      ),
    );
  }
}
