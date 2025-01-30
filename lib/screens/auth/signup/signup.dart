import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/custom_widgets/loading.dart';
import 'package:momento/custom_widgets/login_widget.dart';
import 'package:momento/screens/auth/signup/bloc/signup_bloc.dart';
import 'package:momento/screens/auth/signup/bloc/signup_event.dart';
import 'package:momento/screens/auth/signup/bloc/signup_state.dart';
import 'package:momento/screens/auth/signup/signup_otp.dart';
import 'package:momento/services/auth_api.dart';
import 'package:momento/utils/password_validator.dart';

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
  bool _acceptTerms = true;

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
        appBar: reusableAppBar(),
        backgroundColor: Colors.white,
        body: BlocConsumer<SignUpBloc, SignUpState>(
          listener: (context, state) {
            if (state is SignUpSuccess) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        SignUpOtpVerification(email: emailController.text)),
              );
            }
            if (state is SignUpError) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            return Form(
              key: formKey,
              child: AnimatedLoadingOverlay(
                isLoading: state is SignUpLoading,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding:
                      EdgeInsets.symmetric(horizontal: 25.w, vertical: 35.h),
                  child: Column(
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
                      reusableText("We are excited to have you join us!"),
                      SizedBox(height: 30.h),
                      reusableText("Username"),
                      SizedBox(height: 5.h),
                      SizedBox(height: 5.h),
                      reusableTextField(
                        controller: usernameController,
                        hintText: "Enter your username",
                        prefixIcon: Icons.person,
                        textInputAction: TextInputAction.next,
                        obscureText: false,
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your username'
                            : null,
                      ),
                      SizedBox(height: 15.h),
                      reusableText("Email"),
                      SizedBox(height: 5.h),
                      reusableTextField(
                        controller: emailController,
                        hintText: "Enter your email",
                        prefixIcon: Icons.email,
                        textInputAction: TextInputAction.next,
                        obscureText: false,
                        validator: validateEmailStructure,
                      ),
                      SizedBox(height: 15.h),
                      reusableText("Password"),
                      SizedBox(height: 5.h),
                      reusableTextField(
                        controller: passwordController,
                        hintText: "Enter your password",
                        prefixIcon: Icons.lock,
                        textInputAction: TextInputAction.next,
                        obscureText: true,
                        validator: validatePasswordStructure,
                      ),
                      SizedBox(height: 15.h),
                      reusableText("Confirm Password"),
                      SizedBox(height: 5.h),
                      reusableTextField(
                        controller: confirmPasswordController,
                        hintText: "Confirm your password",
                        prefixIcon: Icons.lock,
                        textInputAction: TextInputAction.done,
                        obscureText: true,
                        validator: (value) => value != passwordController.text
                            ? 'Passwords do not match'
                            : null,
                      ),
                      SizedBox(height: 15.h),
                      Row(
                        children: [
                          Transform.scale(
                            scale: 1.5,
                            child: Checkbox(
                              value: _acceptTerms,
                              onChanged: (value) =>
                                  setState(() => _acceptTerms = value!),
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
                      reusableFilledButton(
                        text: "Register",
                        onPressed: () {
                          if (formKey.currentState!.validate() &&
                              _acceptTerms) {
                            context.read<SignUpBloc>().add(
                                  RegisterUser(
                                    username: usernameController.text,
                                    email: emailController.text,
                                    password: passwordController.text,
                                  ),
                                );
                          } else if (!_acceptTerms) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Please accept the terms and conditions")),
                            );
                          }
                        },
                      ),
                    ],
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
