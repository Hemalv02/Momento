abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String token;
  final String userId;
  final String email;

  LoginSuccess(this.token, this.userId, this.email);
}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure(this.error);
}
