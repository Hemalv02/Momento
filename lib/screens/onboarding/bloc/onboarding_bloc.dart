import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/screens/onboarding/bloc/onboarding_event.dart';
import 'package:momento/screens/onboarding/bloc/onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(OnboardingState()) {
    on<OnboardingEvent>((event, emit) {
      emit(OnboardingState(page: state.page));
    });
  }
}
