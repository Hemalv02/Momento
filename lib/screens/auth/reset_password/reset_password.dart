import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key, required String email});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool hasLowercase = false;
  bool hasUppercase = false;
  bool hasNumber = false;
  bool hasMinLength = false;

  void _validatePassword(String password) {
    setState(() {
      hasLowercase = RegExp(r'(?=.*[a-z])').hasMatch(password);
      hasUppercase = RegExp(r'(?=.*[A-Z])').hasMatch(password);
      hasNumber = RegExp(r'(?=.*[0-9])').hasMatch(password);
      hasMinLength = password.length >= 8;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // onWillPop: () async {
      //   // Redirect to Forgot Password screen
      //   Navigator.pushReplacementNamed(context, '/forgotPassword');
      //   return false; // Prevent default back navigation
      // },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Change Password"),
          backgroundColor: const Color(0xFF003675),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 35.h),
            padding: EdgeInsets.symmetric(horizontal: 25.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Set a new password",
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    "Please enter a strong password and confirm it below.",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  reusableText("New Password"),
                  SizedBox(height: 10.h),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: "Enter your new password",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                            color: const Color(0xFF003675), width: 2.w),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.red, width: 2.w),
                      ),
                    ),
                    onChanged: _validatePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password cannot be empty";
                      }
                      if (!hasLowercase) {
                        return "Password must contain at least one lowercase letter";
                      }
                      if (!hasUppercase) {
                        return "Password must contain at least one uppercase letter";
                      }
                      if (!hasNumber) {
                        return "Password must contain at least one number";
                      }
                      if (!hasMinLength) {
                        return "Password must be at least 8 characters long";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      reusableChecklistItem(
                          "At least one lowercase letter", hasLowercase),
                      reusableChecklistItem(
                          "At least one uppercase letter", hasUppercase),
                      reusableChecklistItem("At least one number", hasNumber),
                      reusableChecklistItem(
                          "Minimum 8 characters", hasMinLength),
                    ],
                  ),
                  SizedBox(height: 15.h),
                  reusableText("Confirm Password"),
                  SizedBox(height: 10.h),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      hintText: "Re-enter your password",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                            color: const Color(0xFF003675), width: 2.w),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.red, width: 2.w),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please confirm your password";
                      }
                      if (value != _passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15.h),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Password changed successfully!"),
                            ),
                          );
                          // Add logic to update password here
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
                      child: const Text("Change Password"),
                    ),
                  ),
                ],
              ),
            ),
          ),
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

  Widget reusableChecklistItem(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          color: isValid ? Colors.green : Colors.red,
          size: 18.sp,
        ),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: 'Roboto',
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}
