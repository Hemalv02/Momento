import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/screens/auth_v2/signup/bloc/signup_otp_event.dart';
import 'package:momento/screens/auth_v2/signup/bloc/signup_otp_state.dart';
import 'package:momento/services/auth_api.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final ApiService apiService;

  OtpBloc({required this.apiService}) : super(OtpInitial()) {
    on<SubmitOtp>(_onSubmitOtp);
    on<ResendOtp>(_onResendOtp);
  }

  Future<void> _onSubmitOtp(SubmitOtp event, Emitter<OtpState> emit) async {
    emit(OtpLoading());
    try {
      await apiService.verifyOTP(event.email, event.otp, event.otpType);
      emit(OtpSuccess("OTP verified successfully!"));
    } catch (e) {
      if (e is ApiException) {
        emit(OtpFailure(e.message)); // Handle specific API errors
      } else {
        emit(OtpFailure("An unexpected error occurred"));
      }
    }
  }

  Future<void> _onResendOtp(ResendOtp event, Emitter<OtpState> emit) async {
    emit(OtpLoading());
    try {
      // await _apiService.();
      await Future.delayed(Duration(seconds: 2));
      emit(OtpSuccess("OTP resent successfully!"));
    } catch (e) {
      emit(OtpFailure(e.toString()));
    }
  }
}
