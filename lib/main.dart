import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:momento/bloc_provider.dart';
import 'package:momento/screens/auth_v2/forgot_password/forgot_password.dart';
import 'package:momento/screens/auth_v2/login/jwt_token.dart';
import 'package:momento/screens/auth_v2/login/login.dart';
import 'package:momento/screens/auth_v2/otp_verify/otp_verify.dart';
import 'package:momento/screens/auth_v2/reset_password/reset_password.dart';
import 'package:momento/screens/auth_v2/signup/signup.dart';
import 'package:momento/screens/events/create_event.dart';
import 'package:momento/screens/events/event_home.dart';
import 'package:momento/screens/events/event_notification.dart';
import 'package:momento/screens/events/event_schedule.dart';
import 'package:momento/screens/events/ticket_scanner.dart';
import 'package:momento/screens/events/todo_page.dart';
import 'package:momento/screens/home.dart';
import 'package:momento/screens/onboarding/onboarding_screens.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences prefs;

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white));
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  _initializeApp();
}

Future<void> _initializeApp() async {
  final prefs = await SharedPreferences.getInstance();
  final isOnboardingCompleted = prefs.getBool('isOnboardingCompleted') ?? false;
  final tokenValidator = TokenValidator();
  bool isValid = await tokenValidator.isTokenValid();
  final isLoggedIn = isValid;

  FlutterNativeSplash.remove();
  runApp(MomentoApp(
      initialRoute: isOnboardingCompleted
          ? (isLoggedIn ? 'home' : 'login')
          : 'onboarding'));
}

class MomentoApp extends StatelessWidget {
  final String initialRoute;

  const MomentoApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: AppBlocProviders.allBlocProviders,
      child: ScreenUtilInit(
        builder: (context, child) => MaterialApp(
          title: 'Momento',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          routes: {
            'onboarding': (context) => const OnboardingScreen(),
            'login': (context) => const LoginScreen(),
            'signup': (context) => const SignUpScreen(),
            // 'signup_otp': (context) => const SignUpOtpVerification(),
            'forgot_password': (context) => const ForgotPassword(),
            'otp_verify': (context) => const OTPVerification(),
            'reset_password': (context) => const ResetPassword(),
            'home': (context) => const HomeScreen(),
            'create_event': (context) => const CreateEventScreen(),
            'event_home': (context) => const EventHome(),
            'ticket_scanner': (context) => const QRScannerPage(),
            // 'guest_list': (context) => const GuestList(),
            'event_schedule': (context) => const EventSchedule(),
            'event_notification': (context) => const EventNotification(),
            'todo_page': (context) => const ToDoPage(),
          },
          initialRoute: initialRoute,
          //initialRoute: 'event_home',
        ),
      ),
    );
  }
}
