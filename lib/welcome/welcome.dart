import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:momento/welcome/bloc/welcome_bloc.dart';
import 'package:momento/welcome/bloc/welcome_event.dart';
import 'package:momento/welcome/bloc/welcome_state.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  PageController _controller = PageController(initialPage: 0);
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Scaffold(
          body:
              BlocBuilder<WelcomeBloc, WelcomeState>(builder: (context, state) {
            return Container(
              margin: EdgeInsets.only(top: 34.h),
              width: 375.w,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  PageView(
                    controller: _controller,
                    onPageChanged: (value) {
                      state.page = value;
                      BlocProvider.of<WelcomeBloc>(context).add(WelcomeEvent());
                    },
                    children: [
                      _page(
                          1,
                          context,
                          "Next",
                          "Welcome to Momento - Your Event, Your Way!",
                          "Stay organized, save time, and create memories that last forever.",
                          "assets/images/welcome1.png"),
                      _page(
                          2,
                          context,
                          "Next",
                          "All-in-One Event Management",
                          "Create & Customize Events, Collaborate Seamlessly, Get Smart Reminders, and Track Attendees with Ease.",
                          "assets/images/welcome2.png"),
                      _page(
                          3,
                          context,
                          "Get Started",
                          "Your Journey Starts Here!",
                          "Sign up to create your first event in minutes",
                          "assets/images/welcome3.png"),
                    ],
                  ),
                  Positioned(
                    bottom: 100.h,
                    child: DotsIndicator(
                      position: state.page,
                      dotsCount: 3,
                      mainAxisAlignment: MainAxisAlignment.center,
                      decorator: DotsDecorator(
                        color: Colors.grey,
                        activeColor: Colors.blue,
                        size: const Size.square(8),
                        activeSize: const Size(18, 8),
                        activeShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ));
  }

  Widget _page(int index, BuildContext context, String buttonName, String title,
      String subTitle, String imagepath) {
    return Column(
      children: [
        SizedBox(
          width: 345.w,
          height: 345.w,
          child: Image.asset(imagepath, fit: BoxFit.cover,),
        ),
        Spacer(),
        Container(
          child: Text(
            textAlign: TextAlign.center,
            title,
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold,),
          ),
        ),
        Container(
          width: 375.w,
          padding: EdgeInsets.only(left: 30.w, right: 30.w),
          child: Text(
            textAlign: TextAlign.center,
            subTitle,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.normal),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (index == 3) {
              Navigator.of(context).pushNamedAndRemoveUntil('login', (route) => false);
            } else {
              _controller.animateToPage(index, duration: const Duration(milliseconds: 1000), curve: Curves.easeIn);
            }
          },
          child: Container(
            width: 325.w,
            height: 50.h,
            margin: EdgeInsets.only(top: 100.h, left: 25.w, right: 25.w, bottom: 20.h),
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.circular(15.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(25),
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
                    color: Colors.white),
              ),
            ),
          ),
        )
        
      ],
    );
  }
}
