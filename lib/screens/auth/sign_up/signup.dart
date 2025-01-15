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
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpStates>(builder: (context, state) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Sign Up"),
          backgroundColor: const Color(0xFF003675),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(left: 25.w, top: 25.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Let's Get Started",
                      style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                          color: Colors.grey.shade800),
                    ),
                    Text(
                      "Fill up your details to create an account.",
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                          color: Colors.grey.shade600),
                    )
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 25.h),
                    padding: EdgeInsets.only(left: 25.w, right: 25.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        reusableText("Name"),
                        buildTextField("Enter your name", "name", (value) {}),
                        SizedBox(height: 6.h),
                        reusableText("User name"),
                        buildTextField("Enter your username", "username",
                            (value) {
                          context.read<SignUpBloc>().add(UserNameEvent(value));
                        }),
                        SizedBox(height: 6.h),
                        reusableText("Email"),
                        buildTextField("Enter your email", "email", (value) {
                          context.read<SignUpBloc>().add(EmailEvent(value));
                        }),
                        SizedBox(height: 6.h),
                        reusableText("Date of Birth"),
                        const DatePickerTextField(),
                        SizedBox(height: 6.h),
                        reusableText("Password"),
                        buildTextField("Enter your password", "password",
                            (value) {
                          context.read<SignUpBloc>().add(PasswordEvent(value));
                        }),
                        SizedBox(height: 6.h),
                        reusableText("Confirm Password"),
                        buildTextField("Re-enter password", "password",
                            (value) {
                          context
                              .read<SignUpBloc>()
                              .add(ConfirmPasswordEvent(value));
                        }),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // Ensures vertical alignment
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(
                              checkColor: Colors.white,
                              activeColor: const Color(0xFF003675),
                              value: isChecked,
                              onChanged: (bool? value) {
                                setState(() {
                                  isChecked = value!;
                                });
                              },
                            ),
                            Expanded(
                              // Allows text to wrap properly
                              child: Text(
                                "By creating an account, you agree to our Terms of Service and Privacy Policy",
                                style: TextStyle(
                                  fontSize: 12.sp, // Adjust font size if needed
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15.h),
                        loginButton("Sign Up", () {
                          //LoginController(context: context).handleLogIn("email");
                          SignUpController(context: context)
                              .handleEmailSignUp();
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class DatePickerTextField extends StatefulWidget {
  const DatePickerTextField({super.key});

  @override
  _DatePickerTextFieldState createState() => _DatePickerTextFieldState();
}

class _DatePickerTextFieldState extends State<DatePickerTextField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode(); // FocusNode for managing focus
  DateTime? _selectedDate; // Variable to track the currently picked date

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ??
          DateTime.now(), // Use current date or previously picked date
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF003675), // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF003675), // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate; // Update the selected date
        _controller.text = "${pickedDate.toLocal()}".split(' ')[0];
        _focusNode.unfocus(); // Remove focus from the TextField
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode, // Assign the FocusNode to the TextField
      readOnly: true,
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        prefixIcon: const Icon(
          Icons.calendar_today,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(color: const Color(0xFF003675), width: 2.w),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(color: Colors.red, width: 2.w),
        ),
        hintText: "Select your date of birth",
        hintStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.normal,
          //color: _textColor.withAlpha(180),
        ),
      ),
    );
  }
}
