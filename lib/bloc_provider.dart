import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/screens/onboarding/bloc/onboarding_bloc.dart';

class AppBlocProviders {
  static get allBlocProviders => [
        BlocProvider(
          create: (context) => OnboardingBloc(),
        ),
      ];
}
