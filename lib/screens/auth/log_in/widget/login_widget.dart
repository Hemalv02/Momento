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
        color: Colors.grey.shade700,
      ),
    ),
  );
}

Widget buildTextField(
    String text, String textType, void Function(String value)? func) {
  return TextField(
    textInputAction:
        textType == 'email' ? TextInputAction.next : TextInputAction.done,
    autocorrect: false,
    decoration: InputDecoration(
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      prefixIcon: Icon(
        textType == 'password' ? Icons.lock : Icons.person,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        borderSide: BorderSide(color: const Color(0xFF003675), width: 2.w),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        borderSide: BorderSide(color: Colors.red, width: 2.w),
      ),
      hintText: text,
      hintStyle: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
        //color: _textColor.withAlpha(180),
      ),
    ),
    obscureText: textType == 'password' ? true : false,
    style: TextStyle(
        fontSize: 15.sp, fontWeight: FontWeight.normal, fontFamily: "Avenir"),
    onChanged: (value) => func!(value),
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

Widget loginButton(String buttonName, void Function()? function) {
  return FilledButton(
    onPressed: function,
    style: FilledButton.styleFrom(
      backgroundColor: const Color(0xFF003675),
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    child: Text(buttonName),
  );
}

Widget signUpButton(String buttonName, void Function()? function) {
  return OutlinedButton(
    onPressed: function,
    style: OutlinedButton.styleFrom(
      // backgroundColor: const Color(0xFFA7C4F7),
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
    child: Text(buttonName),
  );
}
