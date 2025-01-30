import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:momento/services/auth_api.dart';

class ResetPassword extends StatefulWidget {
  final String email;
  const ResetPassword({super.key, required this.email});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
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

  Future<void> _submitResetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final response = await _apiService.resetPassword(
            _passwordController.text, widget.email);

        if (response.message == "Password updated successfully") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Password changed successfully!")),
          );
          Navigator.pushNamed(context, 'login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message)),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred. Please try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 20.h),
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
                    onPressed: _submitResetPassword,
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
