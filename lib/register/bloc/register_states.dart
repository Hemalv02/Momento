
class RegisterStates {
  final String userName;
  final String email;
  final String password;
  final String confirmPassword;
  const RegisterStates({
    required this.userName,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });
  RegisterStates copyWith({
    String? userName,
    String? email,
    String? password,
    String? confirmPassword,
  }) {
    return RegisterStates(
      userName: userName ?? this.userName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }
}