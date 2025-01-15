import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

import 'package:momento/screens/auth/sign_up/loading.dart';
import 'package:momento/screens/auth_v2/signup/bloc/signup_otp_bloc.dart';
import 'package:momento/screens/auth_v2/signup/bloc/signup_otp_event.dart';
import 'package:momento/screens/auth_v2/signup/bloc/signup_otp_state.dart';
import 'package:momento/services/auth_api.dart';

class SignUpOtpVerification extends StatefulWidget {
  final String email;
  const SignUpOtpVerification({super.key, required this.email});

  @override
  State<SignUpOtpVerification> createState() => _SignUpOtpVerificationState();
}

class _SignUpOtpVerificationState extends State<SignUpOtpVerification> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  Timer? _timer;
  int _secondsRemaining = 120;
  bool _isTimerActive = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isTimerActive = false;
        });
      }
    });
  }

  void _resendOTP() {
    setState(() {
      _secondsRemaining = 120;
      _isTimerActive = true;
    });
    _startTimer();
    // Logic to resend OTP can be added here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("OTP has been resent.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OtpBloc(apiService: ApiService()),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
        ),
        backgroundColor: Colors.white,
        body: BlocConsumer<OtpBloc, OtpState>(
          listener: (context, state) {
            if (state is OtpSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("OTP Verified Successfully!")),
              );
              Navigator.of(context).pushReplacementNamed('login');
            }
            if (state is OtpFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          builder: (context, state) {
            return AnimatedLoadingOverlay(
              isLoading: state is OtpLoading,
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.only(top: 20.h),
                  padding: EdgeInsets.only(left: 25.w, right: 25.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Verify your account",
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            "We have sent you an OTP in your email. Please enter the OTP to confirm your registration.",
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
                      reusableText("OTP"),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 50.w,
                            child: TextField(
                              controller: _otpControllers[index],
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                counterText: "",
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: const Color(0xFF003675),
                                    width: 2.w,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 5) {
                                  FocusScope.of(context).nextFocus();
                                } else if (value.isEmpty && index > 0) {
                                  FocusScope.of(context).previousFocus();
                                }
                              },
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 20.h),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            final otp = _otpControllers
                                .map((controller) => controller.text)
                                .join();
                            print(otp);
                            if (otp.length == 6 &&
                                RegExp(r'^\d{6}$').hasMatch(otp)) {
                              context
                                  .read<OtpBloc>()
                                  .add(SubmitOtp(widget.email, otp, "otp_reg"));
                              // Add logic to verify the OTP here
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Please enter a valid 6-digit OTP.")),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003675),
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 50.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text("Verify"),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Center(
                        child: _isTimerActive
                            ? Column(
                                children: [
                                  Text(
                                    "Haven't Got the OTP yet?",
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  Text(
                                    "Resend OTP in ${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                  )
                                ],
                              )
                            : OutlinedButton(
                                onPressed: _resendOTP,
                                style: OutlinedButton.styleFrom(
                                  // backgroundColor: const Color(0xFFA7C4F7),
                                  foregroundColor: const Color(0XFF003675),
                                  minimumSize: const Size(double.infinity, 56),
                                  side: const BorderSide(
                                    width: 2,
                                    color: Color(0xFF003675),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: const Text("Resend OTP"),
                              ),
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

  Widget reusableText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
        color: Colors.grey.shade800,
      ),
    );
  }
}
