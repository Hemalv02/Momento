class LogInState{
  final String email;
  final String password;
  const LogInState({this.email = "", this.password = ""});

  LogInState copyWith({String? email, String? password}){
    return LogInState(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}