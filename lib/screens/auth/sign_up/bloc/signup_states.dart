class SignUpStates {
  final String userName;
  final String email;
  final String password;
  final String confirmPassword;
  const SignUpStates({
    required this.userName,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });
  SignUpStates copyWith({
    String? userName,
    String? email,
    String? password,
    String? confirmPassword,
  }) {
    return SignUpStates(
      userName: userName ?? this.userName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }
}
