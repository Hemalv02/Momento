import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/screens/auth_v2/login/bloc/login_bloc.dart';
import 'package:momento/screens/auth_v2/signup/bloc/signup_bloc.dart';
import 'package:momento/screens/events/fetch_event_bloc/event_api.dart';
import 'package:momento/screens/events/fetch_event_bloc/fetch_event_bloc.dart';
import 'package:momento/screens/onboarding/bloc/onboarding_bloc.dart';
import 'package:momento/services/auth_api.dart';

class AppBlocProviders {
  static get allBlocProviders => [
        BlocProvider(
          create: (context) => OnboardingBloc(),
        ),
        BlocProvider(
            create: (context) => LoginBloc(apiService: ApiService())),
        BlocProvider(
            create: (context) => SignUpBloc(apiService: ApiService())),
        BlocProvider(
            create: (context) => FetchEventBloc(apiService: EventApiService())),
      ];
}
