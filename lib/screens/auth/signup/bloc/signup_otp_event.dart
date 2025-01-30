import 'package:equatable/equatable.dart';

abstract class OtpEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubmitOtp extends OtpEvent {
  final String email;
  final String otp;
  final String otpType;

  SubmitOtp(this.email, this.otp, this.otpType);

  @override
  List<Object?> get props => [otp];
}

class ResendOtp extends OtpEvent {}
