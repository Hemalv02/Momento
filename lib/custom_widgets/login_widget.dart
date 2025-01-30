import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


Widget reusableText(String text) {
  return Container(
    margin: EdgeInsets.only(bottom: 5.h),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
        color: Colors.grey.shade700,
      ),
    ),
  );
}

/// **Reusable Text Field**
Widget reusableTextField({
  required TextEditingController controller,
  required String hintText,
  required IconData prefixIcon,
  required TextInputAction textInputAction,
  required bool obscureText,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    validator: validator,
    textInputAction: textInputAction,
    obscureText: obscureText,
    autocorrect: false,
    decoration: InputDecoration(
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      prefixIcon: Icon(prefixIcon),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        borderSide: BorderSide(color: const Color(0xFF003675), width: 2.w),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        borderSide: BorderSide(color: Colors.red, width: 2.w),
      ),
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
      ),
    ),
    style: TextStyle(
      fontSize: 15.sp,
      fontWeight: FontWeight.normal,
      fontFamily: "Avenir",
    ),
  );
}

/// **Reusable Filled Button**
Widget reusableFilledButton({
  required String text,
  required VoidCallback onPressed,
}) {
  return FilledButton(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      backgroundColor: const Color(0xFF003675),
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    child: Text(text),
  );
}

/// **Reusable Outlined Button**
Widget reusableOutlinedButton({
  required String text,
  required VoidCallback onPressed,
}) {
  return OutlinedButton(
    onPressed: onPressed,
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
    child: Text(text),
  );
}

PreferredSizeWidget reusableAppBar() {
  return AppBar(
    backgroundColor: Colors.white,
    scrolledUnderElevation: 0,
  );
}


Widget forgotPassword(void Function()? func) {
  return Container(
    width: 260.w,
    height: 30.h,
    margin: EdgeInsets.only(top: 10.h, left: 5.w),
    child: GestureDetector(
      onTap: func,
      child: Text(
        'Forgot Your Password?',
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          // decoration: TextDecoration.underline,
          color: const Color(0xFF003675),
          //color: Colors.grey.withAlpha(127),
        ),
      ),
    ),
  );
}

