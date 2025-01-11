import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/screens/auth/log_in/bloc/login_bloc.dart';
import 'package:momento/screens/auth/sign_up/bloc/signup_bloc.dart';
import 'package:momento/screens/onboarding/bloc/onboarding_bloc.dart';

class AppBlocProviders {
  static get allBlocProviders => [
        BlocProvider(
          create: (context) => OnboardingBloc(),
        ),
        BlocProvider(
          create: (context) => LoginBloc(),
        ),
        BlocProvider(
          create: (context) => SignUpBloc(),
        ),
      ];
}
