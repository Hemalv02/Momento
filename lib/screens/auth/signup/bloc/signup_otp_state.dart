import 'package:equatable/equatable.dart';

abstract class OtpState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OtpInitial extends OtpState {}

class OtpLoading extends OtpState {}

class OtpSuccess extends OtpState {
  final String message;

  OtpSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class OtpFailure extends OtpState {
  final String error;

  OtpFailure(this.error);

  @override
  List<Object?> get props => [error];
}
