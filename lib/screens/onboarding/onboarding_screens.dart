import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:momento/screens/onboarding/bloc/onboarding_bloc.dart';
import 'package:momento/screens/onboarding/bloc/onboarding_event.dart';
import 'package:momento/screens/onboarding/bloc/onboarding_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<OnboardingBloc, OnboardingState>(
          builder: (context, state) {
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
                      BlocProvider.of<OnboardingBloc>(context)
                          .add(OnboardingEvent());
                    },
                    children: [
                      _page(
                          1,
                          context,
                          "Next",
                          "Your Event, Your Way!",
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
                          "Join Us to Experience the Best Event Management App.",
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
                        activeColor: const Color(0xFF003675),
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
          },
        ),
      ),
    );
  }

  Widget _page(int index, BuildContext context, String buttonName, String title,
      String subTitle, String imagepath) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.white));
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const Spacer(),
          SizedBox(
            width: 345.w,
            height: 320.h,
            child: Image.asset(
              imagepath,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(
            height: 2,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Text(
              subTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              if (index == 3) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isOnboardingCompleted', true);
                if (context.mounted) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('login', (route) => false);
                }
              } else {
                _controller.animateToPage(index,
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut);
              }
            },
            child: Container(
              width: 325.w,
              height: 50.h,
              margin: EdgeInsets.only(
                  top: 50.h, left: 25.w, right: 25.w, bottom: 20.h),
              decoration: BoxDecoration(
                color: const Color(0xFF003675),
                borderRadius: BorderRadius.circular(15.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(25),
                    blurRadius: 2,
                    spreadRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  buttonName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
