import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


Color _bgColor = Colors.black;
Color _textColor = Colors.white;
AppBar buildAppBar(Color  bgColor,Color textColor , String title) {
  _bgColor = bgColor;
  _textColor = textColor;

  return AppBar(
    centerTitle: true,
    backgroundColor: bgColor,
    iconTheme: IconThemeData(color: Colors.white),
    title: Text(
      title,
      style: TextStyle(
          fontSize: 16.sp, fontWeight: FontWeight.normal, color: textColor),
    ),
    bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: Colors.grey.withAlpha(127),
          height: 1.0,
          //width: 1000.w,
        )),
  );
}

Widget buildThirdPartyLogin(BuildContext context) {
  return Container(
    margin: EdgeInsets.only(top: 40.h, bottom: 20.h),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _reusableIcons('google'),
        _reusableIcons('facebook'),
      ],
    ),
  );
}

Widget _reusableIcons(String iconName) {
  return GestureDetector(
    onTap: () {},
    child: SizedBox(
      width: 40.w,
      height: 40.w,
      child: Image.asset('assets/icons/$iconName.png'),
    ),
  );
}

Widget reusableText(String text) {
  return Container(
    margin: EdgeInsets.only(bottom: 5.h),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
        color: Colors.grey.withAlpha(127),
      ),
    ),
  );
}


Widget buildTextField(String text, String textType, void Function(String value)? func) {
  return Container(
    width: 325.w,
    height: 50.h,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15.w),
      border: Border.all(
        color: Colors.grey.withAlpha(127),
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 16.w,
          // height: 16.w,
          margin: EdgeInsets.only(left: 17.w),
          child: Icon(
            textType == 'password' ? Icons.lock : Icons.person,
          ),
        ),
        Container(
          width: 270.w,
          height: 50.h,
          child: TextField(
            onChanged: (value)=> func!(value),
            autocorrect: false,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderSide: BorderSide(
                color: Colors.transparent,
              )),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
              ),
              hintText: text,
              hintStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.normal,
                color: _textColor.withAlpha(180),
              ),
              contentPadding: EdgeInsets.only(left: 20.w),
            ),
            keyboardType: TextInputType.multiline,
            obscureText: textType == 'password' ? true : false,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.normal,
              fontFamily: "Avenir"
            ),
          ),
        ),
      ],
    ),
  );
}

Widget forgotPassword() {
  return Container(
    width: 260.w,
    height: 44.h,
    margin: EdgeInsets.only(top: 10.h),
    child: GestureDetector(
      onTap: () {},
      child: Text(
        'Forgot password?',
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.normal,
          decoration: TextDecoration.underline,
          //decorationColor: Colors.blue,
          //color: Colors.grey.withAlpha(127),
        ),
      ),
    ),
  );
}

Widget buildLogInAndSignUpButton(String buttonName, void Function()? function) {
  return GestureDetector(
    onTap: function,
    child: Container(
      width: 325.w,
      height: 50.h,
      margin: EdgeInsets.only(top: buttonName == "Log in" ? 40.h : 20.h),
      decoration: BoxDecoration(
        color: buttonName == "Don't have an account? Sign up"
            ? _bgColor
            : Colors.indigo,
        borderRadius: BorderRadius.circular(15.w),
        border: Border.all(
          color: buttonName == "Don't have an account? Sign up"
              ? Colors.grey
              : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            blurRadius: 2,
            spreadRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          buttonName,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.normal,
            color: buttonName == "Don't have an account? Sign up"
                ? _textColor
                : _bgColor,
          ),
        ),
      ),
    ),
  );
}
