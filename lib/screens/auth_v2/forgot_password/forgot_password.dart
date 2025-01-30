// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:momento/screens/auth/log_in/widget/login_widget.dart';

// class ForgotPassword extends StatefulWidget {
//   const ForgotPassword({super.key});

//   @override
//   State<ForgotPassword> createState() => _ForgotPasswordState();
// }

// class _ForgotPasswordState extends State<ForgotPassword> {
//   final formKey = GlobalKey<FormState>();
//   final TextEditingController emailController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//       ),
//       backgroundColor: Colors.white,
//       body: Form(
//         key: formKey,
//         child: SingleChildScrollView(
//           child: Container(
//             margin: EdgeInsets.only(top: 20.h),
//             padding: EdgeInsets.only(left: 25.w, right: 25.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Forgot your password?",
//                       style: TextStyle(
//                           fontSize: 28.sp,
//                           fontWeight: FontWeight.bold,
//                           fontFamily: 'Roboto',
//                           color: Colors.grey.shade800),
//                     ),
//                     Text("Don't worry! We got you covered.",
//                         style: TextStyle(
//                             fontSize: 16.sp,
//                             fontWeight: FontWeight.bold,
//                             fontFamily: 'Roboto',
//                             color: Colors.grey.shade600)),
//                   ],
//                 ),
//                 SizedBox(height: 30.h),
//                 reusableText("Email"),
//                 SizedBox(height: 5.h),
//                 TextFormField(
//                   controller: emailController,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your email';
//                     }
//                     // Simple email validation
//                     if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
//                       return 'Please enter a valid email';
//                     }
//                     return null;
//                   },
//                   textInputAction: TextInputAction.next,
//                   autocorrect: false,
//                   decoration: InputDecoration(
//                     border: const OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(15)),
//                     ),
//                     prefixIcon: const Icon(
//                       Icons.person,
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: const BorderRadius.all(Radius.circular(15)),
//                       borderSide: BorderSide(
//                           color: const Color(0xFF003675), width: 2.w),
//                     ),
//                     errorBorder: OutlineInputBorder(
//                       borderRadius: const BorderRadius.all(Radius.circular(15)),
//                       borderSide: BorderSide(color: Colors.red, width: 2.w),
//                     ),
//                     hintText: "Enter your email",
//                     hintStyle: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.normal,
//                     ),
//                   ),
//                   style: TextStyle(
//                       fontSize: 15.sp,
//                       fontWeight: FontWeight.normal,
//                       fontFamily: "Avenir"),
//                 ),
//                 SizedBox(height: 20.h),
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // context.read<LoginBloc>().add(EmailEvent(email: value));
//                       if (formKey.currentState!.validate()) {
//                         Navigator.of(context).pushNamed('otp_verify');
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF003675),
//                       foregroundColor: Colors.white,
//                       minimumSize: Size(double.infinity, 50.h),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                     ),
//                     child: const Text("Continue"),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:momento/custom_widgets/login_widget.dart';
import 'package:momento/screens/auth_v2/otp_verify/otp_verify.dart';
import 'package:momento/services/auth_api.dart';
class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final ApiService apiService=ApiService();

  Future<void> handleForgotPassword() async {
    if (!formKey.currentState!.validate()) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final response = await apiService.forgotPwd(emailController.text);
      Navigator.pop(context); // Close loading dialog

      if (response.message == "OTP sent to your email") {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return OTPVerification(email: emailController.text,);
        }));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog in case of error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white),
      backgroundColor: Colors.white,
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 20.h),
            padding: EdgeInsets.symmetric(horizontal: 25.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Forgot your password?",
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  "Don't worry! We got you covered.",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    color: Colors.grey.shade600,
                  ),
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
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    prefixIcon: const Icon(Icons.person),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(
                          color: const Color(0xFF003675), width: 2.w),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(color: Colors.red, width: 2.w),
                    ),
                    hintText: "Enter your email",
                    hintStyle: TextStyle(fontSize: 16.sp),
                  ),
                  style: TextStyle(fontSize: 15.sp, fontFamily: "Avenir"),
                ),
                SizedBox(height: 20.h),
                Center(
                  child: ElevatedButton(
                    onPressed: handleForgotPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003675),
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text("Continue"),
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
