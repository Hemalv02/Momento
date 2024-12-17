import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:momento/bloc_provider.dart';
import 'package:momento/screens/auth/log_in/login.dart';
import 'package:momento/screens/auth/sign_up/signup.dart';
import 'package:momento/screens/onboarding/onboarding_screens.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white));
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  _initializeApp();
}

Future<void> _initializeApp() async {
  final prefs = await SharedPreferences.getInstance();
  final isOnboardingCompleted = prefs.getBool('isOnboardingCompleted') ?? false;

  FlutterNativeSplash.remove();
  runApp(
      MomentoApp(initialRoute: isOnboardingCompleted ? 'login' : 'onboarding'));
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
            'login': (context) => const Login(),
            'signup': (context) => const SignUp(),
          },
          initialRoute: initialRoute,
        ),
      ),
    );
  }
}
